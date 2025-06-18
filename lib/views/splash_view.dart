import 'package:flutter/material.dart';

import '../blocs/bloc_loading.dart';
import '../blocs/bloc_navigator.dart';
import '../shared/app_state_manager.dart';
import '../ui/widgets/logo_vertical_widget.dart';
import '../ui/widgets/projector_widget.dart';
import 'enum_views.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final BlocLoading blocLoading = AppStateManager.of(context).blocLoading;
    Future<void>.delayed(const Duration(seconds: 2), () {
      blocLoading.clearMsg();
      // Simula login exitoso y navega a CreateGameView
      if (context.mounted) {
        final BlocNavigator blocNavigator = AppStateManager.of(
          context,
        ).blocNavigator;
        blocNavigator.goTo(EnumViews.createGame);
      }
    });
    return const ProjectorWidget(child: Center(child: LogoVerticalWidget()));
  }
}
