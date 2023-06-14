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
