import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:wow_shopping/backend/api_service.dart';
import 'package:wow_shopping/models/user.dart';

final authRepoProvider = Provider<AuthRepo>(
  (ref) => AuthRepo._(ref),
);
final userProvider = StateProvider<User>(
  (ref) => User.none,
);

class AuthRepo {
  AuthRepo._(
    this.ref,
  );

  final Ref ref;
  late final File _file;
  Timer? _saveTimer;

  // FIXME: this should come from storage
  String get token => '123';
  User get currentUser => ref.read(userProvider);
  Future<void> create() async {
    User currentUser;
    try {
      final dir = await path_provider.getApplicationDocumentsDirectory();
      _file = File(path.join(dir.path, 'user.json'));
    } catch (error, stackTrace) {
      print('$error\n$stackTrace'); // Send to server?
      rethrow;
    }
    try {
      if (await _file.exists()) {
        currentUser = User.fromJson(
          json.decode(await _file.readAsString()),
        );
      } else {
        currentUser = User.none;
      }
    } catch (error, stackTrace) {
      print('$error\n$stackTrace'); // Send to server?
      _file.delete();
      currentUser = User.none;
    }
    ref.read(userProvider.notifier).update((state) => currentUser);
  }

  Future<void> login(String username, String password) async {
    ref
        .read(loginControllerProvider.notifier)
        .updateState(const AsyncValue.loading());
    try {
      final newUser =
          await ref.read(apiServiceProvider).login(username, password);
      ref.read(userProvider.notifier).update((state) => newUser);
      _saveUser();
    } catch (error, trace) {
      ref
          .read(loginControllerProvider.notifier)
          .updateState(AsyncValue.error(error, trace));

      // FIXME: show user error, change state? rethrow?
    }
    ref
        .read(loginControllerProvider.notifier)
        .updateState(const AsyncValue.data(null));
  }

  Future<void> logout() async {
    try {
      await ref.read(apiServiceProvider).logout();
    } catch (error) {
      // FIXME: failed to logout? report to server
    }
    ref.read(userProvider.notifier).update((state) => User.none);
    _saveUser();
  }

  void retrieveUser() {
    // currentUser = apiService.fetchUser();
    // _saveUser();
  }

  void _saveUser() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 1), () async {
      if (ref.read(userProvider) == User.none) {
        await _file.delete();
      } else {
        await _file.writeAsString(json.encode(ref.read(userProvider).toJson()));
      }
    });
  }
}

class LoginController extends StateNotifier<AsyncValue<void>> {
  LoginController() : super(const AsyncValue.data(null));
  updateState(AsyncValue newState) {
    state = newState;
  }
}

final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<void>>((ref) {
  return LoginController();
});
