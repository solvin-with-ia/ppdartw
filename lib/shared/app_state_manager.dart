import 'package:flutter/widgets.dart';

import '../blocs/bloc_game.dart';
import '../blocs/bloc_loading.dart';
import '../blocs/bloc_modal.dart';
import '../blocs/bloc_navigator.dart';
import '../blocs/bloc_session.dart';
import '../blocs/bloc_theme.dart';

class AppStateManager extends InheritedWidget {
  const AppStateManager({
    required this.blocTheme,
    required this.blocSession,
    required this.blocGame,
    required this.blocNavigator,
    required this.blocLoading,
    required super.child,
    this.blocModal,
    super.key,
  });
  final BlocModal? blocModal;
  final BlocTheme blocTheme;
  final BlocSession blocSession;
  final BlocGame blocGame;
  final BlocNavigator blocNavigator;
  final BlocLoading blocLoading;

  static AppStateManager of(BuildContext context) {
    final AppStateManager? result = context
        .dependOnInheritedWidgetOfExactType<AppStateManager>();
    assert(result != null, 'No AppStateManager found in context.');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
