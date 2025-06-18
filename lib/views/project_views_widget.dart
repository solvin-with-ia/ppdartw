import 'package:flutter/material.dart';
import '../blocs/bloc_navigator.dart';
import 'enum_views.dart';
import 'splash_view.dart';
// Importa aquí las demás vistas a medida que las agregues

/// Widget que reacciona al stream de BlocNavigator y muestra la vista correspondiente.
class ProjectViewsWidget extends StatelessWidget {
  const ProjectViewsWidget({required this.blocNavigator, super.key});
  final BlocNavigator blocNavigator;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EnumViews>(
      stream: blocNavigator.viewStream,
      initialData: blocNavigator.currentView,
      builder: (BuildContext context, AsyncSnapshot<EnumViews> snapshot) {
        final EnumViews view = blocNavigator.currentView;
        switch (view) {
          case EnumViews.splash:
            return const SplashView();
        }
      },
    );
  }
}
