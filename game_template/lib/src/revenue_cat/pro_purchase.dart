// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Represents the state of an in-app purchase of ad removal such as
/// [ProPurchase.notStarted()] or [ProPurchase.active()].
class ProPurchase {
  /// The representation of this product on the stores.
  static const productId = 'PRO';

  /// This is `true` if the `remove_ad` product has been purchased and verified.
  /// Do not show ads if so.
  final bool active;

  /// This is `true` when the purchase is pending.
  final bool pending;

  /// If there was an error with the purchase, this field will contain
  /// that error.
  final Object? error;

  const ProPurchase.active() : this._(true, false, null);

  const ProPurchase.error(Object error) : this._(false, false, error);

  const ProPurchase.notStarted() : this._(false, false, null);

  const ProPurchase.pending() : this._(false, true, null);

  const ProPurchase._(this.active, this.pending, this.error);

  @override
  int get hashCode => Object.hash(active, pending, error);

  @override
  bool operator ==(Object other) =>
      other is ProPurchase &&
      other.active == active &&
      other.pending == pending &&
      other.error == error;
}
