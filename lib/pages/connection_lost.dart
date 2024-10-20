import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/root/root.dart' as root;

class ConnectionLostPage extends StatelessWidget {
  const ConnectionLostPage({super.key});

  @override
  Widget build(final context) => BlocBuilder<root.Bloc, root.State>(
        builder: (final context, final state) {
          final error = state.serverConnectionError;

          if (error == null) {
            return SizedBox();
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(child: SizedBox()),
                Icon(
                  Icons.warning_amber,
                  color: Colors.redAccent,
                  size: 64,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Connection failed: $error',
                    style: TextStyle(color: Colors.redAccent),
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
                      onPressed: () =>
                          context.read<root.Bloc>().add(root.Connect()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
}
