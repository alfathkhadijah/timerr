import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Test Ad Unit IDs (replace with your real ones for production)
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // Production Ad Unit IDs (replace with your actual AdMob unit IDs)
  static const String _prodBannerAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/BANNER_AD_UNIT_ID';
  static const String _prodInterstitialAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/INTERSTITIAL_AD_UNIT_ID';
  static const String _prodRewardedAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/REWARDED_AD_UNIT_ID';

  // Ad instances
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Ad state tracking
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  // User experience tracking
  int _sessionCount = 0;
  int _completedSessions = 0;
  DateTime? _lastInterstitialShown;
  DateTime? _lastRewardedShown;

  // Getters for ad unit IDs
  String get bannerAdUnitId => kDebugMode ? _testBannerAdUnitId : _prodBannerAdUnitId;
  String get interstitialAdUnitId => kDebugMode ? _testInterstitialAdUnitId : _prodInterstitialAdUnitId;
  String get rewardedAdUnitId => kDebugMode ? _testRewardedAdUnitId : _prodRewardedAdUnitId;

  // Getters for ad state
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  BannerAd? get bannerAd => _bannerAd;

  /// Initialize AdMob SDK
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadUserStats();
    _preloadAds();
  }

  /// Load user statistics for ad frequency control
  Future<void> _loadUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionCount = prefs.getInt('ad_session_count') ?? 0;
    _completedSessions = prefs.getInt('ad_completed_sessions') ?? 0;
    
    final lastInterstitialString = prefs.getString('last_interstitial_shown');
    if (lastInterstitialString != null) {
      _lastInterstitialShown = DateTime.parse(lastInterstitialString);
    }
    
    final lastRewardedString = prefs.getString('last_rewarded_shown');
    if (lastRewardedString != null) {
      _lastRewardedShown = DateTime.parse(lastRewardedString);
    }
  }

  /// Save user statistics
  Future<void> _saveUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ad_session_count', _sessionCount);
    await prefs.setInt('ad_completed_sessions', _completedSessions);
    
    if (_lastInterstitialShown != null) {
      await prefs.setString('last_interstitial_shown', _lastInterstitialShown!.toIso8601String());
    }
    
    if (_lastRewardedShown != null) {
      await prefs.setString('last_rewarded_shown', _lastRewardedShown!.toIso8601String());
    }
  }

  /// Preload all ad types for better user experience
  void _preloadAds() {
    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd();
  }

  /// Load banner ad for shop page
  void loadBannerAd() {
    // Dispose existing banner ad if any
    _bannerAd?.dispose();
    _isBannerAdLoaded = false;
    
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          if (kDebugMode) print('Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdLoaded = false;
          ad.dispose();
          _bannerAd = null;
          if (kDebugMode) print('Banner ad failed to load: $error');
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () => loadBannerAd());
        },
        onAdOpened: (ad) {
          if (kDebugMode) print('Banner ad opened');
        },
        onAdClosed: (ad) {
          if (kDebugMode) print('Banner ad closed');
        },
      ),
    );
    _bannerAd!.load();
  }

  /// Load interstitial ad for session completion
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          if (kDebugMode) print('Interstitial ad loaded successfully');
          
          _interstitialAd!.setImmersiveMode(true);
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) print('Interstitial ad showed full screen');
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) print('Interstitial ad dismissed');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
              // Preload next interstitial
              Future.delayed(const Duration(seconds: 5), () => loadInterstitialAd());
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) print('Interstitial ad failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          if (kDebugMode) print('Interstitial ad failed to load: $error');
          // Retry after 60 seconds
          Future.delayed(const Duration(seconds: 60), () => loadInterstitialAd());
        },
      ),
    );
  }

  /// Load rewarded ad for bonus coins
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          if (kDebugMode) print('Rewarded ad loaded successfully');
          
          _rewardedAd!.setImmersiveMode(true);
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) print('Rewarded ad showed full screen');
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) print('Rewarded ad dismissed');
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdLoaded = false;
              // Preload next rewarded ad
              Future.delayed(const Duration(seconds: 5), () => loadRewardedAd());
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) print('Rewarded ad failed to show: $error');
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdLoaded = false;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          if (kDebugMode) print('Rewarded ad failed to load: $error');
          // Retry after 60 seconds
          Future.delayed(const Duration(seconds: 60), () => loadRewardedAd());
        },
      ),
    );
  }

  /// Show interstitial ad with smart frequency control
  Future<bool> showInterstitialAd() async {
    if (!_isInterstitialAdLoaded || _interstitialAd == null) {
      if (kDebugMode) print('Interstitial ad not ready');
      return false;
    }

    // Smart frequency control - don't show too often
    if (_lastInterstitialShown != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastInterstitialShown!);
      if (timeSinceLastAd.inMinutes < 10) { // Minimum 10 minutes between interstitials
        if (kDebugMode) print('Interstitial ad shown too recently');
        return false;
      }
    }

    // Only show after user has completed at least 2 sessions
    if (_completedSessions < 2) {
      if (kDebugMode) print('User needs more completed sessions before showing interstitial');
      return false;
    }

    try {
      await _interstitialAd!.show();
      _lastInterstitialShown = DateTime.now();
      await _saveUserStats();
      return true;
    } catch (e) {
      if (kDebugMode) print('Error showing interstitial ad: $e');
      return false;
    }
  }

  /// Show rewarded ad for bonus coins
  Future<bool> showRewardedAd({required Function(int coins) onRewarded}) async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      if (kDebugMode) print('Rewarded ad not ready');
      return false;
    }

    // Frequency control - allow rewarded ads more frequently than interstitials
    if (_lastRewardedShown != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastRewardedShown!);
      if (timeSinceLastAd.inMinutes < 5) { // Minimum 5 minutes between rewarded ads
        if (kDebugMode) print('Rewarded ad shown too recently');
        return false;
      }
    }

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          // Calculate bonus coins based on reward amount
          final bonusCoins = (reward.amount.toInt() * 10).clamp(10, 50); // 10-50 bonus coins
          onRewarded(bonusCoins);
          if (kDebugMode) print('User earned $bonusCoins bonus coins from rewarded ad');
        },
      );
      _lastRewardedShown = DateTime.now();
      await _saveUserStats();
      return true;
    } catch (e) {
      if (kDebugMode) print('Error showing rewarded ad: $e');
      return false;
    }
  }

  /// Track session start for ad frequency
  void trackSessionStart() {
    _sessionCount++;
    _saveUserStats();
  }

  /// Track session completion for ad eligibility
  void trackSessionCompletion() {
    _completedSessions++;
    _saveUserStats();
  }

  /// Check if user should see interstitial after session completion
  bool shouldShowInterstitialAfterSession() {
    // Show interstitial every 3rd completed session, but not too frequently
    if (_completedSessions < 2) return false;
    if (_completedSessions % 3 != 0) return false;
    
    if (_lastInterstitialShown != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastInterstitialShown!);
      if (timeSinceLastAd.inMinutes < 10) return false;
    }
    
    return _isInterstitialAdLoaded;
  }

  /// Check if user should see rewarded ad for session completion
  bool shouldShowRewardedAdForSession() {
    // Allow rewarded ads more frequently than interstitials
    if (_lastRewardedShown != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastRewardedShown!);
      if (timeSinceLastAd.inMinutes < 3) return false; // Minimum 3 minutes between session rewarded ads
    }
    
    return _isRewardedAdLoaded;
  }

  /// Show rewarded ad specifically for session completion (2x coins)
  Future<bool> showSessionRewardedAd({required Function(int coins) onRewarded}) async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      if (kDebugMode) print('Session rewarded ad not ready');
      return false;
    }

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          // For session completion, we give the original coins as bonus (doubling effect)
          // The actual doubling logic is handled in the dialog
          final bonusCoins = reward.amount.toInt();
          onRewarded(bonusCoins);
          if (kDebugMode) print('User earned session completion bonus from rewarded ad');
        },
      );
      _lastRewardedShown = DateTime.now();
      await _saveUserStats();
      return true;
    } catch (e) {
      if (kDebugMode) print('Error showing session rewarded ad: $e');
      return false;
    }
  }

  /// Dispose of all ads
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}