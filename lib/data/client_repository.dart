import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:binary_stream/binary_stream.dart';
import 'package:json/json.dart';
import 'package:web_socket_client/web_socket_client.dart';

class ClientRepository {
  WebSocket? webSocket;

  final authResponse = StreamController<AuthResponse>.broadcast();
  // ignore: close_sinks
  final message = StreamController<MessageReader>.broadcast();
  // ignore: close_sinks
  final connectionState = StreamController<ConnectionState>.broadcast();

  void connect(final String serverAddress) {
    if (webSocket != null) {
      log('Failed to connect: already connected!');

      return;
    }

    webSocket = WebSocket(
      Uri.parse('ws://$serverAddress/worker'),
    );

    webSocket!.connection.listen((final state) => connectionState.add(state));

    webSocket!.messages.listen((final message) {
      if (message is String) {
        authResponse.add(AuthResponse.fromJson(jsonDecode(message)));
      }
      if (message is List<int>) {
        this.message.add(MessageReader(Uint8List.fromList(message)));
      }
    });
  }

  void loginWithCode(final String code) => webSocket!.send(
        jsonEncode(AuthRequest(loginCode: code).toJson()),
      );

  void loginWithToken(final String token) => webSocket!.send(
        jsonEncode(AuthRequest(authToken: token).toJson()),
      );

  void sendGetProductInfo(final String productId) => send(
        OutgoingMessages.getProductInfo,
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
        OutgoingMessages.updateProductInfo,
        (final binaryStream) => binaryStream
          ..writeString(productId)
          ..writeFloat32LE(productWidth)
          ..writeFloat32LE(productLength)
          ..writeFloat32LE(productHeight)
          ..writeString(productManufacturer)
          ..writeString(rackId)
          ..writeInt32LE(productShelf)
          ..writeInt32LE(productSpot)
          ..writeString(productCategory)
          ..writeString(productName),
      );

  void send(
    final OutgoingMessages command, [
    final void Function(BinaryStream binaryStream)? data,
  ]) {
    if (webSocket == null) {
      log('Failed to send message: not connected!');

      return;
    }

    final binaryStream = BinaryStream();

    binaryStream.writeInt8(command.index);

    data?.call(binaryStream);

    webSocket!.send(binaryStream.binary);
  }

  void stop() {
    if (webSocket == null) {
      return;
    }

    webSocket!.close(1000);

    webSocket = null;
  }
}

@JsonCodable()
class AuthRequest {
  String? loginCode;
  String? authToken;

  AuthRequest({
    this.loginCode,
    this.authToken,
  });
}

@JsonCodable()
class AuthResponse {
  bool? success;
  String? authToken;
}

class MessageReader {
  late final IncomingMessages? command;
  late final BinaryStream data;

  MessageReader(final List<int> rawData) {
    data = BinaryStream()..binary = rawData;
    command = IncomingMessages.values.elementAtOrNull(data.readUint8());
  }
}

enum IncomingMessages {
  productInfo,
}

enum OutgoingMessages {
  getProductInfo,
  updateProductInfo,
}
