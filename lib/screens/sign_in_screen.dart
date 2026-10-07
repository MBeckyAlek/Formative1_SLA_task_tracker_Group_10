import 'package:flutter/material.dart';
import '../app_router.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, Routes.home),
            child: const Text('Continue (placeholder)'),
          ),
        ),
      );
}
