import 'package:flutter/material.dart';
import '../secure_app_lock.dart';

class AppLockLifecycleWatcher extends StatefulWidget {
  final Widget child;
  final Widget? lockScreen;
  final GlobalKey<NavigatorState> navigatorKey;

  const AppLockLifecycleWatcher({super.key, required this.child, this.lockScreen, required this.navigatorKey});

  @override
  State<AppLockLifecycleWatcher> createState() => _AppLockLifecycleWatcherState();
}

class _AppLockLifecycleWatcherState extends State<AppLockLifecycleWatcher> with WidgetsBindingObserver {
  final lockController = SecureLock.lockController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      lockController.lock();
    }

    if (state == AppLifecycleState.resumed &&
        lockController.locked &&
        lockController.enabled &&
        !lockController.isInLockScreen) {
      lockController.setisInLockScreen(true);
      Future.microtask(() async {
        if (mounted) {
          await Navigator.of(
            widget.navigatorKey.currentContext!,
          ).push(MaterialPageRoute(builder: (ctx) => AppLockScreenWrapper(child: widget.lockScreen ?? PinCodePage())));
          lockController.setisInLockScreen(false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
