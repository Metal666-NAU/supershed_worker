part of 'root.dart';

class Bloc extends flutter_bloc.Bloc<Event, State> {
  final ClientRepository clientRepository;

  Bloc({required this.clientRepository}) : super(const State()) {
    clientRepository.onAuthResponse(
      (final AuthResponse authResponse) => add(AuthReponse(authResponse)),
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
          scannedShelf: () => null,
        ),
      ),
    );
    on<QRCodeScanned>((final event, final emit) async {
      if (event.data == state.scannedProduct?.id ||
          event.data == state.scannedShelf?.id) {
        return;
      }

      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate();
      }

      if (state.scannedProduct == null) {
        emit(state.copyWith(scannedProduct: () => ScannedProduct(event.data)));

        return;
      }

      if (state.scannedShelf == null) {
        emit(state.copyWith(scannedShelf: () => ScannedShelf(event.data)));

        return;
      }
    });
    on<Rescan>((final event, final emit) {
      if (state.scannedShelf == null) {
        emit(state.copyWith(scannedProduct: () => null));

        return;
      }

      emit(state.copyWith(scannedShelf: () => null));
    });
  }
}
