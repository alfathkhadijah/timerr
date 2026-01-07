import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/admob_service.dart';
import '../timer_service.dart';

class RewardedAdWidget extends StatelessWidget {
  const RewardedAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final timerService = Provider.of<TimerService>(context);
    final theme = timerService.currentTheme;
    final adMobService = AdMobService();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.textColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.textColor.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.textColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🎁', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonus Coins',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: theme.textColor.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      'Watch an ad to earn 10-50 bonus coins',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: adMobService.isRewardedAdLoaded
                  ? () => _showRewardedAd(context, timerService, adMobService)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: adMobService.isRewardedAdLoaded 
                  ? theme.accent.withOpacity(0.08)
                  : theme.textColor.withOpacity(0.05),
                foregroundColor: adMobService.isRewardedAdLoaded 
                  ? theme.accent.withOpacity(0.8)
                  : theme.textColor.withOpacity(0.4),
                elevation: 0,
                side: BorderSide(
                  color: adMobService.isRewardedAdLoaded 
                    ? theme.accent.withOpacity(0.2)
                    : theme.textColor.withOpacity(0.1),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                adMobService.isRewardedAdLoaded ? Icons.play_arrow_rounded : Icons.hourglass_empty_rounded,
                size: 18,
                color: adMobService.isRewardedAdLoaded 
                  ? theme.accent.withOpacity(0.7)
                  : theme.textColor.withOpacity(0.4),
              ),
              label: Text(
                adMobService.isRewardedAdLoaded ? 'WATCH AD' : 'LOADING...',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: adMobService.isRewardedAdLoaded 
                    ? theme.accent.withOpacity(0.8)
                    : theme.textColor.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRewardedAd(BuildContext context, TimerService timerService, AdMobService adMobService) {
    adMobService.showRewardedAd(
      onRewarded: (bonusCoins) {
        // Add bonus coins to user's balance
        timerService.addBonusCoins(bonusCoins);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You earned $bonusCoins bonus coins!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
                color: Colors.white.withOpacity(0.95),
                fontSize: 15,
              ),
            ),
            backgroundColor: const Color(0xFF6B8E6B), // Muted sage green
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(16),
            elevation: 2,
          ),
        );
      },
    );
  }
}