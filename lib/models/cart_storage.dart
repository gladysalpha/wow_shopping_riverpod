import 'dart:collection';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wow_shopping/models/cart_item.dart';

part 'cart_storage.g.dart';

@JsonSerializable()
class CartStorage {
  const CartStorage({
    required this.items,
  });

  final List<CartItem> items;

  static const empty = CartStorage(items: []);

  CartStorage copyWith({
    Iterable<CartItem>? items,
  }) {
    return CartStorage(
      items: items != null ? UnmodifiableListView(items) : this.items,
    );
  }

  factory CartStorage.fromJson(Map json) => _$CartStorageFromJson(json);

  Map<String, dynamic> toJson() => _$CartStorageToJson(this);

  @override
  String toString() => '${describeIdentity(this)}{${toJson()}}';

  Decimal get currentCartTotal => _calculateCartTotal(items);

  Decimal _calculateCartTotal(List<CartItem> items) {
    return items.fold<Decimal>(Decimal.zero, (prev, el) => prev + el.total);
  }
}
