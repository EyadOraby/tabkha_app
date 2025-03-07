import 'package:flutter/material.dart';

class NavigationsServices {
  // Authentication

  static void firstRouteNavigation(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static void pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  static void pushNamed(BuildContext context, String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }
}
