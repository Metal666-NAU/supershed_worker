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

    return _pageRoot(
      _loginForm(loginCodeController),
    );
  }

  Widget _pageRoot(final Widget loginForm) => Center(child: loginForm);

  Widget _loginForm(
    final TextEditingController loginCodeController,
  ) =>
      BlocBuilder<root.Bloc, root.State>(
        builder: (final context, final state) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SafeArea(
                child: Center(
                  child: Text(
                    'Connected to ${state.serverAddress}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
              Text(
                'Login Code:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Pinput(
                  length: constants.loginCodeLength,
                  controller: loginCodeController,
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
              ),
              const Expanded(child: SizedBox()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () =>
                        context.read<root.Bloc>().add(root.ClearServer()),
                    child: Text('Change server'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context
                        .read<root.Bloc>()
                        .add(root.SubmitLoginCode(loginCodeController.text)),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
