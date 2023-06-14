part of 'root.dart';

class Bloc extends flutter_bloc.Bloc<Event, State> {
  final ClientRepository clientRepository;

  Bloc({required this.clientRepository}) : super(const State()) {
    clientRepository.onAuthResponse(
      (final AuthResponse authResponse) => add(AuthReponse(authResponse)),
    );

    on<Startup>((final event, final emit) async {
      await clientRepository.connect();

      final String? loginToken = await SecureStorage.loginToken.get();

      if (loginToken == null) {
        emit(state.copyWith(page: () => Page.login));

        return;
      }

      clientRepository.loginWithToken(loginToken);
    });
    on<AuthReponse>((final event, final emit) async {
      if (event.authResponse.success.v!) {
        await SecureStorage.loginToken.set(event.authResponse.loginToken.v!);

        emit(state.copyWith(page: () => Page.home));

        return;
      }

      await SecureStorage.loginToken.clear();

      emit(state.copyWith(page: () => Page.login));
    });
  }
}
