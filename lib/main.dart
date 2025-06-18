import 'package:flutter/material.dart';

import 'blocs/bloc_theme.dart';
import 'domains/blocs/bloc_session.dart';
import 'domains/repositories/session_repository.dart';
import 'domains/services/service_session.dart';
import 'infrastructure/gateways/session_gateway_impl.dart';
import 'infrastructure/repositories/session_repository_impl.dart';
import 'infrastructure/services/fake_service_session.dart';
import 'shared/app_state_manager.dart';
import 'shared/theme.dart';
import 'views/splash_view.dart';

void main() {
  final BlocTheme blocTheme = BlocTheme();
  final ServiceSession serviceSession = FakeServiceSession();

  // Debes proveer una implementación real de SessionRepository aquí
  final SessionRepository sessionRepository = SessionRepositoryImpl(
    SessionGatewayImpl(serviceSession),
  );
  final BlocSession blocSession = BlocSession(sessionRepository);
  runApp(
    AppStateManager(
      blocTheme: blocTheme,
      blocSession: blocSession,
      child: const MyApp(),
    ),
  );
}

// Asegúrate de inicializar BlocSession correctamente en main.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: planningPokerTheme,
      home: const SplashView(),
    );
  }
}
