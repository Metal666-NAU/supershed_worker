part of 'root.dart';

class Bloc extends flutter_bloc.Bloc<Event, State> {
  final ClientRepository clientRepository;

  Bloc({required this.clientRepository}) : super(const State()) {
    clientRepository.authResponse.stream.listen(
      (final AuthResponse authResponse) => add(AuthReponse(authResponse)),
    );
    clientRepository.message.stream.listen(
      (final messageReader) => add(Message(messageReader)),
    );
    clientRepository.connectionClosed.stream.listen(
      (final _) => add(const ConnectionClosed()),
    );

    on<Startup>((final event, final emit) async {
      final String? error = await clientRepository.connect();

      if (error != null) {
        log('Failed to connect: $error');

        // TODO: show error message

        return;
      }

      final String? loginToken = await SecureStorage.authToken.get();

      if (loginToken == null) {
        emit(state.copyWith(page: () => Page.login));

        return;
      }

      clientRepository.loginWithToken(loginToken);
    });
    on<AuthReponse>((final event, final emit) async {
      if (event.authResponse.success.v!) {
        await SecureStorage.authToken.set(event.authResponse.authToken.v!);

        emit(state.copyWith(page: () => Page.home));

        return;
      }

      await SecureStorage.authToken.clear();

      emit(state.copyWith(page: () => Page.login));
    });
    on<Message>((final event, final emit) {
      final BinaryStream data = event.messageReader.data;

      switch (event.messageReader.command) {
        case IncomingMessages.productInfo:
          {
            final productWidth = data.readFloatLE();
            final productLength = data.readFloatLE();
            final productHeight = data.readFloatLE();
            final productManufacturer = data.readString();
            final rackId = data.readString();
            final productShelf = data.readIntLE();
            final productSpot = data.readIntLE();
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
    on<ConnectionClosed>(
      (final event, final emit) async {
        emit(
          state.copyWith(
            page: () => Page.startup,
            scannedProduct: () => null,
          ),
        );

        await clientRepository.stop();

        add(const Startup());
      },
    );
    on<SubmitLoginCode>((final event, final emit) {
      clientRepository.loginWithCode(event.code);

      emit(state.copyWith(page: () => Page.startup));
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
