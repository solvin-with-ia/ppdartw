import 'package:flutter/material.dart';

import 'blocs/bloc_theme.dart';
import 'shared/app_state_manager.dart';
import 'shared/theme.dart';
import 'views/splash_view.dart';

void main() {
  final BlocTheme blocTheme = BlocTheme();
  runApp(AppStateManager(blocTheme: blocTheme, child: const MyApp()));
}

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
