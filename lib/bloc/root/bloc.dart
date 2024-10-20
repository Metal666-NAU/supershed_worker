part of 'root.dart';

class Bloc extends flutter_bloc.Bloc<Event, State> {
  final client_repository.ClientRepository clientRepository;

  Bloc({required this.clientRepository}) : super(const State()) {
    clientRepository.authResponse.stream.listen(
      (final client_repository.AuthResponse authResponse) =>
          add(AuthResponse(authResponse)),
    );
    clientRepository.message.stream.listen(
      (final messageReader) => add(Message(messageReader)),
    );
    clientRepository.connectionState.stream.listen(
      (final state) {
        log('Connection state changed: ${state.runtimeType}');

        switch (state) {
          case final Reconnected _:
          case final Connected _:
            {
              add(ConnectionOpened());

              break;
            }
          case final Disconnected disconnected:
            {
              add(ConnectionClosed(disconnected.reason));

              break;
            }
          case final Reconnecting _:
            {
              clientRepository.stop();

              break;
            }
        }
      },
    );

    on<Startup>((final event, final emit) async {
      await Settings.init();

      final serverAddress = Settings.serverAddress.value;

      if (serverAddress == null) {
        return;
      }

      add(Connect(serverAddress));
    });
    on<Connect>((final event, final emit) async {
      String? serverAddress = event.serverAddress;

      if (serverAddress != null) {
        await Settings.serverAddress.save(serverAddress);
      } else {
        serverAddress = state.serverAddress;

        if (serverAddress == null) {
          log('Failed to connect: serverAddress is null!');

          return;
        }
      }

      emit(
        state.copyWith(
          serverAddress: () => serverAddress,
        ),
      );

      clientRepository.connect(serverAddress);
    });
    on<ClearServer>((final event, final emit) async {
      clientRepository.stop();

      await Settings.serverAddress.save(null);
      await SecureStorage.authToken.clear();

      emit(
        state.copyWith(
          page: () => Page.startup,
          serverAddress: () => null,
        ),
      );
    });
    on<AuthResponse>((final event, final emit) async {
      if (event.authResponse.success ?? false) {
        await SecureStorage.authToken.set(event.authResponse.authToken!);

        emit(state.copyWith(page: () => Page.home));

        return;
      }

      await SecureStorage.authToken.clear();

      emit(state.copyWith(page: () => Page.login));
    });
    on<Message>((final event, final emit) {
      final BinaryStream data = event.messageReader.data;

      switch (event.messageReader.command) {
        case client_repository.IncomingMessages.productInfo:
          {
            final productWidth = data.readFloat32LE();
            final productLength = data.readFloat32LE();
            final productHeight = data.readFloat32LE();
            final productManufacturer = data.readString();
            final rackId = data.readString();
            final productShelf = data.readInt32LE();
            final productSpot = data.readInt32LE();
            final productCategory = data.readString();
            final productName = data.readString();

            emit(
              state.copyWith(
                scannedProduct: () => state.scannedProduct?.copyWith(
                  info: () => ScannedProductInfo(
                    width: roundProductSize(productWidth),
                    length: roundProductSize(productLength),
                    height: roundProductSize(productHeight),
                    manufacturer: productManufacturer,
                    rackId: rackId,
                    shelf: productShelf,
                    spot: productSpot,
                    category: productCategory,
                    name: productName,
                  ),
                ),
              ),
            );

            break;
          }
        case null:
          {
            break;
          }
      }
    });
    on<ConnectionOpened>((final event, final emit) async {
      final String? loginToken = await SecureStorage.authToken.get();

      if (loginToken == null) {
        emit(state.copyWith(page: () => Page.login));

        return;
      }

      clientRepository.loginWithToken(loginToken);
    });
    on<ConnectionClosed>(
      (final event, final emit) async {
        emit(
          state.copyWith(
            page: () =>
                event.error == null ? Page.startup : Page.connectionLost,
            serverConnectionError: () => event.error,
            scannedProduct: () => null,
          ),
        );

        clientRepository.stop();
      },
    );
    on<SubmitLoginCode>((final event, final emit) {
      clientRepository.loginWithCode(event.code);
    });
    on<BeginScan>(
      (final event, final emit) =>
          emit(state.copyWith(page: () => Page.scanner)),
    );
    on<EndScan>(
      (final event, final emit) => emit(
        state.copyWith(
          page: () => Page.home,
          scannedProduct: () => null,
        ),
      ),
    );
    on<QRCodeScanned>((final event, final emit) async {
      if (event.data == state.scannedProduct?.id) {
        return;
      }

      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate();
      }

      if (state.scannedProduct == null) {
        emit(state.copyWith(scannedProduct: () => ScannedProduct(event.data)));

        clientRepository.sendGetProductInfo(event.data);

        return;
      }
    });
    on<SetProductName>(
      (final event, final emit) => emit(
        state.copyWith(
          scannedProduct: () => state.scannedProduct?.copyWith(
            info: () =>
                state.scannedProduct?.info?.copyWith(name: () => event.name),
          ),
        ),
      ),
    );
    on<SetProductCategory>(
      (final event, final emit) => emit(
        state.copyWith(
          scannedProduct: () => state.scannedProduct?.copyWith(
            info: () => state.scannedProduct?.info
                ?.copyWith(category: () => event.category),
          ),
        ),
      ),
    );
    on<SetProductShelf>(
      (final event, final emit) => emit(
        state.copyWith(
          scannedProduct: () => state.scannedProduct?.copyWith(
            info: () =>
                state.scannedProduct?.info?.copyWith(shelf: () => event.shelf),
          ),
        ),
      ),
    );
    on<SetProductSpot>(
      (final event, final emit) => emit(
        state.copyWith(
          scannedProduct: () => state.scannedProduct?.copyWith(
            info: () =>
                state.scannedProduct?.info?.copyWith(spot: () => event.spot),
          ),
        ),
      ),
    );
    on<SetProductWidth>(
      (final event, final emit) => emit(
        state.copyWith(
          scannedProduct: () => state.scannedProduct?.copyWith(
            info: () => state.scannedProduct?.info?.copyWith(
              width: () => roundProductSize(event.width),
            ),
          ),
        ),
      ),
    );
    on<SetProductLength>(
      (final event, final emit) => emit(
        state.copyWith(
          scannedProduct: () => state.scannedProduct?.copyWith(
            info: () => state.scannedProduct?.info?.copyWith(
              length: () => roundProductSize(event.length),
            ),
          ),
        ),
      ),
    );
    on<SetProductHeight>(
      (final event, final emit) => emit(
        state.copyWith(
          scannedProduct: () => state.scannedProduct?.copyWith(
            info: () => state.scannedProduct?.info?.copyWith(
              height: () => roundProductSize(event.height),
            ),
          ),
        ),
      ),
    );
    on<UpdateProduct>(
      (final event, final emit) {
        final ScannedProductInfo info = state.scannedProduct!.info!;

        clientRepository.sendUpdateProductInfo(
          state.scannedProduct!.id,
          info.width,
          info.length,
          info.height,
          info.manufacturer,
          info.rackId,
          info.shelf,
          info.spot,
          info.category,
          info.name,
        );
      },
    );
    on<Rescan>(
      (final event, final emit) =>
          emit(state.copyWith(scannedProduct: () => null)),
    );
  }

  double roundProductSize(final double dimension) =>
      double.parse(dimension.toStringAsFixed(2));
}
