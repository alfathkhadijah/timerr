import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/admob_service.dart';
import '../timer_service.dart';

class SessionCompleteDialog extends StatelessWidget {
  final int coinsEarned;
  final String category;
  final int durationMinutes;

  const SessionCompleteDialog({
    super.key,
    required this.coinsEarned,
    required this.category,
    required this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final timerService = Provider.of<TimerService>(context, listen: false);
    final theme = timerService.currentTheme;
    final adMobService = AdMobService();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.accent.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.accent.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: theme.accent,
                size: 40,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Session Complete!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: theme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Session Details
            Text(
              'Great job on your $durationMinutes-minute $category session!',
              style: TextStyle(
                fontSize: 16,
                color: theme.textColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            // Coins Earned
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    '+$coinsEarned coins earned',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.textColor.withOpacity(0.7), // Match "Focus Space" text color
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Rewarded Ad Option (if available)
            if (adMobService.isRewardedAdLoaded && coinsEarned > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.textColor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.textColor.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('🎁', style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Double Your Coins!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: theme.textColor,
                                ),
                              ),
                              Text(
                                'Watch an ad to earn ${coinsEarned * 2} coins total',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () => _watchAdForDoubleCoins(context, timerService, adMobService),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.accent.withOpacity(0.08),
                          foregroundColor: theme.accent.withOpacity(0.8),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          side: BorderSide(
                            color: theme.accent.withOpacity(0.2),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          Icons.play_arrow_rounded, 
                          size: 18,
                          color: theme.accent.withOpacity(0.7),
                        ),
                        label: Text(
                          'WATCH AD (2X COINS)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: theme.accent.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.textColor.withOpacity(0.1),
                  foregroundColor: theme.textColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  adMobService.isRewardedAdLoaded && coinsEarned > 0 ? 'CONTINUE' : 'AWESOME!',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _watchAdForDoubleCoins(BuildContext context, TimerService timerService, AdMobService adMobService) {
    adMobService.showSessionRewardedAd(
      onRewarded: (bonusCoins) {
        // Add the original coins earned as bonus (effectively doubling)
        timerService.addBonusCoins(coinsEarned);
        
        // Close the dialog
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Coins doubled! You earned ${coinsEarned * 2} coins total!',
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
            duration: const Duration(seconds: 5),
            margin: const EdgeInsets.all(16),
            elevation: 2,
          ),
        );
      },
    );
  }
}