import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:wow_shopping/app/config.dart';
import 'package:wow_shopping/app/theme.dart';
import 'package:wow_shopping/backend/auth_repo.dart';
import 'package:wow_shopping/features/login/login_screen.dart';
import 'package:wow_shopping/features/main/main_screen.dart';
import 'package:wow_shopping/features/splash/splash_screen.dart';
import 'package:wow_shopping/models/user.dart';

import 'init_repo_provider.dart';

export 'package:wow_shopping/app/config.dart';

const _appTitle = 'Shop Wow';

class ShopWowApp extends ConsumerStatefulWidget {
  const ShopWowApp({
    super.key,
    required this.config,
  });

  final AppConfig config;

  @override
  ConsumerState<ShopWowApp> createState() => _ShopWowAppState();
}

class _ShopWowAppState extends ConsumerState<ShopWowApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Intl.defaultLocale = PlatformDispatcher.instance.locale.toLanguageTag();
  }

  @override
  Widget build(BuildContext context) {
    final initrepo = ref.watch(initRepoProvider);
    final authRepo = ref.watch(authRepoProvider);
    print(authRepo.currentUser);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: appOverlayDarkIcons,
      child: initrepo.when(
        data: (data) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: _appTitle,
          theme: generateLightTheme(),
          onGenerateRoute: (RouteSettings settings) {
            if (settings.name == Navigator.defaultRouteName) {
              if (authRepo.currentUser == User.none) {
                return LoginScreen.route();
              }
              return MainScreen.route();
            } else {
              return null; // Page not found
            }
          },
        ),
        error: (error, stl) {
          return Theme(
            data: generateLightTheme(),
            child: Directionality(
                textDirection: TextDirection.ltr,
                child: Center(child: Text('$error'))),
          );
        },
        loading: () => Theme(
          data: generateLightTheme(),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: SplashScreen(),
          ),
        ),
      ),
    );
  }
}
