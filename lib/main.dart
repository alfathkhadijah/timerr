import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'introduction_page.dart';
import 'loading_page.dart';
import 'timer_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerService>(
      builder: (context, timerService, _) {
        final currentTheme = timerService.currentTheme;
        
        return MaterialApp(
          title: 'Focus Space',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: currentTheme.id == 'midnight' ? Brightness.dark : Brightness.light, 
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: currentTheme.primary,
              primary: currentTheme.primary,
              surface: currentTheme.surface,
              background: currentTheme.background,
              brightness: currentTheme.id == 'midnight' ? Brightness.dark : Brightness.light,
            ),
            textTheme: GoogleFonts.outfitTextTheme(
              Theme.of(context).textTheme.apply(
                bodyColor: currentTheme.textColor,
                displayColor: currentTheme.textColor,
              ),
            ),
            scaffoldBackgroundColor: currentTheme.background,
          ),
          home: const AppInitializer(),
        );
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool? _hasSeenIntroduction;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show loading for at least 5 seconds for better UX and branding
    final loadingFuture = Future.delayed(const Duration(seconds: 5));
    
    // Check introduction status
    final prefs = await SharedPreferences.getInstance();
    
    // For testing: Uncomment the next line to always show the introduction page
    // await prefs.remove('has_seen_introduction');
    
    final hasSeenIntroduction = prefs.getBool('has_seen_introduction') ?? false;
    
    print('Has seen introduction: $hasSeenIntroduction'); // Debug log
    
    // Wait for both loading time and data loading
    await loadingFuture;
    
    if (mounted) {
      setState(() {
        _hasSeenIntroduction = hasSeenIntroduction;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingPage();
    }
    
    // Show introduction page if first time, otherwise show home page
    return _hasSeenIntroduction! ? const HomePage() : const IntroductionPage();
  }
}
