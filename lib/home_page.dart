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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  double _sliderValue = 25;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
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
                opacity: 0.15, // Subtle background
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
                    ? _buildTimerView(context, textColor, accentColor, backgroundColor)
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
             setState(() {
               _currentIndex = index;
             });
          },
          backgroundColor: Colors.transparent,
          indicatorColor: accentColor.withOpacity(0.2),
          elevation: 0,
          height: 65,
          destinations: const [
             NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer), label: 'Timer'),
             NavigationDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: 'Tasks'),
             NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Shop'),
             NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerView(BuildContext context, Color textColor, Color accentColor, Color backgroundColor) {
    final timerService = Provider.of<TimerService>(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row with Coins
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Focus Space',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textColor.withOpacity(0.9),
                  letterSpacing: -0.5,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Mode Toggle
          if (!timerService.isRunning)
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
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.selected)) {
                      return accentColor.withOpacity(0.2);
                    }
                    return Colors.transparent;
                  }),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.selected)) {
                      return accentColor;
                    }
                    return textColor.withOpacity(0.7);
                  }),
                ),
              ),
            ),
  
          const SizedBox(height: 32),
          
          // Timer Display
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 10 * sin(_floatingController.value * 2 * pi)),
                child: child,
              );
            },
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 320,
                  height: 320,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Focus Pulse Glow
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 260 + (20 * _pulseController.value),
                            height: 260 + (20 * _pulseController.value),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(timerService.isRunning ? 0.2 * _pulseController.value : 0.05),
                                  blurRadius: 60 + (30 * _pulseController.value),
                                  spreadRadius: 2 + (5 * _pulseController.value),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      // Glass Sphere
                      ClipOval(
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 270,
                            height: 270,
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
                      
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: CircularProgressIndicator(
                          value: timerService.isRunning ? timerService.progress : 1.0,
                          strokeWidth: 12,
                          backgroundColor: textColor.withOpacity(0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Logic (Modernized)
                        if (timerService.mode == TimerMode.pomodoro)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: timerService.currentCharacter.effectColor.withOpacity(0.15),
                                    blurRadius: 30,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  timerService.currentCharacter.icon,
                                  style: const TextStyle(fontSize: 60),
                                ),
                              ),
                            ),
                          ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.2),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            _formatTime(timerService.remainingSeconds, timerService),
                            key: ValueKey<int>(timerService.remainingSeconds),
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: -2,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        if (timerService.isRunning)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              timerService.selectedCategory.toUpperCase(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
                
                const SizedBox(height: 40),

                // Controls (only show if not running)
                  _buildCategorySelector(timerService, textColor, accentColor, backgroundColor),
                  
                  const SizedBox(height: 24),

                  // Mini To-Do List (Summary)
                  if (!timerService.isRunning && timerService.tasks.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Next Tasks",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...timerService.tasks.where((t) => !t.isCompleted).take(3).map((task) => Card( // Increased to 3 tasks
                      elevation: 0,
                      color: Colors.white.withOpacity(0.3),
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        dense: true,
                        leading: IconButton(
                          icon: Icon(Icons.circle_outlined, size: 22, color: accentColor),
                          onPressed: () => timerService.toggleTask(task.id),
                        ),
                        title: Text(
                          task.title, 
                          style: TextStyle(
                            color: textColor, 
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          )
                        ),
                        onTap: () => setState(() => _currentIndex = 2), // Still allows going to tasks tab
                      ),
                    )),
                    if (timerService.tasks.where((t) => !t.isCompleted).length > 2)
                      TextButton(
                        onPressed: () => setState(() => _currentIndex = 2),
                        child: Text("See all tasks...", style: TextStyle(color: accentColor, fontSize: 12)),
                      ),
                    const SizedBox(height: 16),
                  ],
                  
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
                          style: TextStyle(color: textColor.withOpacity(0.8)),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: accentColor,
                            inactiveTrackColor: Colors.black12,
                            thumbColor: accentColor,
                            overlayColor: accentColor.withOpacity(0.2),
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
                            },
                          ),
                        ),
                      ],
                    ),
                  ],

                const SizedBox(height: 40),

                // Action Button
                SizedBox(
                  height: 64,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (timerService.isRunning) {
                        timerService.stopTimer();
                      } else {
                         if (timerService.mode == TimerMode.basic) {
                            timerService.setDuration(_sliderValue.toInt());
                            timerService.startTimer();
                         } else {
                           if (timerService.remainingSeconds == 0) {
                              timerService.setDuration(25);
                           }
                           timerService.startTimer();
                         }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: timerService.isRunning ? const Color(0xFFC23D36) : accentColor,
                      foregroundColor: Colors.white,
                      elevation: 12,
                      shadowColor: (timerService.isRunning ? const Color(0xFFC23D36) : accentColor).withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                    child: Text(
                      timerService.isRunning ? 'GIVE UP' : 'START FOCUS',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
  
  Widget _buildPresetButton(BuildContext context, int minutes, TimerService service, Color textColor, Color accentColor) {
      final isSelected = service.remainingSeconds == minutes * 60;
      return InkWell(
        onTap: () {
          service.setDuration(minutes);
        },
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 110,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withOpacity(0.15) : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? accentColor : Colors.white.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ] : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$minutes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? accentColor : textColor,
                ),
              ),
              Text(
                'MIN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: (isSelected ? accentColor : textColor).withOpacity(0.6),
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
                color: textColor.withOpacity(0.4),
                letterSpacing: 1.2,
              ),
            ),
            IconButton(
              onPressed: () => _showEditCategoriesDialog(context, service, textColor, accentColor, backgroundColor),
              icon: Icon(Icons.settings_suggest_rounded, color: accentColor, size: 20),
              tooltip: 'Manage Categories',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 52,
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
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ] : [],
                  ),
                  child: Center(
                    child: Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : textColor.withOpacity(0.6),
                        letterSpacing: 0.8,
                      ),
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
