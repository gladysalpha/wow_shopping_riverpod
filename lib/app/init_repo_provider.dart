import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wow_shopping/backend/auth_repo.dart';
import 'package:wow_shopping/backend/cart_repo.dart';
import 'package:wow_shopping/backend/product_repo.dart';
import 'package:wow_shopping/backend/wishlist_repo.dart';

final initRepoProvider = FutureProvider.autoDispose(
  (ref) async {
    await ref.read(productsRepoProvider).create();
    await ref.read(wishlistRepoProvider).create();
    await ref.read(cartRepoProvider).create();
    await ref.read(authRepoProvider).create();
  },
);
