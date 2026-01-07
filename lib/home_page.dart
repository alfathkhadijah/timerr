import 'dart:math' as math;
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Universal responsive system
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;
                final aspectRatio = screenHeight / screenWidth;
                final isTablet = screenWidth >= 600 || (screenWidth * screenHeight) > 1000000;
                final isCompact = screenWidth < 380;
                
                // Adaptive padding and constraints
                final horizontalPadding = isTablet ? 32.0 : (isCompact ? 16.0 : 24.0);
                final verticalPadding = isTablet ? 20.0 : 16.0;
                final maxContentWidth = isTablet ? 500.0 : (screenWidth * 0.95);
                
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, 
                    vertical: verticalPadding
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxContentWidth,
                        maxHeight: screenHeight,
                      ),
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
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          // Universal navigation bar sizing
          final screenWidth = constraints.maxWidth;
          final screenHeight = MediaQuery.of(context).size.height;
          final textScaleFactor = MediaQuery.of(context).textScaleFactor;
          
          final isTablet = screenWidth >= 600 || (screenWidth * screenHeight) > 1000000;
          final baseScale = math.min(screenWidth / 375.0, screenHeight / 812.0);
          final finalScale = math.max(0.8, math.min(1.2, baseScale));
          
          final navHeight = (isTablet ? 75.0 : 65.0) * finalScale;
          final iconSize = (isTablet ? 28.0 : 24.0) * finalScale;
          final fontSize = (isTablet ? 14.0 : 12.0) * finalScale / textScaleFactor;
          
          return Theme(
            data: Theme.of(context).copyWith(
              navigationBarTheme: NavigationBarThemeData(
                labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
                  if (states.contains(MaterialState.selected)) {
                    return TextStyle(
                      color: accentColor,
                      fontSize: fontSize.clamp(10.0, 16.0),
                      fontWeight: FontWeight.w600,
                    );
                  }
                  return TextStyle(
                    color: timerService.isRunning ? textColor.withOpacity(0.25) : textColor.withOpacity(0.5),
                    fontSize: fontSize.clamp(10.0, 16.0),
                    fontWeight: FontWeight.w500,
                  );
                }),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
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
                height: navHeight.clamp(60.0, 85.0),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      Icons.timer_outlined, 
                      color: textColor.withOpacity(0.4),
                      size: iconSize.clamp(20.0, 32.0),
                    ), 
                    selectedIcon: Icon(
                      Icons.timer, 
                      color: accentColor,
                      size: iconSize.clamp(20.0, 32.0),
                    ), 
                    label: 'Timer'
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.checklist_outlined, 
                      color: timerService.isRunning 
                        ? textColor.withOpacity(0.15) 
                        : textColor.withOpacity(0.4),
                      size: iconSize.clamp(20.0, 32.0),
                    ), 
                    selectedIcon: Icon(
                      Icons.checklist, 
                      color: timerService.isRunning 
                        ? accentColor.withOpacity(0.25) 
                        : accentColor,
                      size: iconSize.clamp(20.0, 32.0),
                    ), 
                    label: 'Tasks'
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.shopping_bag_outlined, 
                      color: timerService.isRunning 
                        ? textColor.withOpacity(0.15) 
                        : textColor.withOpacity(0.4),
                      size: iconSize.clamp(20.0, 32.0),
                    ), 
                    selectedIcon: Icon(
                      Icons.shopping_bag, 
                      color: timerService.isRunning 
                        ? accentColor.withOpacity(0.25) 
                        : accentColor,
                      size: iconSize.clamp(20.0, 32.0),
                    ), 
                    label: 'Shop'
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.bar_chart_outlined, 
                      color: timerService.isRunning 
                        ? textColor.withOpacity(0.15) 
                        : textColor.withOpacity(0.4),
                      size: iconSize.clamp(20.0, 32.0),
                    ), 
                    selectedIcon: Icon(
                      Icons.bar_chart, 
                      color: timerService.isRunning 
                        ? accentColor.withOpacity(0.25) 
                        : accentColor,
                      size: iconSize.clamp(20.0, 32.0),
                    ), 
                    label: 'Stats'
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimerView(BuildContext context, Color textColor, Color accentColor, Color backgroundColor, TimerService timerService) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    final textScaleFactor = mediaQuery.textScaleFactor;
    
    // Universal device classification system
    final aspectRatio = screenHeight / screenWidth;
    final screenArea = screenWidth * screenHeight;
    final effectiveWidth = screenWidth / textScaleFactor;
    final effectiveHeight = screenHeight / textScaleFactor;
    
    // Device type detection (works for all brands and models)
    final isTablet = screenWidth >= 600 || screenArea > 1000000;
    final isSmallPhone = screenWidth < 360 || screenHeight < 640;
    final isLargePhone = screenWidth > 400 && screenHeight > 800 && !isTablet;
    final isFoldable = aspectRatio < 1.3 || aspectRatio > 2.5;
    final isCompactDevice = effectiveWidth < 380;
    
    // Universal scaling factors based on screen characteristics
    final baseScale = math.min(effectiveWidth / 375.0, effectiveHeight / 812.0); // iPhone 11 Pro as baseline
    final densityScale = math.min(devicePixelRatio / 3.0, 1.2); // Normalize density differences
    final areaScale = math.sqrt(screenArea / 304875.0); // Normalize by iPhone 11 Pro area
    final finalScale = (baseScale + areaScale) / 2.0;
    
    // Adaptive sizing system - works universally
    final headerFontSize = (isTablet ? 32.0 : 24.0) * finalScale;
    final coinFontSize = (isTablet ? 22.0 : 16.0) * finalScale;
    final timerSize = math.min(
      (isTablet ? 300.0 : 220.0) * finalScale,
      effectiveWidth * 0.65,
    );
    final timerFontSize = (isTablet ? 42.0 : 32.0) * finalScale;
    final characterSize = (isTablet ? 50.0 : 38.0) * finalScale; // Increased from 40.0 : 30.0
    
    return Column(
      children: [
        // Fixed Header Row with Coins (stays on top)
        Container(
          padding: EdgeInsets.only(bottom: math.max(12.0, 16.0 * finalScale)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Focus Space',
                  style: TextStyle(
                    fontSize: headerFontSize.clamp(18.0, 36.0),
                    fontWeight: FontWeight.w800,
                    color: textColor.withOpacity(0.7),
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🪙',
                    style: TextStyle(
                      fontSize: math.max(16.0, 20.0 * finalScale).clamp(14.0, 24.0),
                    ),
                  ),
                  SizedBox(width: math.max(4.0, 6.0 * finalScale)),
                  Text(
                    '${timerService.coins}',
                    style: TextStyle(
                      fontSize: coinFontSize.clamp(14.0, 24.0),
                      fontWeight: FontWeight.w700,
                      color: textColor.withOpacity(0.7), // Match "Focus Space" text color
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Content based on timer state
        Expanded(
          child: timerService.isRunning 
            ? // When running - full screen centered timer
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Timer Display
                      Container(
                        width: timerSize + (80 * finalScale),
                        height: timerSize + (80 * finalScale),
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glass sphere background
                            ClipOval(
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  width: timerSize,
                                  height: timerSize,
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
                              width: timerSize + (20 * finalScale),
                              height: timerSize + (20 * finalScale),
                              child: CircularProgressIndicator(
                                value: timerService.progress,
                                strokeWidth: math.max(6.0, 10.0 * finalScale).clamp(4.0, 12.0),
                                backgroundColor: textColor.withOpacity(0.03),
                                valueColor: AlwaysStoppedAnimation<Color>(accentColor.withOpacity(0.8)),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            
                            // Timer content
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Character icon for pomodoro mode - original style
                                if (timerService.mode == TimerMode.pomodoro)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: math.max(4.0, 8.0 * finalScale)),
                                    child: Text(
                                      timerService.currentCharacter.icon,
                                      style: TextStyle(
                                        fontSize: (characterSize * 0.8).clamp(20.0, 40.0), // Increased from 0.7 and higher min
                                      ),
                                    ),
                                  ),
                                // Timer text
                                Text(
                                  _formatTime(timerService.remainingSeconds, timerService),
                                  style: TextStyle(
                                    fontSize: timerFontSize.clamp(24.0, 48.0),
                                    fontWeight: FontWeight.w900,
                                    color: textColor.withOpacity(0.8),
                                    letterSpacing: -1 * finalScale,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                                // Category badge
                                Container(
                                  margin: EdgeInsets.only(top: math.max(8.0, 12.0 * finalScale)),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: math.max(16.0, 20.0 * finalScale), 
                                    vertical: math.max(6.0, 8.0 * finalScale)
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    timerService.selectedCategory.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: math.max(12.0, 16.0 * finalScale).clamp(10.0, 18.0),
                                      fontWeight: FontWeight.w800,
                                      color: accentColor.withOpacity(0.7),
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
                        SizedBox(height: math.max(24.0, 40.0 * finalScale)),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                          padding: EdgeInsets.all(math.max(16.0, 24.0 * finalScale)),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.12)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.format_quote,
                                color: accentColor.withOpacity(0.5),
                                size: math.max(24.0, 28.0 * finalScale),
                              ),
                              SizedBox(height: math.max(6.0, 8.0 * finalScale)),
                              Text(
                                timerService.currentQuote,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: math.max(14.0, 18.0 * finalScale).clamp(12.0, 20.0),
                                  fontWeight: FontWeight.w500,
                                  color: textColor.withOpacity(0.7),
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // End session early button
                      SizedBox(height: math.max(24.0, 40.0 * finalScale)),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showGiveUpDialog(context, timerService, accentColor, textColor),
                          borderRadius: BorderRadius.circular(12),
                          splashColor: textColor.withOpacity(0.1),
                          highlightColor: textColor.withOpacity(0.05),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: math.max(14.0, 16.0 * finalScale), 
                              horizontal: math.max(24.0, 28.0 * finalScale)
                            ),
                            decoration: BoxDecoration(
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
                                fontSize: math.max(15.0, 17.0 * finalScale).clamp(13.0, 19.0),
                                fontWeight: FontWeight.w500,
                                color: textColor.withOpacity(0.8),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: math.max(16.0, 24.0 * finalScale)),
                    ],
                  ),
                ),
              )
            : // When not running - normal layout with controls
              LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Mode Toggle
                      Center(
                        child: SegmentedButton<TimerMode>(
                          segments: [
                            ButtonSegment<TimerMode>(
                              value: TimerMode.pomodoro,
                              label: Text('Pomodoro', style: TextStyle(fontSize: math.max(14.0, 16.0 * finalScale).clamp(12.0, 18.0))),
                              icon: Icon(Icons.timer, size: math.max(20.0, 24.0 * finalScale).clamp(18.0, 28.0)),
                            ),
                            ButtonSegment<TimerMode>(
                              value: TimerMode.basic,
                              label: Text('Basic Timer', style: TextStyle(fontSize: math.max(14.0, 16.0 * finalScale).clamp(12.0, 18.0))),
                              icon: Icon(Icons.watch_later_outlined, size: math.max(20.0, 24.0 * finalScale).clamp(18.0, 28.0)),
                            ),
                          ],
                          selected: <TimerMode>{timerService.mode},
                          onSelectionChanged: (Set<TimerMode> newSelection) {
                            timerService.setMode(newSelection.first);
                            if (newSelection.first == TimerMode.basic) {
                              timerService.setDuration(_sliderValue.toInt());
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                              if (states.contains(MaterialState.selected)) {
                                return accentColor.withOpacity(0.12);
                              }
                              return Colors.transparent;
                            }),
                            foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                              if (states.contains(MaterialState.selected)) {
                                return accentColor.withOpacity(0.8);
                              }
                              return textColor.withOpacity(0.5);
                            }),
                          ),
                        ),
                      ),

                      SizedBox(height: math.max(16.0, 20.0 * finalScale)),
                      
                      // Timer Display
                      Center(
                        child: Container(
                          width: timerSize,
                          height: timerSize,
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glass sphere background
                              ClipOval(
                                child: BackdropFilter(
                                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    width: timerSize - (40 * finalScale),
                                    height: timerSize - (40 * finalScale),
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
                                width: timerSize - (20 * finalScale),
                                height: timerSize - (20 * finalScale),
                                child: CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: math.max(6.0, 8.0 * finalScale).clamp(4.0, 10.0),
                                  backgroundColor: textColor.withOpacity(0.03),
                                  valueColor: AlwaysStoppedAnimation<Color>(accentColor.withOpacity(0.6)),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              
                              // Timer content
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Character icon for pomodoro mode - original style
                                  if (timerService.mode == TimerMode.pomodoro)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: math.max(4.0, 6.0 * finalScale)),
                                      child: Text(
                                        timerService.currentCharacter.icon,
                                        style: TextStyle(
                                          fontSize: (characterSize * 0.8).clamp(18.0, 35.0), // Increased from 0.7 and higher min
                                        ),
                                      ),
                                    ),
                                  // Timer text
                                  Text(
                                    _formatTime(timerService.remainingSeconds, timerService),
                                    style: TextStyle(
                                      fontSize: timerFontSize.clamp(20.0, 42.0),
                                      fontWeight: FontWeight.w900,
                                      color: textColor.withOpacity(0.8),
                                      letterSpacing: -1 * finalScale,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: math.max(8.0, 12.0 * finalScale)), // Reduced spacing before buttons

                      // Controls
                      _buildCategorySelector(timerService, textColor, accentColor, backgroundColor),
                      
                      SizedBox(height: math.max(8.0, 12.0 * finalScale)), // Reduced spacing after categories
                      // INPUTS BASED ON MODE
                      if (timerService.mode == TimerMode.pomodoro) ...[
                        // Make buttons span full width like session goal
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildPresetButton(context, 25, timerService, textColor, accentColor),
                              ),
                              SizedBox(width: math.max(8.0, 16.0 * finalScale)),
                              Expanded(
                                child: _buildPresetButton(context, 50, timerService, textColor, accentColor),
                              ),
                            ],
                          ),
                        ),
                        // Minimal spacing to prevent overflow
                        SizedBox(height: math.max(8.0, 12.0 * finalScale)),
                      ] else ...[
                        // Basic Slider
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                          child: Column(
                            children: [
                              Text(
                                'Duration: ${_sliderValue.toInt()} min',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.6),
                                  fontSize: math.max(14.0, 16.0 * finalScale).clamp(12.0, 18.0),
                                ),
                              ),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: accentColor.withOpacity(0.7),
                                  inactiveTrackColor: Colors.black.withOpacity(0.06),
                                  thumbColor: accentColor.withOpacity(0.8),
                                  overlayColor: accentColor.withOpacity(0.1),
                                  trackHeight: math.max(4.0, 6.0 * finalScale).clamp(3.0, 8.0),
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
                                    timerService.setDuration(_sliderValue.toInt());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const Spacer(),
                      
                      // Action Button
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        child: SizedBox(
                          height: math.max(44.0, 56.0 * finalScale).clamp(40.0, 64.0), // Reduced height
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
                                fontSize: (timerService.remainingSeconds > 0) 
                                  ? math.max(16.0, 20.0 * finalScale).clamp(14.0, 22.0)
                                  : math.max(14.0, 18.0 * finalScale).clamp(12.0, 20.0),
                                fontWeight: FontWeight.w800,
                                letterSpacing: (timerService.remainingSeconds > 0) ? 1.5 : 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: math.max(8.0, 12.0 * finalScale)), // Reduced final spacing
                    ],
                  );
                },
              ),
        ),
      ],
    );
  }
  
  Widget _buildPresetButton(BuildContext context, int minutes, TimerService service, Color textColor, Color accentColor) {
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;
      final screenHeight = mediaQuery.size.height;
      final textScaleFactor = mediaQuery.textScaleFactor;
      
      // Universal scaling system
      final effectiveWidth = screenWidth / textScaleFactor;
      final baseScale = math.min(effectiveWidth / 375.0, screenHeight / 812.0);
      final finalScale = math.max(0.8, math.min(1.3, baseScale));
      
      final isSelected = service.remainingSeconds == minutes * 60;
      
      // More aggressive size reduction to eliminate overflow completely
      final fontSize = (16.0 * finalScale).clamp(12.0, 20.0); // Further reduced from 18.0
      final labelFontSize = (8.0 * finalScale).clamp(6.0, 11.0); // Further reduced from 9.0
      final buttonHeight = (55.0 * finalScale).clamp(40.0, 65.0); // Further reduced from 60.0
      final verticalPadding = (6.0 * finalScale).clamp(3.0, 10.0); // Further reduced from 8.0
      final horizontalPadding = (12.0 * finalScale).clamp(8.0, 16.0); // Further reduced from 14.0
      
      return InkWell(
        onTap: () {
          service.setDuration(minutes);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: buttonHeight,
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withOpacity(0.1) : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? accentColor.withOpacity(0.6) : Colors.white.withOpacity(0.15),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: accentColor.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$minutes',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? accentColor.withOpacity(0.8) : textColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 2.0 * finalScale), // Reduced spacing between number and MIN
              Text(
                'MIN',
                style: TextStyle(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                  color: (isSelected ? accentColor.withOpacity(0.8) : textColor.withOpacity(0.7)).withOpacity(0.6),
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
    
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final textScaleFactor = mediaQuery.textScaleFactor;
    final devicePixelRatio = mediaQuery.devicePixelRatio;
    
    // Universal scaling system
    final effectiveWidth = screenWidth / textScaleFactor;
    final baseScale = math.min(effectiveWidth / 375.0, screenHeight / 812.0);
    final finalScale = math.max(0.8, math.min(1.3, baseScale));
    
    // Adaptive sizing for all devices
    final titleFontSize = (14.0 * finalScale).clamp(11.0, 18.0);
    final categoryFontSize = (12.0 * finalScale).clamp(9.0, 15.0);
    final iconSize = (20.0 * finalScale).clamp(16.0, 26.0);
    final categoryHeight = (40.0 * finalScale).clamp(32.0, 50.0);
    
    // Calculate available width for categories
    final availableWidth = screenWidth - 48; // Account for padding
    final settingsButtonWidth = iconSize + 16;
    final categoryAreaWidth = availableWidth - settingsButtonWidth;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Session Goal",
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w800,
                color: textColor.withOpacity(0.3),
                letterSpacing: 1.2,
              ),
            ),
            IconButton(
              onPressed: () => _showEditCategoriesDialog(context, service, textColor, accentColor, backgroundColor),
              icon: Icon(Icons.settings_suggest_rounded, color: accentColor.withOpacity(0.6), size: iconSize),
              tooltip: 'Manage Categories',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: iconSize + 8,
                minHeight: iconSize + 8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: categoryHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: service.categories.length,
                itemBuilder: (context, index) {
                  final category = service.categories[index];
                  final isSelected = service.selectedCategory == category;
                  
                  // Universal text measurement system
                  final textPainter = TextPainter(
                    text: TextSpan(
                      text: category.toUpperCase(),
                      style: TextStyle(
                        fontSize: categoryFontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    maxLines: 1,
                    textDirection: TextDirection.ltr,
                  );
                  textPainter.layout();
                  
                  // Smart width calculation that works on all devices
                  final textWidth = textPainter.size.width;
                  final basePadding = 24.0 * finalScale;
                  final minWidth = 60.0 * finalScale;
                  final idealWidth = textWidth + basePadding;
                  
                  // Ensure all categories fit within screen bounds
                  final maxCategoryWidth = (categoryAreaWidth - (service.categories.length * 8)) / service.categories.length;
                  final finalWidth = math.max(minWidth, math.min(idealWidth, maxCategoryWidth));
                  
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      service.setCategory(category);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                      width: finalWidth,
                      margin: EdgeInsets.only(right: 8.0 * finalScale),
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor.withOpacity(0.8) : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18.0 * finalScale),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ] : [],
                      ),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 80),
                          curve: Curves.easeOut,
                          style: TextStyle(
                            fontSize: categoryFontSize,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : textColor.withOpacity(0.4),
                            letterSpacing: 0.2,
                          ),
                          child: Text(
                            category.toUpperCase(),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}