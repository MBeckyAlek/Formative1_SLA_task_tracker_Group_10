import 'package:flutter/material.dart';
import 'screens/home_shell.dart';
import 'screens/sign_in_screen.dart';

class Routes {
  static const signIn = '/';
  static const home = '/home';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.home:
      return MaterialPageRoute(builder: (_) => const HomeShell());
    default:
      return MaterialPageRoute(builder: (_) => const SignInScreen());
  }
}
