import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../bloc/root/root.dart' as root;

class ScannnerPage extends StatelessWidget {
  const ScannnerPage({super.key});

  @override
  Widget build(final context) {
    final Size pageSize = MediaQuery.of(context).size;

    final scanRectSide = pageSize.width / 1.5;

    final Rect scanRect = Rect.fromCenter(
      center: Offset(pageSize.width / 2, pageSize.height * 0.3),
      width: scanRectSide,
      height: scanRectSide,
    );

    return pageRoot(
      scanner(context, scanRect),
      overlay(scanRect),
      controls(
        backButton(context),
        scanWindowFrame(context, scanRect),
        bottomPanel(context),
      ),
    );
  }

  Widget pageRoot(
    final Widget scanner,
    final Widget overlay,
    final Widget controls,
  ) =>
      Stack(
        children: [
          scanner,
          overlay,
          controls,
        ],
      );

  Widget scanner(
    final BuildContext context,
    final Rect scanRect,
  ) =>
      MobileScanner(
        scanWindow: scanRect,
        onDetect: (final BarcodeCapture capture) {
          final List<Barcode> barcodes = capture.barcodes;

          if (barcodes.isEmpty) {
            return;
          }

          final String? data = barcodes.first.rawValue;

          if (data == null) {
            return;
          }

          context.read<root.Bloc>().add(root.QRCodeScanned(data));
        },
      );

  Widget overlay(final Rect scanRect) => ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.black54,
          BlendMode.srcOut,
        ),
        child: ColoredBox(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                top: scanRect.top,
                left: scanRect.left,
                child: Container(
                  width: scanRect.width,
                  height: scanRect.height,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget controls(
    final Widget backButton,
    final Widget scanWindowFrame,
    final Widget bottomPanel,
  ) =>
      SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: backButton,
            ),
            scanWindowFrame,
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: bottomPanel,
            ),
          ],
        ),
      );

  Widget backButton(final BuildContext context) => TextButton.icon(
        onPressed: () => context.read<root.Bloc>().add(const root.EndScan()),
        icon: const Icon(Icons.arrow_circle_left_outlined),
        label: const Text('Back'),
      );

  Widget scanWindowFrame(
    final BuildContext context,
    final Rect scanRect,
  ) =>
      Positioned(
        top: scanRect.top,
        left: scanRect.left,
        child: Container(
          width: scanRect.width,
          height: scanRect.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              width: 2,
              color: Colors.white,
            ),
          ),
        )
            .animate(
          onPlay: (final controller) => controller.repeat(reverse: true),
        )
            .shimmer(
          angle: 80,
          duration: const Duration(seconds: 1),
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.primary,
          ],
        ),
      );

  Widget bottomPanel(final BuildContext context) {
    Widget infoCard(final Widget? child) => Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: child ??
                const Row(
                  children: [
                    Text('Loading information...'),
                    SizedBox(width: 15),
                    SizedBox.square(
                      dimension: 25,
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
          ),
        );

    Widget rescanButton() => TextButton(
          onPressed: () => context.read<root.Bloc>().add(const root.Rescan()),
          child: const Text('Rescan'),
        );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: BlocBuilder<root.Bloc, root.State>(
          buildWhen: (final previous, final current) =>
              previous.scannedProduct != current.scannedProduct ||
              previous.scannedShelf != current.scannedShelf,
          builder: (final context, final state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.scannedProduct != null)
                infoCard(
                  state.scannedProduct!.info == null
                      ? null
                      : Row(
                          children: [
                            Column(
                              children: [
                                const Text('Scanned product:'),
                                Text(state.scannedProduct!.info!.name),
                                Text(state.scannedProduct!.id),
                              ],
                            ),
                            if (state.scannedShelf == null) rescanButton(),
                          ],
                        ),
                ),
              if (state.scannedShelf != null)
                infoCard(
                  state.scannedShelf!.info == null
                      ? null
                      : Row(
                          children: [
                            Column(
                              children: [
                                const Text('Scanned shelf:'),
                                Text(state.scannedShelf!.id),
                              ],
                            ),
                            rescanButton(),
                          ],
                        ),
                ),
              if (state.scannedProduct == null || state.scannedShelf == null)
                Text(
                  'Please scan a ${state.scannedProduct == null ? 'product' : 'shelf'}...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              if (state.scannedProduct != null && state.scannedShelf != null)
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload),
                  label: const Text('Submit'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
