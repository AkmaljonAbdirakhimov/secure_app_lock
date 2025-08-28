import 'package:flutter/material.dart';

import 'secure_lock.dart';

class AppLockScreenWrapper extends StatefulWidget {
  final Widget child;

  const AppLockScreenWrapper({super.key, required this.child});

  @override
  State<AppLockScreenWrapper> createState() => _AppLockScreenWrapperState();
}

class _AppLockScreenWrapperState extends State<AppLockScreenWrapper> {
  final lockController = SecureLock.lockController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: lockController,
      builder: (context, child) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (lockController.isInLockScreen && !lockController.locked && Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }

          if (lockController.isInLockScreen &&
              lockController.locked &&
              lockController.biometricsEnabled &&
              lockController.enabled) {
            lockController.tryBiometricUnlock();
          }
        });

        return PopScope(canPop: false, child: widget.child);
      },
    );
  }
}
