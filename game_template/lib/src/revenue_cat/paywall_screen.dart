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

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  static const _gap = SizedBox(height: 60);

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.backgroundSettings,
      body: ResponsiveScreen(
        squarishMainArea: ListView(
          children: [
            _gap,
            const Text(
              'Become a PRO!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 55,
                height: 1,
              ),
            ),
            _gap,
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
                        return Column(
                            children: snapshot.data!.current?.availablePackages
                                    .map<Widget>((p) => ListTile(
                                          title: Text(p.storeProduct.description),
                                          subtitle: Text(
                                              "${p.packageType.name} - ${p.identifier} ${p.offeringIdentifier}"),
                                          trailing: Text(
                                            p.storeProduct.priceString,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onTap: () {
                                            inAppPurchase!.buy(p);
                                            // Pop current screen without waiting
                                            GoRouter.of(context).pop();
                                          },
                                        ))
                                    .toList() ??
                                []);
                      }
                    },
                  ),
                  _gap,
                  Text("User ID: "),
                  SelectableText(
                    "${inAppPurchase?.customerInfo?.originalAppUserId}"
                  )
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
