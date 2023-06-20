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
  final bool notFound;

  const ScannedProduct(
    this.id, {
    this.info,
    this.notFound = false,
  });

  ScannedProduct copyWith({
    final ScannedProductInfo? Function()? info,
    final bool Function()? notFound,
  }) =>
      ScannedProduct(
        id,
        info: info == null ? this.info : info.call(),
        notFound: notFound == null ? this.notFound : notFound.call(),
      );
}

class ScannedProductInfo {
  final String manufacturerName;

  const ScannedProductInfo({required this.manufacturerName});
}

class ScannedShelf {
  final String id;
  final ScannedShelfInfo? info;
  final bool notFound;

  const ScannedShelf(
    this.id, {
    this.info,
    this.notFound = false,
  });

  ScannedShelf copyWith({
    final ScannedShelfInfo? Function()? info,
    final bool Function()? notFound,
  }) =>
      ScannedShelf(
        id,
        info: info == null ? this.info : info.call(),
        notFound: notFound == null ? this.notFound : notFound.call(),
      );
}

class ScannedShelfInfo {}

enum Page {
  startup,
  login,
  home,
  scanner,
}
