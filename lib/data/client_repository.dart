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
        Uri.parse('ws://$serverAddress:$serverPort/worker'),
      ))
          .ready;

      webSocketChannel!.stream.listen((final message) {
        if (message is String) {
          for (final authResponseHandler in authResponseHandlers) {
            authResponseHandler.call(message.cv<AuthResponse>());
          }
        }
        if (message is List<int>) {}
      });

      return null;
    } catch (error) {
      return error.toString();
    }
  }

  void onAuthResponse(final void Function(AuthResponse authResponse) handler) =>
      authResponseHandlers.add(handler);

  void loginWithCode(final String code) => webSocketChannel!.sink.add(
        (AuthRequest()..loginCode.v = code).toJson(),
      );

  void loginWithToken(final String token) => webSocketChannel!.sink.add(
        (AuthRequest()..authToken.v = token).toJson(),
      );

  Future<dynamic> stop() async {
    if (webSocketChannel == null) {
      return;
    }

    await webSocketChannel!.sink.close(status.goingAway);
  }
}

class AuthRequest extends CvModelBase {
  final loginCode = CvField<String?>('loginCode');
  final authToken = CvField<String?>('authToken');

  @override
  List<CvField> get fields => [loginCode, authToken];
}

class AuthResponse extends CvModelBase {
  final success = CvField<bool>('success');
  final authToken = CvField<String>('authToken');

  @override
  List<CvField> get fields => [success, authToken];
}
