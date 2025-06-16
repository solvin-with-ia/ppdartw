import 'package:flutter/widgets.dart';
import '../blocs/bloc_theme.dart';

class AppStateManager extends InheritedWidget {
  const AppStateManager({
    required this.blocTheme,
    required super.child,
    super.key,
  });
  final BlocTheme blocTheme;

  static AppStateManager of(BuildContext context) {
    final AppStateManager? result = context
        .dependOnInheritedWidgetOfExactType<AppStateManager>();
    assert(result != null, 'No AppStateManager found in context.');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
