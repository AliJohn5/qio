import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:qio/main.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      //adUnitId: 'ca-app-pub-2027578160537963/8726568606',
      adUnitId: 'ca-app-pub-4733483461092180/8985078150',
      request: AdRequest(),
      size: AdSize(width: size.width.toInt(), height: 100),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          if (kDebugMode) {
            print('BannerAd failed to load: $error');
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _isBannerAdLoaded ? double.infinity : 0,
      height: _isBannerAdLoaded ? 100 : 0,
      color: Colors.grey[300],
      child: Center(
        child: _isBannerAdLoaded ? AdWidget(ad: _bannerAd!) : Text(""),
      ),
    );
  }
}
