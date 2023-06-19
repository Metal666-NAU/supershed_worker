import 'package:flutter/material.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(final context) => pageRoot(
        progressIndicator(),
      );

  Widget pageRoot(final Widget progressIndicator) =>
      Center(child: progressIndicator);

  Widget progressIndicator() => const CircularProgressIndicator();
}
