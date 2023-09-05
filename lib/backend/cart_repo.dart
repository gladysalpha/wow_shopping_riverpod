import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:wow_shopping/backend/wishlist_repo.dart';
import 'package:wow_shopping/models/cart_item.dart';
import 'package:wow_shopping/models/cart_storage.dart';
import 'package:wow_shopping/models/product_item.dart';

/// FIXME: Very similar to the [WishlistRepo] and should be refactored out and simplified

final cartRepoProvider = Provider<CartRepo>(
  (ref) => CartRepo._(ref),
);
final cartStorageProvider = StateProvider<CartStorage>(
  (ref) => const CartStorage(items: []),
);

class CartRepo {
  CartRepo._(
    this.ref,
  );

  final Ref ref;
  late final File _file;

  Timer? _saveTimer;

  Future<void> create() async {
    CartStorage cartStorage;
    try {
      final dir = await path_provider.getApplicationDocumentsDirectory();
      _file = File(path.join(dir.path, 'cart.json'));
      if (await _file.exists()) {
        cartStorage = CartStorage.fromJson(
          json.decode(await _file.readAsString()),
        );
      } else {
        cartStorage = CartStorage.empty;
      }
      ref.read(cartStorageProvider.notifier).update((state) => cartStorage);
    } catch (error, stackTrace) {
      print('$error\n$stackTrace'); // Send to server?
      rethrow;
    }
  }

  List<CartItem> get currentCartItems => ref.read(cartStorageProvider).items;

  CartItem cartItemForProduct(ProductItem item) {
    return ref
        .read(cartStorageProvider)
        .items //
        .firstWhere((el) => el.product.id == item.id,
            orElse: () => CartItem.none);
  }

  bool cartContainsProduct(ProductItem item) {
    return cartItemForProduct(item) != CartItem.none;
  }

  void addToCart(ProductItem item,
      {ProductOption option = ProductOption.none}) {
    final existingItem = cartItemForProduct(item);
    if (existingItem != CartItem.none) {
      updateQuantity(item.id, existingItem.quantity + 1);
      return;
    }
    final cartStorage = ref.read(cartStorageProvider);
    final updatedCartStorage = cartStorage.copyWith(
      items: {
        ...cartStorage.items,
        CartItem(
          product: item,
          option: option,
          deliveryFee: Decimal.zero,
          // FIXME: where from?
          deliveryDate: DateTime.now(),
          // FIXME: where from?
          quantity: 1,
        ),
      },
    );
    ref
        .read(cartStorageProvider.notifier)
        .update((state) => updatedCartStorage);
    _saveCart();
  }

  void updateQuantity(String productId, int quantity) {
    final cartStorage = ref.read(cartStorageProvider);

    final updatedCartStorage = cartStorage.copyWith(
      items: cartStorage.items.map((item) {
        if (item.product.id == productId) {
          return item.copyWith(quantity: quantity);
        } else {
          return item;
        }
      }),
    );
    ref
        .read(cartStorageProvider.notifier)
        .update((state) => updatedCartStorage);

    _saveCart();
  }

  void removeToCart(String productId) {
    final cartStorage = ref.read(cartStorageProvider);

    final updatedCartStorage = cartStorage.copyWith(
      items: cartStorage.items.where((el) => el.product.id != productId),
    );
    print(updatedCartStorage);
    ref
        .read(cartStorageProvider.notifier)
        .update((state) => updatedCartStorage);

    _saveCart();
  }

  void _saveCart() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 1), () async {
      await _file
          .writeAsString(json.encode(ref.read(cartStorageProvider).toJson()));
    });
  }
}
