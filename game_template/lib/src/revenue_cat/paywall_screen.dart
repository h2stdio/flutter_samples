// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:game_template/src/revenue_cat/revenue_cat_purchase_controller.dart';
import 'package:game_template/src/style/palette.dart';
import 'package:game_template/src/style/responsive_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/models/offerings_wrapper.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  static const _gap = SizedBox(height: 20);

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.backgroundSettings,
      body: ResponsiveScreen(
        squarishMainArea: ListView(
          padding: EdgeInsets.zero,
          children: [
            Image.asset(
              "assets/images/cat.png",
              width: 100,
              height: 140,
            ),
            const Text(
              'Become a PRO!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 55,
                height: 1,
              ),
            ),
            Consumer<RevenueCatPurchaseController?>(
                builder: (context, inAppPurchase, child) {
              return Column(
                children: [
                  FutureBuilder<Offerings?>(
                    future: inAppPurchase?.getOfferings(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Column(
                          children: [
                            Text("Houston, we have a problem 😔"),
                            _gap,
                            Text("Details: ${snapshot.error}"),
                          ],
                        );
                      } else if (!snapshot.hasData) {
                        return CupertinoActivityIndicator();
                      } else {
                        // We have the offerings, let's display them in the paywall
                        return Column(children: [
                          Text(
                            "Wanna be a PRO like me? Take a look and choose the subscription that better fits your needs",
                            textAlign: TextAlign.center,
                          ),
                          _gap,
                          ...?snapshot.data!.current?.availablePackages
                              .map<Widget>((p) => GestureDetector(
                                    onTap: () {
                                      inAppPurchase!.buy(p).then((value) =>
                                          GoRouter.of(context).pop());
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: palette.trueWhite,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: p.packageType !=
                                                      PackageType.twoMonth
                                                  ? palette.proColor
                                                      .withOpacity(0.1)
                                                  : palette.proColor,
                                              width: 2)),
                                      padding: const EdgeInsets.all(8.0),
                                      margin: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          if (p.packageType ==
                                              PackageType.twoMonth)
                                            Text(
                                              "Most Popular!",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: palette.proColor,
                                                  fontSize: 20),
                                            ),
                                          Text(
                                            p.storeProduct.description,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 28),
                                            textAlign: TextAlign.center,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              inAppPurchase!.buy(p).then(
                                                  (value) =>
                                                      GoRouter.of(context)
                                                          .pop());
                                            },
                                            child: Text(
                                                "Subscribe for ${p.storeProduct.priceString}"),
                                          ),
                                          Text(
                                            "${p.packageType.name} - ${p.identifier}",
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: palette.darkPen,
                                            ),
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                          Text(
                            "${snapshot.data?.current?.identifier}",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: palette.darkPen,
                            ),
                          ),
                          _gap,
                          Text(
                            "Restore Purchases",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: palette.proColor,
                            ),
                          ),
                          _gap,
                          Text(
                            "Privacy Policy - Terms and conditions",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: palette.proColor,
                            ),
                          ),
                          _gap,
                        ]);
                      }
                    },
                  ),
                ],
              );
            }),
            _gap,
          ],
        ),
        rectangularMenuArea: ElevatedButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          child: const Text('Back'),
        ),
      ),
    );
  }
}
