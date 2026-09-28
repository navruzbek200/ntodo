import 'package:flutter/material.dart';

import 'route_names.dart';

/// Lets non-widget code (e.g. the HTTP layer) navigate.
final appNavigatorKey = GlobalKey<NavigatorState>();

void goToLoginClearingStack() {
  appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
    RouteNames.login,
    (_) => false,
  );
}
