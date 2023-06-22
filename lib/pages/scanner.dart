import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../bloc/root/root.dart' as root;

class ScannnerPage extends HookWidget {
  const ScannnerPage({super.key});

  @override
  Widget build(final context) {
    final nameController = useTextEditingController();
    final categoryController = useTextEditingController();

    final Size pageSize = MediaQuery.of(context).size;

    final scanRectSide = pageSize.width / 1.5;

    final Rect scanRect = Rect.fromCenter(
      center: Offset(pageSize.width / 2, pageSize.height * 0.3),
      width: scanRectSide,
      height: scanRectSide,
    );

    return pageRoot(
      scannerContainer(
        scanner(context, scanRect),
        overlay(scanRect),
        controls(
          backButton(context),
          scanWindowFrame(context, scanRect),
        ),
      ),
      productInfoPanel(
        context,
        nameController,
        categoryController,
      ),
    );
  }

  Widget pageRoot(
    final Widget scannerContainer,
    final Widget productInfoPanel,
  ) =>
      BlocBuilder<root.Bloc, root.State>(
        buildWhen: (final previous, final current) =>
            (previous.scannedProduct == null &&
                current.scannedProduct != null) ||
            (previous.scannedProduct != null && current.scannedProduct == null),
        builder: (final context, final state) => Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              top: state.scannedProduct == null ? 0 : -200,
              left: 0,
              right: 0,
              bottom: 0,
              child: scannerContainer,
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutQuart,
              top: state.scannedProduct == null
                  ? MediaQuery.of(context).size.height - 75
                  : 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: productInfoPanel,
            ),
          ],
        ),
      );

  Widget scannerContainer(
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
            fit: StackFit.passthrough,
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
  ) =>
      SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: backButton,
            ),
            scanWindowFrame,
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
        top: scanRect.top - MediaQuery.of(context).padding.top,
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

  Widget productInfoPanel(
    final BuildContext context,
    final TextEditingController nameController,
    final TextEditingController categoryController,
  ) {
    Widget propertyHeader(final String text) => Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            '$text: ',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        );

    Widget indentedBox(final String header, final Widget child) => Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                header,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontSize: 22),
              ),
              const SizedBox(height: 10),
              child,
            ],
          ),
        );

    Widget slider(
      final String header,
      final double value,
      final void Function(double value) onChanged,
    ) =>
        Row(
          children: [
            Text('$header: '),
            Text(value.toString()),
            Expanded(
              child: Slider(
                min: 0.1,
                max: 2,
                value: value,
                onChanged: onChanged,
              ),
            ),
          ],
        );

    return BlocBuilder<root.Bloc, root.State>(
      buildWhen: (final previous, final current) =>
          (previous.scannedProduct == null && current.scannedProduct != null) ||
          (previous.scannedProduct != null && current.scannedProduct == null),
      builder: (final context, final state) => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: state.scannedProduct == null
              ? const BorderRadius.vertical(
                  top: Radius.circular(20),
                )
              : null,
        ),
        child: BlocBuilder<root.Bloc, root.State>(
          buildWhen: (final previous, final current) =>
              previous.scannedProduct != current.scannedProduct,
          builder: (final context, final state) {
            if (state.scannedProduct == null) {
              return Center(
                child: Text(
                  'Please scan a product...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              );
            }

            if (state.scannedProduct!.info != null) {
              final nameSelection = nameController.selection;
              nameController.text = state.scannedProduct!.info!.name;
              nameController.selection = nameSelection;

              final categorySelection = categoryController.selection;
              categoryController.text = state.scannedProduct!.info!.category;
              categoryController.selection = categorySelection;
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Product Id: ${state.scannedProduct!.id}',
                      textAlign: TextAlign.center,
                    ),
                    if (state.scannedProduct!.info == null)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (state.scannedProduct!.info != null)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              propertyHeader('Name'),
                              TextField(
                                controller: nameController,
                                onChanged: (final value) => context
                                    .read<root.Bloc>()
                                    .add(root.SetProductName(value)),
                              ),
                              propertyHeader('Category'),
                              TextField(
                                controller: categoryController,
                                onChanged: (final value) => context
                                    .read<root.Bloc>()
                                    .add(root.SetProductCategory(value)),
                              ),
                              propertyHeader('Location'),
                              Row(
                                children: [
                                  Expanded(
                                    child: indentedBox(
                                      'Shelf',
                                      SpinBox(
                                        min: 0,
                                        max: double.infinity,
                                        value: state.scannedProduct!.info!.shelf
                                            .toDouble(),
                                        onChanged: (final value) =>
                                            context.read<root.Bloc>().add(
                                                  root.SetProductShelf(
                                                    value.toInt(),
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: indentedBox(
                                      'Spot',
                                      SpinBox(
                                        min: 1,
                                        max: double.infinity,
                                        value: state.scannedProduct!.info!.spot
                                            .toDouble(),
                                        onChanged: (final value) =>
                                            context.read<root.Bloc>().add(
                                                  root.SetProductSpot(
                                                    value.toInt(),
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              propertyHeader('Size'),
                              slider(
                                'Width',
                                state.scannedProduct!.info!.width,
                                (final value) => context
                                    .read<root.Bloc>()
                                    .add(root.SetProductWidth(value)),
                              ),
                              slider(
                                'Length',
                                state.scannedProduct!.info!.length,
                                (final value) => context
                                    .read<root.Bloc>()
                                    .add(root.SetProductLength(value)),
                              ),
                              slider(
                                'Height',
                                state.scannedProduct!.info!.height,
                                (final value) => context
                                    .read<root.Bloc>()
                                    .add(root.SetProductHeight(value)),
                              ),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () => context
                                      .read<root.Bloc>()
                                      .add(const root.UpdateProduct()),
                                  icon: const Icon(Icons.send),
                                  label: const Text('Update'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    TextButton(
                      onPressed: () =>
                          context.read<root.Bloc>().add(const root.Rescan()),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.keyboard_double_arrow_down),
                          Text('Back'),
                          Icon(Icons.keyboard_double_arrow_down),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
