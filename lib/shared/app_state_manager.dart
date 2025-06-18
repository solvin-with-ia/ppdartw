import 'package:flutter/widgets.dart';
import '../blocs/bloc_theme.dart';

import '../domains/blocs/bloc_session.dart';

class AppStateManager extends InheritedWidget {
  const AppStateManager({
    required this.blocTheme,
    required this.blocSession,
    required super.child,
    super.key,
  });
  final BlocTheme blocTheme;
  final BlocSession blocSession;

  static AppStateManager of(BuildContext context) {
    final AppStateManager? result = context
        .dependOnInheritedWidgetOfExactType<AppStateManager>();
    assert(result != null, 'No AppStateManager found in context.');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
