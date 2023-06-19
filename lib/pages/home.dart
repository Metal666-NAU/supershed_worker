import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/root/root.dart' as root;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(final context) => pageRoot(
        actionsPanel(context),
      );

  Widget pageRoot(final Widget actionsPanel) => Center(
        child: actionsPanel,
      );

  Widget actionsPanel(final BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () =>
                context.read<root.Bloc>().add(const root.BeginScan()),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan'),
          ),
        ],
      );
}
