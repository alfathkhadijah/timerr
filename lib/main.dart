import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';
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
          title: 'Study Timer',
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
          home: const HomePage(),
        );
      },
    );
  }
}
