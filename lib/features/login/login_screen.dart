import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wow_shopping/backend/auth_repo.dart';
import 'package:wow_shopping/features/main/main_screen.dart';
import 'package:wow_shopping/models/user.dart';
import 'package:wow_shopping/widgets/app_button.dart';
import 'package:wow_shopping/widgets/common.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen._();

  static Route<void> route() {
    return PageRouteBuilder(
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return FadeTransition(
          opacity: animation,
          child: const LoginScreen._(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(userProvider, (previous, next) {
      print(previous);
      print(next);
      if (previous == null) {
        return;
      }
      if (previous == User.none && next != User.none) {
        Navigator.pushAndRemoveUntil(
            context, MainScreen.route(), (route) => false);
      }
    });
    final loginState = ref.watch(loginControllerProvider);
    return Material(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              onPressed: loginState.isLoading
                  ? null
                  : () async {
                      await ref.read(authRepoProvider).login(
                            'username',
                            'password',
                          );
                    },
              label: 'Login',
            ),
            verticalMargin16,
            if (loginState.isLoading) //
              const CircularProgressIndicator(),
            if (loginState.hasError) //
              Text(loginState.error.toString()),
          ],
        ),
      ),
    );
  }
}
