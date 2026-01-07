import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/todo_task.dart';
import 'models/app_theme.dart';
import 'models/app_character.dart';

enum TimerMode { pomodoro, basic }

class TimerService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _timer;
  Timer? _quoteTimer;
  int _remainingSeconds = 0;
  int _initialSeconds = 0;
  String _selectedCategory = 'Study';
  bool _isRunning = false;
  TimerMode _mode = TimerMode.pomodoro; // Default to Pomodoro per requirements? Or user choice. Let's say Pomodoro.
  
  // Motivational quotes
  String _currentQuote = '';
  int _currentQuoteIndex = 0;
  
  final List<String> _motivationalQuotes = [
    "Focus is the key to success. You've got this!",
    "Every minute of focus brings you closer to your goals.",
    "Discipline is choosing between what you want now and what you want most.",
    "The expert in anything was once a beginner.",
    "Progress, not perfection, is the goal.",
    "Your future self will thank you for this focused time.",
    "Small steps daily lead to big changes yearly.",
    "Concentration is the secret of strength.",
    "The way to get started is to quit talking and begin doing.",
    "Success is the sum of small efforts repeated day in and day out.",
    "Don't watch the clock; do what it does. Keep going.",
    "The only impossible journey is the one you never begin.",
    "Believe you can and you're halfway there.",
    "It always seems impossible until it's done.",
    "The future depends on what you do today.",
    "Excellence is not a skill, it's an attitude.",
    "Your limitation—it's only your imagination.",
    "Great things never come from comfort zones.",
    "Dream it. Wish it. Do it.",
    "Stay focused and never give up."
  ];

  // Categories
  List<String> _categories = ['Study', 'Work', 'Exercise', 'Reading', 'Meditation'];
  
  List<String> get categories => List.unmodifiable(_categories);

  // Themes
  String _activeThemeId = 'dusk';
  List<String> _unlockedThemeIds = ['dusk'];
  
  String get activeThemeId => _activeThemeId;
  List<String> get unlockedThemeIds => _unlockedThemeIds;
  AppTheme get currentTheme => AppTheme.allThemes.firstWhere((t) => t.id == _activeThemeId, orElse: () => AppTheme.allThemes.first);

  // Characters
  String _activeCharacterId = 'tomato';
  List<String> _unlockedCharacterIds = ['tomato'];

  String get activeCharacterId => _activeCharacterId;
  List<String> get unlockedCharacterIds => _unlockedCharacterIds;
  AppCharacter get currentCharacter => AppCharacter.allCharacters.firstWhere((c) => c.id == _activeCharacterId, orElse: () => AppCharacter.allCharacters.first);

  int _coins = 0;
  List<Map<String, dynamic>> _history = [];
  List<TodoTask> _tasks = [];
  
  int get remainingSeconds => _remainingSeconds;
  String get selectedCategory => _selectedCategory;
  bool get isRunning => _isRunning;
  TimerMode get mode => _mode;
  int get coins => _coins;
  List<Map<String, dynamic>> get history => _history;
  List<TodoTask> get tasks => _tasks;
  double get progress => _initialSeconds == 0 ? 0 : _remainingSeconds / _initialSeconds;
  String get currentQuote => _currentQuote;

  TimerService({bool skipNotifications = false}) {
    if (!skipNotifications) {
      _initNotifications();
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt('coins') ?? 0;
    
    final List<String>? historyString = prefs.getStringList('history');
    if (historyString != null) {
      _history = historyString.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    }

    final List<String>? tasksString = prefs.getStringList('tasks');
    if (tasksString != null) {
      _tasks = tasksString.map((e) => TodoTask.fromJson(jsonDecode(e))).toList();
    }

    final List<String>? categoriesList = prefs.getStringList('categories');
    if (categoriesList != null && categoriesList.isNotEmpty) {
      _categories = categoriesList;
    }

    _activeThemeId = prefs.getString('activeThemeId') ?? 'dusk';
    _unlockedThemeIds = prefs.getStringList('unlockedThemeIds') ?? ['dusk'];

    _activeCharacterId = prefs.getString('activeCharacterId') ?? 'tomato';
    _unlockedCharacterIds = prefs.getStringList('unlockedCharacterIds') ?? ['tomato'];

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', _coins);
    
    final List<String> historyString = _history.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('history', historyString);

    final List<String> tasksString = _tasks.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('tasks', tasksString);

    await prefs.setStringList('categories', _categories);
    await prefs.setString('activeThemeId', _activeThemeId);
    await prefs.setStringList('unlockedThemeIds', _unlockedThemeIds);
    await prefs.setString('activeCharacterId', _activeCharacterId);
    await prefs.setStringList('unlockedCharacterIds', _unlockedCharacterIds);
  }

  // Task Operations
  void addTask(String title) {
    final task = TodoTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );
    _tasks.add(task);
    _saveData();
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      _saveData();
      notifyListeners();
    }
  }

  void removeTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveData();
    notifyListeners();
  }

  // Category Operations
  void addCategory(String category) {
    if (category.isNotEmpty && !_categories.contains(category)) {
      _categories.add(category);
      _saveData();
      notifyListeners();
    }
  }

  void removeCategory(String category) {
    if (_categories.length > 1) { // Keep at least one category
      _categories.remove(category);
      if (_selectedCategory == category) {
        _selectedCategory = _categories.first;
      }
      _saveData();
      notifyListeners();
    }
  }

  void editCategory(String oldCategory, String newCategory) {
    int index = _categories.indexOf(oldCategory);
    if (index != -1 && newCategory.isNotEmpty && !_categories.contains(newCategory)) {
      _categories[index] = newCategory;
      if (_selectedCategory == oldCategory) {
        _selectedCategory = newCategory;
      }
      _saveData();
      notifyListeners();
    }
  }

  // Theme Operations
  void purchaseTheme(AppTheme theme) {
    if (_coins >= theme.cost && !_unlockedThemeIds.contains(theme.id)) {
      _coins -= theme.cost;
      _unlockedThemeIds.add(theme.id);
      _saveData();
      notifyListeners();
    }
  }

  void debugAddCoins() {
    _coins += 1000;
    _saveData();
    notifyListeners();
  }

  void setTheme(String themeId) {
    if (_unlockedThemeIds.contains(themeId)) {
      _activeThemeId = themeId;
      _saveData();
      notifyListeners();
    }
  }

  // Character Operations
  void purchaseCharacter(AppCharacter character) {
    if (_coins >= character.cost && !_unlockedCharacterIds.contains(character.id)) {
      _coins -= character.cost;
      _unlockedCharacterIds.add(character.id);
      _saveData();
      notifyListeners();
    }
  }

  void setCharacter(String characterId) {
    if (_unlockedCharacterIds.contains(characterId)) {
      _activeCharacterId = characterId;
      _saveData();
      notifyListeners();
    }
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // For MacOS/iOS
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setMode(TimerMode mode) {
    _mode = mode;
    _remainingSeconds = 0; // Reset timer when switching modes
    _initialSeconds = 0;
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void setDuration(int minutes) {
    _initialSeconds = minutes * 60;
    _remainingSeconds = _initialSeconds;
    notifyListeners();
  }

  void startTimer() {
    if (_remainingSeconds <= 0) return;
    
    _isRunning = true;
    
    // Set initial quote
    _setRandomQuote();
    
    // Start quote rotation timer (every 3 minutes = 180 seconds)
    _quoteTimer = Timer.periodic(const Duration(seconds: 180), (timer) {
      _setRandomQuote();
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _completeTimer();
      }
    });
    notifyListeners();
  }
  
  void _setRandomQuote() {
    _currentQuoteIndex = (_currentQuoteIndex + 1) % _motivationalQuotes.length;
    _currentQuote = _motivationalQuotes[_currentQuoteIndex];
    notifyListeners();
  }

  void stopTimer() {
    print("Stopping timer manually - resetting to initial duration.");
    _timer?.cancel();
    _quoteTimer?.cancel();
    _isRunning = false;
    
    // Reset timer to initial duration when giving up
    _remainingSeconds = _initialSeconds;
    _currentQuote = '';
    
    _showNotification("Timer Reset", "Timer has been reset. Ready to start again!");
    notifyListeners();
  }

  void _completeTimer() {
    print("Timer completed.");
    _timer?.cancel();
    _quoteTimer?.cancel();
    _isRunning = false;
    
    // Calculate Coins: 5 coins per 5 minutes completed
    int minutes = _initialSeconds ~/ 60;
    int coinsEarned = (minutes ~/ 5) * 5;
    
    // Add to History
    final session = {
      'date': DateTime.now().toIso8601String(),
      'duration': _initialSeconds, // stored in seconds
      'category': _selectedCategory,
      'coins': coinsEarned,
    };
    _history.add(session);

    if (coinsEarned > 0) {
       _coins += coinsEarned;
       _showNotification("Session Complete!", "You earned $coinsEarned coins! Total: $_coins");
    } else {
       _showNotification("Session Complete!", "You finished your $_selectedCategory session!");
    }
    
    _saveData(); // Persist changes
    
    _remainingSeconds = 0;
    _currentQuote = '';
    notifyListeners();
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'timer_channel',
      'Timer Notifications',
      channelDescription: 'Notifications for timer events',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
        await _notificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
    );
    } catch (e) {
        print("Notification error (might be web/limit): $e");
    }
    
  }

  // Stats Helpers
  Map<String, int> getDailyStats() {
    // Returns { 'Study': 1200, 'Work': 600 } in seconds, for TODAY
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _getStatsForRange(today, today.add(const Duration(days: 1)));
  }

  Map<String, int> getMonthlyStats() {
     final now = DateTime.now();
     final start = DateTime(now.year, now.month, 1);
     final end = DateTime(now.year, now.month + 1, 1);
     return _getStatsForRange(start, end);
  }

  Map<String, int> getYearlyStats() {
     final now = DateTime.now();
     final start = DateTime(now.year, 1, 1);
     final end = DateTime(now.year + 1, 1, 1);
     return _getStatsForRange(start, end);
  }

  Map<String, int> _getStatsForRange(DateTime start, DateTime end) {
    Map<String, int> stats = {};
    for (var session in _history) {
      final date = DateTime.parse(session['date']);
      if (date.isAfter(start) && date.isBefore(end)) {
        final category = session['category'] as String;
        final duration = session['duration'] as int;
        stats[category] = (stats[category] ?? 0) + duration;
      }
    }
    return stats;
  }
}
