import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'timer_service.dart';
import 'stats_page.dart';
import 'todo_page.dart';
import 'shop_page.dart';
import 'models/app_theme.dart';
import 'models/app_character.dart';
import 'widgets/session_complete_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  double _sliderValue = 25;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Set up session complete callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerService = Provider.of<TimerService>(context, listen: false);
      timerService.setSessionCompleteCallback(_showSessionCompleteDialog);
    });
  }

  void _showSessionCompleteDialog(int coinsEarned, String category, int minutes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionCompleteDialog(
        coinsEarned: coinsEarned,
        category: category,
        durationMinutes: minutes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerService = Provider.of<TimerService>(context);
    final AppTheme currentTheme = timerService.currentTheme;

    final Color textColor = currentTheme.textColor;
    final Color accentColor = currentTheme.accent;
    final Color backgroundColor = currentTheme.background;

    return Scaffold(
      body: Stack(
        children: [
          // Background Layer
          if (currentTheme.backgroundImagePath != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  currentTheme.backgroundImagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: backgroundColor),
                ),
              ),
            )
          else
            Container(color: backgroundColor),

          // Main Content Layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_currentIndex),
                      child: _currentIndex == 0 
                        ? _buildTimerView(context, textColor, accentColor, backgroundColor, timerService)
                        : _currentIndex == 1 
                          ? const TodoPage()
                          : _currentIndex == 2
                            ? const ShopPage() 
                            : const StatsPage(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
              if (states.contains(MaterialState.selected)) {
                return TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                );
              }
              return TextStyle(
                color: timerService.isRunning ? textColor.withOpacity(0.25) : textColor.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              );
            }),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            // Very soft, barely visible background
            color: textColor.withOpacity(0.02),
            border: Border(
              top: BorderSide(
                color: textColor.withOpacity(0.06),
                width: 0.5,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (int index) {
              if (!timerService.isRunning) {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            backgroundColor: Colors.transparent,
            indicatorColor: accentColor.withOpacity(0.08),
            elevation: 0,
            height: 65,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.timer_outlined, 
                  color: textColor.withOpacity(0.4),
                ), 
                selectedIcon: Icon(
                  Icons.timer, 
                  color: accentColor,
                ), 
                label: 'Timer'
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.checklist_outlined, 
                  color: timerService.isRunning 
                    ? textColor.withOpacity(0.15) 
                    : textColor.withOpacity(0.4),
                ), 
                selectedIcon: Icon(
                  Icons.checklist, 
                  color: timerService.isRunning 
                    ? accentColor.withOpacity(0.25) 
                    : accentColor,
                ), 
                label: 'Tasks'
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.shopping_bag_outlined, 
                  color: timerService.isRunning 
                    ? textColor.withOpacity(0.15) 
                    : textColor.withOpacity(0.4),
                ), 
                selectedIcon: Icon(
                  Icons.shopping_bag, 
                  color: timerService.isRunning 
                    ? accentColor.withOpacity(0.25) 
                    : accentColor,
                ), 
                label: 'Shop'
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.bar_chart_outlined, 
                  color: timerService.isRunning 
                    ? textColor.withOpacity(0.15) 
                    : textColor.withOpacity(0.4),
                ), 
                selectedIcon: Icon(
                  Icons.bar_chart, 
                  color: timerService.isRunning 
                    ? accentColor.withOpacity(0.25) 
                    : accentColor,
                ), 
                label: 'Stats'
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerView(BuildContext context, Color textColor, Color accentColor, Color backgroundColor, TimerService timerService) {
    return Column(
      children: [
        // Fixed Header Row with Coins (stays on top)
        Container(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Focus Space',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textColor.withOpacity(0.7), // More muted
                  letterSpacing: -0.5,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06), // More muted
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.12)), // More muted
                  ),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        '${timerService.coins}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor.withOpacity(0.8), // More muted
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Content based on timer state
        Expanded(
          child: timerService.isRunning 
            ? // When running - full screen centered timer
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Timer Display
                    Container(
                      width: 320,
                      height: 320,
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glass sphere background
                          ClipOval(
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.15),
                                      Colors.white.withOpacity(0.02),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Progress indicator
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: CircularProgressIndicator(
                              value: timerService.progress,
                              strokeWidth: 8,
                              backgroundColor: textColor.withOpacity(0.03), // More muted
                              valueColor: AlwaysStoppedAnimation<Color>(accentColor.withOpacity(0.8)), // More muted
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          
                          // Timer content
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Character icon for pomodoro mode
                              if (timerService.mode == TimerMode.pomodoro)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    timerService.currentCharacter.icon,
                                    style: const TextStyle(fontSize: 52),
                                  ),
                                ),
                              // Timer text
                              Text(
                                _formatTime(timerService.remainingSeconds, timerService),
                                style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  color: textColor.withOpacity(0.8), // More muted
                                  letterSpacing: -2,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                              // Category badge
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.06), // More muted
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  timerService.selectedCategory.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: accentColor.withOpacity(0.7), // More muted
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Motivational Quote
                    if (timerService.currentQuote.isNotEmpty) ...[
                      const SizedBox(height: 40),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06), // More muted
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.12)), // More muted
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.format_quote,
                              color: accentColor.withOpacity(0.5), // More muted
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              timerService.currentQuote,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor.withOpacity(0.7), // More muted
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // End session early button
                    const SizedBox(height: 40),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showGiveUpDialog(context, timerService, accentColor, textColor),
                        borderRadius: BorderRadius.circular(12),
                        splashColor: textColor.withOpacity(0.1),
                        highlightColor: textColor.withOpacity(0.05),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                          decoration: BoxDecoration(
                            // Minimalist theme-aware design
                            color: textColor.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: textColor.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'End session early',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: textColor.withOpacity(0.8),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : // When not running - normal layout with controls
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mode Toggle
                  Center(
                    child: SegmentedButton<TimerMode>(
                      segments: const [
                        ButtonSegment<TimerMode>(
                          value: TimerMode.pomodoro,
                          label: Text('Pomodoro'),
                          icon: Icon(Icons.timer),
                        ),
                        ButtonSegment<TimerMode>(
                          value: TimerMode.basic,
                          label: Text('Basic Timer'),
                          icon: Icon(Icons.watch_later_outlined),
                        ),
                      ],
                      selected: <TimerMode>{timerService.mode},
                      onSelectionChanged: (Set<TimerMode> newSelection) {
                        timerService.setMode(newSelection.first);
                        // Set initial duration for basic mode
                        if (newSelection.first == TimerMode.basic) {
                          timerService.setDuration(_sliderValue.toInt());
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.selected)) {
                            return accentColor.withOpacity(0.12); // More muted
                          }
                          return Colors.transparent;
                        }),
                        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.selected)) {
                            return accentColor.withOpacity(0.8); // More muted
                          }
                          return textColor.withOpacity(0.5); // More muted
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // Timer Display
                  Center(
                    child: Container(
                      width: 240,
                      height: 240,
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glass sphere background
                          ClipOval(
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.15),
                                      Colors.white.withOpacity(0.02),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Progress indicator
                          SizedBox(
                            width: 220,
                            height: 220,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 6,
                              backgroundColor: textColor.withOpacity(0.03), // More muted
                              valueColor: AlwaysStoppedAnimation<Color>(accentColor.withOpacity(0.6)), // More muted
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          
                          // Timer content
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Character icon for pomodoro mode
                              if (timerService.mode == TimerMode.pomodoro)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Text(
                                    timerService.currentCharacter.icon,
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                ),
                              // Timer text
                              Text(
                                _formatTime(timerService.remainingSeconds, timerService),
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: textColor.withOpacity(0.8), // More muted
                                  letterSpacing: -1,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Controls
                  _buildCategorySelector(timerService, textColor, accentColor, backgroundColor),
                  
                  const SizedBox(height: 12),
                  // INPUTS BASED ON MODE
                  if (timerService.mode == TimerMode.pomodoro) ...[
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         _buildPresetButton(context, 25, timerService, textColor, accentColor),
                         _buildPresetButton(context, 50, timerService, textColor, accentColor),
                       ],
                     )
                  ] else ...[
                    // Basic Slider
                    Column(
                      children: [
                        Text(
                          'Duration: ${_sliderValue.toInt()} min',
                          style: TextStyle(color: textColor.withOpacity(0.6)), // More muted
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: accentColor.withOpacity(0.7), // More muted
                            inactiveTrackColor: Colors.black.withOpacity(0.06), // More muted
                            thumbColor: accentColor.withOpacity(0.8), // More muted
                            overlayColor: accentColor.withOpacity(0.1), // More muted
                          ),
                          child: Slider(
                            value: _sliderValue,
                            min: 5, 
                            max: 120,
                            divisions: 23, 
                            label: '${_sliderValue.toInt()} min',
                            onChanged: (value) {
                              setState(() {
                                _sliderValue = value;
                              });
                              // Set duration immediately when slider changes
                              timerService.setDuration(_sliderValue.toInt());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],

                  const Spacer(), // Push button to bottom
                  
                  // Action Button
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (timerService.remainingSeconds > 0) ? () {
                        timerService.startTimer();
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (timerService.remainingSeconds > 0) 
                          ? accentColor.withOpacity(0.8) 
                          : textColor.withOpacity(0.1),
                        foregroundColor: (timerService.remainingSeconds > 0) 
                          ? Colors.white 
                          : textColor.withOpacity(0.4),
                        elevation: (timerService.remainingSeconds > 0) ? 4 : 0,
                        shadowColor: accentColor.withOpacity(0.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: Text(
                        (timerService.remainingSeconds > 0) 
                          ? 'START FOCUS' 
                          : 'SELECT DURATION FIRST',
                        style: TextStyle(
                          fontSize: (timerService.remainingSeconds > 0) ? 18 : 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: (timerService.remainingSeconds > 0) ? 1.5 : 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
        ),
      ],
    );
  }
  
  Widget _buildPresetButton(BuildContext context, int minutes, TimerService service, Color textColor, Color accentColor) {
      final isSelected = service.remainingSeconds == minutes * 60;
      return InkWell(
        onTap: () {
          service.setDuration(minutes);
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withOpacity(0.1) : Colors.white.withOpacity(0.12), // More muted
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? accentColor.withOpacity(0.6) : Colors.white.withOpacity(0.15), // More muted
              width: 2,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: accentColor.withOpacity(0.15), // More muted
                blurRadius: 8, // Reduced blur
                spreadRadius: 0, // Reduced spread
              )
            ] : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$minutes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? accentColor.withOpacity(0.8) : textColor.withOpacity(0.7), // More muted
                ),
              ),
              Text(
                'MIN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: (isSelected ? accentColor.withOpacity(0.8) : textColor.withOpacity(0.7)).withOpacity(0.6), // More muted
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      );
  }
  String _formatTime(int seconds, TimerService service) {
    if (service.mode == TimerMode.pomodoro && seconds == 0 && !service.isRunning) {
      return "25:00";
    }
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showGiveUpDialog(BuildContext context, TimerService service, Color accentColor, Color textColor) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, widget) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(animation1.value),
          child: Opacity(
            opacity: animation1.value,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with simple background
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    'End Session Early?',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    'You\'re doing great! Ending now means you won\'t earn coins for this session. Are you sure you want to stop?',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    children: [
                      // Keep going button (primary)
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentColor, accentColor.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => Navigator.pop(context),
                              child: const Center(
                                child: Text(
                                  'KEEP GOING',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Give up button (secondary)
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                Navigator.pop(context);
                                service.stopTimer();
                              },
                              child: Center(
                                child: Text(
                                  'END',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  void _showEditCategoriesDialog(BuildContext context, TimerService service, Color textColor, Color accentColor, Color backgroundColor) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Edit Categories', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'New Category',
                          hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: accentColor),
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          service.addCategory(controller.text);
                          controller.clear();
                          setDialogState(() {});
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: service.categories.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final cat = service.categories[index];
                      return ListTile(
                        title: Text(cat, style: TextStyle(color: textColor)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            if (service.categories.length > 1) {
                              service.removeCategory(cat);
                              setDialogState(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('At least one category is required')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CLOSE', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCategorySelector(TimerService service, Color textColor, Color accentColor, Color backgroundColor) {
    if (service.isRunning) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Session Goal",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textColor.withOpacity(0.3), // More muted
                letterSpacing: 1.2,
              ),
            ),
            IconButton(
              onPressed: () => _showEditCategoriesDialog(context, service, textColor, accentColor, backgroundColor),
              icon: Icon(Icons.settings_suggest_rounded, color: accentColor.withOpacity(0.6), size: 20), // More muted
              tooltip: 'Manage Categories',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: service.categories.length,
            itemBuilder: (context, index) {
              final category = service.categories[index];
              final isSelected = service.selectedCategory == category;
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  service.setCategory(category);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor.withOpacity(0.8) : Colors.white.withOpacity(0.08), // More muted
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.2), // More muted
                        blurRadius: 8, // Reduced blur
                        offset: const Offset(0, 2), // Reduced offset
                      )
                    ] : [],
                  ),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 80),
                      curve: Curves.easeOut,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : textColor.withOpacity(0.4), // More muted
                        letterSpacing: 0.8,
                      ),
                      child: Text(category.toUpperCase()),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}