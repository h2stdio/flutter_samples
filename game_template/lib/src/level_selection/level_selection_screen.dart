// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:game_template/src/revenue_cat/revenue_cat_purchase_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import 'levels.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();

    return Scaffold(
      backgroundColor: palette.backgroundLevelSelection,
      body: SafeArea(
        child: ResponsiveScreen(
          squarishMainArea: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Select level',
                    style:
                        TextStyle(fontFamily: 'Permanent Marker', fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Expanded(
                child: Consumer<RevenueCatPurchaseController?>(
                  builder: (context, inAppPurchase, child) {
                    var isPro = inAppPurchase?.proPurchase.active ?? false;
                    return ListView(
                      children: [
                        for (final level in gameLevels)
                          ListTile(
                            onTap: () {
                              final audioController =
                                  context.read<AudioController>();
                              if (isLevelEnabled(
                                  isPro, playerProgress, level)) {
                                audioController.playSfx(SfxType.buttonTap);
                                GoRouter.of(context)
                                    .go('/play/session/${level.number}');
                              } else {
                                audioController.playSfx(SfxType.meow);
                                GoRouter.of(context).push('/purchase');
                              }
                            },
                            leading: CircleAvatar(
                                backgroundColor:
                                    isLevelPassed(playerProgress, level)
                                        ? Colors.green
                                        : null,
                                foregroundColor: Colors.white,
                                child: !isLevelEnabled(
                                        isPro, playerProgress, level)
                                    ? Icon(Icons.lock)
                                    : (isLevelPassed(playerProgress, level)
                                        ? Icon(Icons.check)
                                        : Text(level.number.toString()))),
                            title: Text(
                              'Level #${level.number}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isLevelPassed(playerProgress, level)
                                      ? Colors.green
                                      : isLevelEnabled(
                                              isPro, playerProgress, level)
                                          ? Colors.black
                                          : Colors.grey),
                            ),
                            trailing: !isPro && level.proLevel
                                ? Badge(
                                    label: Text("PRO"),
                                    backgroundColor: palette.proColor,
                                  )
                                : null,
                          )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          rectangularMenuArea: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<PlayerProgress>().reset();
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    const SnackBar(
                        content: Text('Player progress has been reset.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: Text("Reset progress"),
              ),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).pop();
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isLevelEnabled(
      bool isPro, PlayerProgress playerProgress, GameLevel level) {
    return isPro ||
        (!isPro &&
            !level.proLevel &&
            playerProgress.highestLevelReached >= level.number - 1);
  }

  bool isLevelPassed(PlayerProgress playerProgress, GameLevel level) {
    return (playerProgress.highestLevelReached > level.number - 1);
  }
}
