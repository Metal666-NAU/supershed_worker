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
  }
}
