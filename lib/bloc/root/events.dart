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

class Rescan extends Event {
  const Rescan();
}
