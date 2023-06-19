part of 'root.dart';

class State {
  final Page page;
  final ScannedProduct? scannedProduct;
  final ScannedShelf? scannedShelf;

  const State({
    this.page = Page.startup,
    this.scannedProduct,
    this.scannedShelf,
  });

  State copyWith({
    final Page Function()? page,
    final ScannedProduct? Function()? scannedProduct,
    final ScannedShelf? Function()? scannedShelf,
  }) =>
      State(
        page: page == null ? this.page : page.call(),
        scannedProduct: scannedProduct == null
            ? this.scannedProduct
            : scannedProduct.call(),
        scannedShelf:
            scannedShelf == null ? this.scannedShelf : scannedShelf.call(),
      );
}

class ScannedProduct {
  final String id;
  final ScannedProductInfo? info;

  const ScannedProduct(this.id, {this.info});
}

class ScannedProductInfo {
  final String name;

  const ScannedProductInfo(this.name);
}

class ScannedShelf {
  final String id;
  final ScannedShelfInfo? info;

  const ScannedShelf(this.id, {this.info});
}

class ScannedShelfInfo {}

enum Page {
  startup,
  login,
  home,
  scanner,
}
