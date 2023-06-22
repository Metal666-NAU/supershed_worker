import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pinput/pinput.dart';

import '../bloc/root/root.dart' as root;
import '../data/constants.dart' as constants;

class LoginPage extends HookWidget {
  const LoginPage({super.key});

  @override
  Widget build(final context) {
    final loginCodeController = useTextEditingController();

    return pageRoot(
      loginForm(
        label(context),
        loginCodeInput(context, loginCodeController),
        submitButton(context, loginCodeController),
      ),
    );
  }

  Widget pageRoot(final Widget loginForm) => Center(child: loginForm);

  Widget loginForm(
    final Widget label,
    final Widget loginCodeInput,
    final Widget submitButton,
  ) =>
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(child: SizedBox()),
            label,
            loginCodeInput,
            const Expanded(child: SizedBox()),
            Center(
              child: submitButton,
            ),
          ],
        ),
      );

  Widget label(final BuildContext context) => Text(
        'Login Code:',
        style: Theme.of(context).textTheme.headlineMedium,
      );

  Widget loginCodeInput(
    final BuildContext context,
    final TextEditingController controller,
  ) =>
      Padding(
        padding: const EdgeInsets.all(20),
        child: Pinput(
          length: constants.loginCodeLength,
          controller: controller,
          defaultPinTheme: PinTheme(
            padding: const EdgeInsets.all(15),
            textStyle: const TextStyle(fontSize: 20),
            decoration: BoxDecoration(
              color: ElevationOverlay.applySurfaceTint(
                Theme.of(context).cardColor,
                Theme.of(context).colorScheme.surfaceTint,
                5,
              ),
            ),
          ),
        ),
      );

  Widget submitButton(
    final BuildContext context,
    final TextEditingController loginCodeController,
  ) =>
      OutlinedButton(
        onPressed: () => context
            .read<root.Bloc>()
            .add(root.SubmitLoginCode(loginCodeController.text)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: const Text(
          'Submit',
          style: TextStyle(fontSize: 22),
        ),
      );
}
