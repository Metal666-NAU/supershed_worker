part of 'root.dart';

class State {
  final Page page;
  final ScannedProduct? scannedProduct;

  const State({
    this.page = Page.startup,
    this.scannedProduct,
  });

  State copyWith({
    final Page Function()? page,
    final ScannedProduct? Function()? scannedProduct,
  }) =>
      State(
        page: page == null ? this.page : page.call(),
        scannedProduct: scannedProduct == null
            ? this.scannedProduct
            : scannedProduct.call(),
      );
}

class ScannedProduct {
  final String id;
  final ScannedProductInfo? info;

  const ScannedProduct(
    this.id, {
    this.info,
  });

  ScannedProduct copyWith({
    final ScannedProductInfo? Function()? info,
  }) =>
      ScannedProduct(
        id,
        info: info == null ? this.info : info.call(),
      );
}

class ScannedProductInfo {
  final double width;
  final double length;
  final double height;
  final String manufacturer;
  final String rackId;
  final int shelf;
  final int spot;
  final String category;
  final String name;

  const ScannedProductInfo({
    required this.width,
    required this.length,
    required this.height,
    required this.manufacturer,
    required this.rackId,
    required this.shelf,
    required this.spot,
    required this.category,
    required this.name,
  });

  ScannedProductInfo copyWith({
    final double Function()? width,
    final double Function()? length,
    final double Function()? height,
    final String Function()? manufacturer,
    final String Function()? rackId,
    final int Function()? shelf,
    final int Function()? spot,
    final String Function()? category,
    final String Function()? name,
  }) =>
      ScannedProductInfo(
        width: width == null ? this.width : width.call(),
        length: length == null ? this.length : length.call(),
        height: height == null ? this.height : height.call(),
        manufacturer:
            manufacturer == null ? this.manufacturer : manufacturer.call(),
        rackId: rackId == null ? this.rackId : rackId.call(),
        shelf: shelf == null ? this.shelf : shelf.call(),
        spot: spot == null ? this.spot : spot.call(),
        category: category == null ? this.category : category.call(),
        name: name == null ? this.name : name.call(),
      );
}

enum Page {
  startup,
  login,
  home,
  scanner,
}
