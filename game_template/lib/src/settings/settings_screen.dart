// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:game_template/src/audio/audio_controller.dart';
import 'package:game_template/src/audio/sounds.dart';
import 'package:game_template/src/revenue_cat/revenue_cat_purchase_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import 'custom_name_dialog.dart';
import 'settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _gap = SizedBox(height: 60);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final palette = context.watch<Palette>();
    final audioController = context.watch<AudioController>();

    return Scaffold(
      backgroundColor: palette.backgroundSettings,
      body: ResponsiveScreen(
        squarishMainArea: ListView(
          children: [
            _gap,
            const Text(
              'Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 45,
                height: 1,
              ),
            ),
            const _NameChangeLine(
              'Name',
            ),
            ValueListenableBuilder<bool>(
              valueListenable: settings.soundsOn,
              builder: (context, soundsOn, child) => _SettingsLine(
                'Sound FX',
                Icon(soundsOn ? Icons.graphic_eq : Icons.volume_off),
                onSelected: () => settings.toggleSoundsOn(),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: settings.musicOn,
              builder: (context, musicOn, child) => _SettingsLine(
                'Music',
                Icon(musicOn ? Icons.music_note : Icons.music_off),
                onSelected: () => settings.toggleMusicOn(),
              ),
            ),
            Consumer<RevenueCatPurchaseController?>(
                builder: (context, inAppPurchase, child) {
              if (inAppPurchase == null) {
                // In-app purchases are not supported yet.
                // Go to lib/main.dart and uncomment the lines that create
                // the InAppPurchaseController.
                return const SizedBox.shrink();
              }

              Widget icon;
              VoidCallback? callback;
              if (inAppPurchase.proPurchase.active) {
                icon = const Icon(Icons.check);
              } else if (inAppPurchase.proPurchase.pending) {
                icon = const CircularProgressIndicator();
              } else {
                icon = Icon(
                  Icons.star,
                  color: palette.proColor,
                );
                callback = () {


                  audioController.playSfx(SfxType.meow);

                  GoRouter.of(context).push('/purchase');
                };
              }
              return _SettingsLine(
                inAppPurchase.proPurchase.active
                    ? "You're a PRO"
                    : 'Become a PRO',
                icon,
                onSelected: callback,
                color: palette.proColor,
              );
            }),

            /// Restore purchases
            Consumer<RevenueCatPurchaseController?>(
                builder: (context, inAppPurchase, child) {
              if (inAppPurchase != null && inAppPurchase.proPurchase.active) {
                // In-app purchases are not supported yet.
                // Go to lib/main.dart and uncomment the lines that create
                // the InAppPurchaseController.
                return const SizedBox.shrink();
              } else {
                return _SettingsLine(
                  "Restore purchases",
                  Icon(Icons.restart_alt),
                  onSelected: () {
                    inAppPurchase!.restorePurchases();
                  },
                );
              }
            }),
            _gap,
            _SettingsLine(
              'Reset progress',
              const Icon(Icons.delete),
              onSelected: () {
                context.read<PlayerProgress>().reset();

                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(
                  const SnackBar(
                      content: Text('Player progress has been reset.')),
                );
              },
            ),
            _gap,
            Consumer<RevenueCatPurchaseController?>(
                builder: (context, inAppPurchase, child) {
              return Column(
                children: [
                  Text("User ID: "),
                  SelectableText(
                    "${inAppPurchase?.customerInfo?.originalAppUserId}",
                    textAlign: TextAlign.center,
                  )
                ],
              );
            }),
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

class _NameChangeLine extends StatelessWidget {
  final String title;

  const _NameChangeLine(this.title);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return InkResponse(
      highlightShape: BoxShape.rectangle,
      onTap: () => showCustomNameDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                  fontFamily: 'Permanent Marker',
                  fontSize: 30,
                )),
            const Spacer(),
            ValueListenableBuilder(
              valueListenable: settings.playerName,
              builder: (context, name, child) => Text(
                '‘$name’',
                style: const TextStyle(
                  fontFamily: 'Permanent Marker',
                  fontSize: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsLine extends StatelessWidget {
  final String title;
  final Widget icon;
  final Color? color;

  final VoidCallback? onSelected;

  const _SettingsLine(this.title, this.icon, {this.onSelected, this.color});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      onTap: onSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(
                    fontFamily: 'Permanent Marker',
                    fontSize: 30,
                    color: color)),
            const Spacer(),
            icon,
          ],
        ),
      ),
    );
  }
}
