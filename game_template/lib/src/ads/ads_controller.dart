// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logging/logging.dart';

import 'preloaded_banner_ad.dart';

/// Allows showing ads. A facade for `package:google_mobile_ads`.
class AdsController {
  final MobileAds _instance;

  static final Logger _log = Logger('AdsController');

  PreloadedBannerAd? _preloadedAd;

  /// Creates an [AdsController] that wraps around a [MobileAds] [instance].
  ///
  /// Example usage:
  ///
  ///     var controller = AdsController(MobileAds.instance);
  AdsController(MobileAds instance) : _instance = instance;

  void dispose() {
    _preloadedAd?.dispose();
  }

  /// Initializes the injected [MobileAds.instance].
  Future<void> initialize() async {
    var status = await _instance.initialize();
    _log.info(
        "AdmobStatus: ${status.adapterStatuses.keys.map<String>((key) => "$key:${status.adapterStatuses[key]!.description}").join(", ")}");
  }

  /// Starts preloading an ad to be used later.
  ///
  /// The work doesn't start immediately so that calling this doesn't have
  /// adverse effects (jank) during start of a new screen.
  void preloadAd() {
    // TODO: When ready, change this to the Ad Unit IDs provided by AdMob.
    //       The current values are AdMob's sample IDs.
    final adUnitId = defaultTargetPlatform == TargetPlatform.android
        ? 'ca-app-pub-3940256099942544/6300978111'
        // iOS
        : 'ca-app-pub-3940256099942544/2934735716';
    _preloadedAd =
        PreloadedBannerAd(size: AdSize.mediumRectangle, adUnitId: adUnitId);

    _preloadedAd!.load();
  }

  /// Allows caller to take ownership of a [PreloadedBannerAd].
  ///
  /// If this method returns a non-null value, then the caller is responsible
  /// for disposing of the loaded ad.
  PreloadedBannerAd? takePreloadedAd() {
    final ad = _preloadedAd;
    _preloadedAd = null;
    return ad;
  }
}
