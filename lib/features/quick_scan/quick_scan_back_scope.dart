import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Quick-scan screens navigate between each other with `context.go`, which
/// replaces the navigation stack. Without this, the system back button would
/// pop the only remaining route and close the app. This mirrors the app-bar
/// back button: pop if possible, otherwise go to [fallbackRoute].
class QuickScanBackScope extends StatelessWidget {
  const QuickScanBackScope({
    super.key,
    required this.fallbackRoute,
    required this.child,
  });

  final String fallbackRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(fallbackRoute);
      },
      child: child,
    );
  }
}
