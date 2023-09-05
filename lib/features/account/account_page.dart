import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wow_shopping/backend/auth_repo.dart';
import 'package:wow_shopping/features/login/login_screen.dart';
import 'package:wow_shopping/widgets/app_button.dart';
import 'package:wow_shopping/widgets/common.dart';

import '../../models/user.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(userProvider, (previous, next) {
      print(previous);
      print(next);

      if (next == User.none) {
        Navigator.pushAndRemoveUntil(
            context, LoginScreen.route(), (route) => false);
      }
    });
    return SizedBox.expand(
      child: Material(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Account'),
            verticalMargin48,
            verticalMargin48,
            AppButton(
              onPressed: () async => await ref.read(authRepoProvider).logout(),
              label: 'Logout',
            ),
          ],
        ),
      ),
    );
  }
}
