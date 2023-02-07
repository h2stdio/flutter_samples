import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:game_template/src/revenue_cat/pro_purchase.dart';
import 'package:logging/logging.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../style/snack_bar.dart';

class RevenueCatPurchaseController extends ChangeNotifier {
  static final Logger _log = Logger('InAppPurchases');

  StreamSubscription<CustomerInfo>? _subscription;

  static bool buildingForAmazon = false;
  ProPurchase _proPurchase = const ProPurchase.notStarted();
  CustomerInfo? _customerInfo;

  RevenueCatPurchaseController();

  /// The current state of the PRO purchase.
  ProPurchase get proPurchase => _proPurchase;

  /// The current customer info.
  CustomerInfo? get customerInfo => _customerInfo;

  Future<void> init() async {
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration("public_google_sdk_key");
      if (buildingForAmazon) {
        // use your preferred way to determine if this build is for Amazon store
        // checkout our MagicWeather sample for a suggestion
        configuration = AmazonConfiguration("public_amazon_sdk_key");
      }
    } else if (Platform.isIOS) {
      configuration =
          PurchasesConfiguration("appl_HDDCuxYkRUQCefoxERRADxCWMuS");
    }
    await Purchases.configure(configuration!);
  }

  /// Subscribes to CustomerInfo changes
  void subscribe() {
    _subscription?.cancel();
    Purchases.addCustomerInfoUpdateListener(_listenToPurchaseUpdated);
  }

  Future<Offerings?> getOfferings() async {
    try {
      return Purchases.getOfferings();
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      // optional error handling
      _log.severe("Error retrieving offerings: $errorCode");
      return null;
    }
  }

  Future<void> buy(Package package) async {
    try {
      // Pending status
      _proPurchase = ProPurchase.pending();
      notifyListeners();
      // Perform purchase
      await Purchases.purchasePackage(package);
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        _proPurchase = ProPurchase.error("Error code: $errorCode");
        notifyListeners();
      } else {
        _proPurchase = ProPurchase.notStarted();
        notifyListeners();
      }
    }
  }

  Future<void> restorePurchases() async {
    _log.info("Restoring purchases...");
    try {
      // Pending status
      _proPurchase = ProPurchase.pending();
      notifyListeners();
      // Perform purchase
      await Purchases.restorePurchases();
      _log.info("Purchases restored!");
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      _log.severe("Error restoring purchases: $errorCode");
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        _proPurchase = ProPurchase.error("Error code: $errorCode");
        notifyListeners();
      } else {
        _proPurchase = ProPurchase.notStarted();
        notifyListeners();
      }
    }
  }

  Future<void> _listenToPurchaseUpdated(CustomerInfo customerInfo) async {
    _log.info(() => 'New CustomerInfo instance received: $customerInfo');
    _customerInfo = customerInfo;

    if (customerInfo.entitlements.active.containsKey(ProPurchase.productId)) {
      _log.info("PRO enabled");
      _proPurchase = const ProPurchase.active();
      _customerInfo = customerInfo;
      showSnackBar('Thank you for your support!');
    } else {
      _log.info("PRO not enabled");
      _proPurchase = const ProPurchase.notStarted();
    }
    notifyListeners();
  }
}
