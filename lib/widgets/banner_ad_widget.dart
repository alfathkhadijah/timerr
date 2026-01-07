import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final adMobService = AdMobService();
    
    if (!adMobService.isBannerAdLoaded || adMobService.bannerAd == null) {
      return const SizedBox.shrink(); // Don't show anything if ad isn't loaded
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          width: adMobService.bannerAd!.size.width.toDouble(),
          height: adMobService.bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: adMobService.bannerAd!),
        ),
      ),
    );
  }
}