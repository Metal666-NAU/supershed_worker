part of 'root.dart';

abstract class Event {
  const Event();
}

class Startup extends Event {
  const Startup();
}

class AuthReponse extends Event {
  final AuthResponse authResponse;

  const AuthReponse(this.authResponse);
}

class Message extends Event {
  final MessageReader messageReader;

  const Message(this.messageReader);
}

class ConnectionClosed extends Event {
  const ConnectionClosed();
}

class SubmitLoginCode extends Event {
  final String code;

  const SubmitLoginCode(this.code);
}

class BeginScan extends Event {
  const BeginScan();
}

class EndScan extends Event {
  const EndScan();
}

class QRCodeScanned extends Event {
  final String data;

  const QRCodeScanned(this.data);
}

class SetProductName extends Event {
  final String name;

  const SetProductName(this.name);
}

class SetProductCategory extends Event {
  final String category;

  const SetProductCategory(this.category);
}

class SetProductShelf extends Event {
  final int shelf;

  const SetProductShelf(this.shelf);
}

class SetProductSpot extends Event {
  final int spot;

  const SetProductSpot(this.spot);
}

class SetProductWidth extends Event {
  final double width;

  const SetProductWidth(this.width);
}

class SetProductLength extends Event {
  final double length;

  const SetProductLength(this.length);
}

class SetProductHeight extends Event {
  final double height;

  const SetProductHeight(this.height);
}

class UpdateProduct extends Event {
  const UpdateProduct();
}

class Rescan extends Event {
  const Rescan();
}
