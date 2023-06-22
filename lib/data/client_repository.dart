import 'dart:async';
import 'dart:typed_data';

import 'package:binary_stream/binary_stream.dart';
import 'package:cv/cv_json.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ClientRepository {
  WebSocketChannel? webSocketChannel;

  final authResponse = StreamController<AuthResponse>.broadcast();
  final message = StreamController<MessageReader>.broadcast();
  final connectionClosed = StreamController<void>.broadcast();

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

      webSocketChannel!.stream.listen(
        (final message) {
          if (message is String) {
            authResponse.add(message.cv<AuthResponse>());
          }
          if (message is List<int>) {
            this.message.add(MessageReader(Uint8List.fromList(message)));
          }
        },
        onDone: () => connectionClosed.add(null),
      );

      return null;
    } catch (error) {
      return error.toString();
    }
  }

  void loginWithCode(final String code) => webSocketChannel!.sink.add(
        (AuthRequest()..loginCode.v = code).toJson(),
      );

  void loginWithToken(final String token) => webSocketChannel!.sink.add(
        (AuthRequest()..authToken.v = token).toJson(),
      );

  void sendGetProductInfo(final String productId) => send(
        OutgoingMessages.getPoductInfo,
        (final binaryStream) => binaryStream.writeString(productId),
      );

  void sendUpdateProductInfo(
    final String productId,
    final double productWidth,
    final double productLength,
    final double productHeight,
    final String productManufacturer,
    final String rackId,
    final int productShelf,
    final int productSpot,
    final String productCategory,
    final String productName,
  ) =>
      send(
        OutgoingMessages.updatePoductInfo,
        (final binaryStream) => binaryStream
          ..writeString(productId)
          ..writeFloatLE(productWidth)
          ..writeFloatLE(productLength)
          ..writeFloatLE(productHeight)
          ..writeString(productManufacturer)
          ..writeString(rackId)
          ..writeIntLE(productShelf)
          ..writeIntLE(productSpot)
          ..writeString(productCategory)
          ..writeString(productName),
      );

  void send(
    final OutgoingMessages command, [
    final void Function(BinaryStream binaryStream)? data,
  ]) {
    final binaryStream = BinaryStream();

    binaryStream.writeByte(command.index);

    data?.call(binaryStream);

    webSocketChannel!.sink.add(binaryStream.binary);
  }

  Future<dynamic> stop() async {
    if (webSocketChannel == null) {
      return;
    }

    await webSocketChannel!.sink.close(status.goingAway);

    webSocketChannel = null;
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

class MessageReader {
  late final IncomingMessages? command;
  late final BinaryStream data;

  MessageReader(final List<int> rawData) {
    data = BinaryStream()..binary = rawData;
    command = IncomingMessages.values.elementAtOrNull(data.readByte());
  }
}

enum IncomingMessages {
  productInfo,
}

enum OutgoingMessages {
  getPoductInfo,
  updatePoductInfo,
}
