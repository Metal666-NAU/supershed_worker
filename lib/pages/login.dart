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
        loginCodeInput(loginCodeController),
        submitButton(context, loginCodeController),
      ),
    );
  }

  Widget pageRoot(final Widget loginForm) => Center(child: loginForm);

  Widget loginForm(
    final Widget loginCodeInput,
    final Widget submitButton,
  ) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loginCodeInput,
          submitButton,
        ],
      );

  Widget loginCodeInput(final TextEditingController controller) => Row(
        children: [
          Pinput(
            length: constants.loginCodeLength,
            controller: controller,
          ),
        ],
      );

  Widget submitButton(
    final BuildContext context,
    final TextEditingController loginCodeController,
  ) =>
      TextButton(
        onPressed: () => context
            .read<root.Bloc>()
            .add(root.SubmitLoginCode(loginCodeController.text)),
        child: const Text('Submit'),
      );
}
