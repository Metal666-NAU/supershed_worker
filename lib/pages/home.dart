import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/root/root.dart' as root;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(final context) => _pageRoot(
        _actionsPanel(),
      );

  Widget _pageRoot(final Widget actionsPanel) => Center(
        child: actionsPanel,
      );

  Widget _actionsPanel() => BlocBuilder<root.Bloc, root.State>(
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
              LayoutBuilder(
                builder: (final context, final constraints) => Center(
                  child: SizedBox.square(
                    dimension: constraints.maxWidth / 1.5,
                    child: Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            context.read<root.Bloc>().add(root.BeginScan()),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              size: constraints.maxWidth / 5,
                            ),
                            Text(
                              'Scan',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
              ElevatedButton(
                onPressed: () =>
                    context.read<root.Bloc>().add(root.ClearServer()),
                child: Text('Change server'),
              ),
            ],
          ),
        ),
      );
}
