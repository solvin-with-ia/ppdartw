import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../shared/theme.dart';

/// BlocTheme controlado por BlocModule y BlocGeneral
class BlocTheme extends BlocModule {
  final BlocGeneral<ThemeData> _themeBloc = BlocGeneral<ThemeData>(
    planningPokerTheme,
  );

  /// Getter para el ThemeData actual
  ThemeData get themeData => _themeBloc.value;

  /// Getter para el stream de ThemeData
  Stream<ThemeData> get themeDataStream => _themeBloc.stream;

  /// Cambia el ThemeData y actualiza el stream
  void changeThemeData(ThemeData theme) {
    if (theme != _themeBloc.value) {
      _themeBloc.value = theme;
    }
  }

  @override
  void dispose() {
    _themeBloc.dispose();
  }
}
