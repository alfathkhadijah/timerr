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
import 'services/admob_service.dart';

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
    "Stay focused and never give up.",
    "The mind is everything. What you think you become.",
    "Success is not final, failure is not fatal: it is the courage to continue that counts.",
    "The only way to do great work is to love what you do.",
    "Innovation distinguishes between a leader and a follower.",
    "Your time is limited, don't waste it living someone else's life.",
    "The best time to plant a tree was 20 years ago. The second best time is now.",
    "Don't be afraid to give up the good to go for the great.",
    "The difference between ordinary and extraordinary is that little extra.",
    "Success is walking from failure to failure with no loss of enthusiasm.",
    "The only person you are destined to become is the person you decide to be.",
    "What lies behind us and what lies before us are tiny matters compared to what lies within us.",
    "The future belongs to those who believe in the beauty of their dreams.",
    "It is during our darkest moments that we must focus to see the light.",
    "The way to get started is to quit talking and begin doing.",
    "Don't let yesterday take up too much of today.",
    "You learn more from failure than from success. Don't let it stop you. Failure builds character.",
    "If you are working on something that you really care about, you don't have to be pushed.",
    "Experience is a hard teacher because she gives the test first, the lesson afterward.",
    "To know how much there is to know is the beginning of learning to live.",
    "Focus on being productive instead of busy.",
    "The successful warrior is the average man with laser-like focus.",
    "Where focus goes, energy flows and results show.",
    "Lack of direction, not lack of time, is the problem. We all have twenty-four hour days.",
    "The art of being wise is knowing what to overlook.",
    "Concentrate all your thoughts upon the work at hand. The sun's rays do not burn until brought to a focus.",
    "It is not enough to be busy. The question is: what are we busy about?",
    "The key is not to prioritize what's on your schedule, but to schedule your priorities.",
    "You can't depend on your eyes when your imagination is out of focus.",
    "Most people have no idea of the giant capacity we can immediately command when we focus all of our resources on mastering a single area of our lives.",
    "Successful people maintain a positive focus in life no matter what is going on around them.",
    "The shorter way to do many things is to only do one thing at a time.",
    "If you want to live a happy life, tie it to a goal, not to people or things.",
    "A goal is a dream with a deadline.",
    "You are never too old to set another goal or to dream a new dream.",
    "Setting goals is the first step in turning the invisible into the visible.",
    "A goal without a plan is just a wish.",
    "The trouble with not having a goal is that you can spend your life running up and down the field and never score.",
    "Goals are dreams with deadlines.",
    "If you want to be happy, set a goal that commands your thoughts, liberates your energy, and inspires your hopes.",
    "The greater danger for most of us lies not in setting our aim too high and falling short; but in setting our aim too low, and achieving our mark.",
    "You have been designed to accomplish something special with your life.",
    "Don't wait for opportunity. Create it.",
    "The best revenge is massive success.",
    "Success is not the key to happiness. Happiness is the key to success.",
    "The only impossible journey is the one you never begin.",
    "Success is not how high you have climbed, but how you make a positive difference to the world.",
    "Don't be pushed around by the fears in your mind. Be led by the dreams in your heart.",
    "Hard work beats talent when talent doesn't work hard.",
    "The difference between a successful person and others is not a lack of strength, not a lack of knowledge, but rather a lack in will.",
    "Success is the result of preparation, hard work, and learning from failure.",
    "The road to success and the road to failure are almost exactly the same.",
    "Success is not about being the best. It's about always getting better.",
    "Don't wish it were easier; wish you were better.",
    "The elevator to success is out of order. You'll have to use the stairs... one step at a time.",
    "Success is not just about what you accomplish in your life, it's about what you inspire others to do.",
    "The price of success is hard work, dedication to the job at hand.",
    "Success is not measured by what you accomplish, but by the opposition you have encountered.",
    "I find that the harder I work, the more luck I seem to have.",
    "There are no shortcuts to any place worth going.",
    "The expert in anything was once a beginner who refused to give up.",
    "Every expert was once a beginner. Every pro was once an amateur.",
    "It's not about perfect. It's about effort.",
    "Champions don't become champions in the ring. They become champions in their training.",
    "The cave you fear to enter holds the treasure you seek.",
    "Your comfort zone is a beautiful place, but nothing ever grows there.",
    "If it doesn't challenge you, it doesn't change you.",
    "The only way to make sense out of change is to plunge into it, move with it, and join the dance.",
    "Life begins at the end of your comfort zone.",
    "You miss 100% of the shots you don't take.",
    "Whether you think you can or you think you can't, you're right.",
    "The mind is a powerful thing. When you fill it with positive thoughts, your life will start to change.",
    "Positive anything is better than negative nothing.",
    "Keep your face always toward the sunshine—and shadows will fall behind you.",
    "The only time you fail is when you fall down and stay down.",
    "Fall seven times, stand up eight.",
    "It's not whether you get knocked down; it's whether you get up.",
    "Strength doesn't come from what you can do. It comes from overcoming the things you once thought you couldn't.",
    "The comeback is always stronger than the setback.",
    "Every setback is a setup for a comeback.",
    "Turn your wounds into wisdom.",
    "The strongest people are not those who show strength in front of us, but those who win battles we know nothing about.",
    "You are braver than you believe, stronger than you seem, and smarter than you think.",
    "Difficult roads often lead to beautiful destinations.",
    "The best view comes after the hardest climb.",
    "Stars can't shine without darkness.",
    "Every moment is a fresh beginning.",
    "Today is the first day of the rest of your life.",
    "The best time to plant a tree was 20 years ago. The second best time is now.",
    "You don't have to be great to get started, but you have to get started to be great.",
    "A journey of a thousand miles begins with a single step.",
    "The secret of getting ahead is getting started."
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

  void addBonusCoins(int amount) {
    _coins += amount;
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
    
    // Track session start for ads
    AdMobService().trackSessionStart();
    
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
    
    // Track session completion for ads
    AdMobService().trackSessionCompletion();
    
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

    // Add coins to balance
    if (coinsEarned > 0) {
       _coins += coinsEarned;
    }
    
    _saveData(); // Persist changes
    
    _remainingSeconds = 0;
    _currentQuote = '';
    notifyListeners();
    
    // Show session complete dialog with rewarded ad option
    _showSessionCompleteDialog(coinsEarned, minutes);
    
    // Show interstitial ad if conditions are met (after dialog)
    _showInterstitialAdIfEligible();
  }

  void _showSessionCompleteDialog(int coinsEarned, int minutes) {
    // This will be called from the UI layer
    // We'll add a callback mechanism for this
    _sessionCompleteCallback?.call(coinsEarned, _selectedCategory, minutes);
  }

  // Callback for session completion dialog
  Function(int coinsEarned, String category, int minutes)? _sessionCompleteCallback;
  
  void setSessionCompleteCallback(Function(int coinsEarned, String category, int minutes)? callback) {
    _sessionCompleteCallback = callback;
  }

  void _showInterstitialAdIfEligible() {
    final adMobService = AdMobService();
    if (adMobService.shouldShowInterstitialAfterSession()) {
      // Delay ad show to avoid conflicting with session complete dialog
      Future.delayed(const Duration(seconds: 8), () {
        adMobService.showInterstitialAd();
      });
    }
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
