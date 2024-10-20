import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../bloc/root/root.dart' as root;

class StartupPage extends HookWidget {
  const StartupPage({super.key});

  @override
  Widget build(final context) {
    final serverAddressController = useTextEditingController();

    return _pageRoot(serverAddressController);
  }

  Widget _pageRoot(final TextEditingController serverAddressController) =>
      BlocBuilder<root.Bloc, root.State>(
        buildWhen: (final previous, final current) =>
            previous.serverAddress != current.serverAddress,
        builder: (final context, final state) {
          final serverAddress = state.serverAddress;

          serverAddressController.text = serverAddress ?? '';

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(child: SizedBox()),
                Text(
                  'Server Address:',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'ws://',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: serverAddressController,
                            decoration: InputDecoration.collapsed(
                              hintText: '192.168.1.xxx:8181',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
                if (serverAddress == null)
                  FilledButton.tonal(
                    onPressed: () => context
                        .read<root.Bloc>()
                        .add(root.Connect(serverAddressController.text)),
                    child: Text('Connect'),
                  )
                else
                  FilledButton.icon(
                    onPressed: () =>
                        context.read<root.Bloc>().add(root.ClearServer()),
                    icon: SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).cardColor,
                      ),
                    ),
                    label: Text('Cancel connection'),
                  ),
              ],
            ),
          );
        },
      );
}
