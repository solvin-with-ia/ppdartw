import 'package:flutter/widgets.dart';

import '../blocs/bloc_navigator.dart';
import '../blocs/bloc_theme.dart';
import '../domains/blocs/bloc_session.dart';

class AppStateManager extends InheritedWidget {
  const AppStateManager({
    required this.blocTheme,
    required this.blocSession,
    required this.blocNavigator,
    required super.child,
    super.key,
  });
  final BlocTheme blocTheme;
  final BlocSession blocSession;
  final BlocNavigator blocNavigator;

  static AppStateManager of(BuildContext context) {
    final AppStateManager? result = context
        .dependOnInheritedWidgetOfExactType<AppStateManager>();
    assert(result != null, 'No AppStateManager found in context.');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
