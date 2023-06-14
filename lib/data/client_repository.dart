import 'dart:io';

import 'package:cv/cv_json.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ClientRepository {
  WebSocketChannel? webSocketChannel;

  List<void Function(AuthResponse authResponse)> authResponseHandlers = [];

  Future<String?> connect([
    final String serverAddress = '192.168.1.184',
    final String serverPort = '8181',
  ]) async {
    if (webSocketChannel != null) {
      return 'Already connected.';
    }
    try {
      await (webSocketChannel = WebSocketChannel.connect(
        Uri.parse('ws://$serverAddress:$serverPort'),
      ))
          .ready;

      return null;
    } catch (error) {
      return error.toString();
    }
  }

  void onAuthResponse(final void Function(AuthResponse authResponse) handler) =>
      authResponseHandlers.add(handler);

  void loginWithCredentials(final String username, final String password) =>
      webSocketChannel!.sink.add(
        (AuthRequest()
              ..username.v = username
              ..password.v = password)
            .toJson(),
      );

  void loginWithToken(final String token) => webSocketChannel!.sink.add(
        (AuthRequest()..loginToken.v = token).toJson(),
      );

  Future<dynamic> stop() async {
    if (webSocketChannel == null) {
      return;
    }

    await webSocketChannel!.sink.close(status.goingAway);
  }
}

class AuthRequest extends CvModelBase {
  final loginToken = CvField<String?>('loginToken');
  final username = CvField<String?>('username');
  final password = CvField<String?>('password');

  @override
  List<CvField> get fields => [loginToken, username, password];
}

class AuthResponse extends CvModelBase {
  final success = CvField<bool>('success');
  final loginToken = CvField<String>('loginToken');

  @override
  List<CvField> get fields => [success, loginToken];
}
