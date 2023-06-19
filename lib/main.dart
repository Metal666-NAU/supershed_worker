import 'package:cv/cv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/root/root.dart' as root;
import 'data/client_repository.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/scanner.dart';
import 'pages/startup.dart';

void main() {
  cvAddConstructor(AuthRequest.new);
  cvAddConstructor(AuthResponse.new);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(final context) => materialApp(home);

  Widget materialApp(final Widget Function() home) => RepositoryProvider(
        create: (final context) => ClientRepository(),
        child: BlocProvider(
          create: (final context) =>
              root.Bloc(clientRepository: context.read<ClientRepository>())
                ..add(const root.Startup()),
          child: MaterialApp(
            darkTheme: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: ThemeMode.dark,
            home: home(),
          ),
        ),
      );

  Widget home() => Scaffold(
        body: BlocBuilder<root.Bloc, root.State>(
          buildWhen: (final previous, final current) =>
              previous.page != current.page,
          builder: (final context, final state) => switch (state.page) {
            root.Page.startup => const StartupPage(),
            root.Page.login => const LoginPage(),
            root.Page.home => const HomePage(),
            root.Page.scanner => const ScannnerPage(),
          },
        ),
      );
}
