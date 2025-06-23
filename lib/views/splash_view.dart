import 'package:flutter/material.dart';

import '../blocs/bloc_loading.dart';

import '../shared/app_state_manager.dart';
import '../ui/widgets/logo_vertical_widget.dart';
import '../ui/widgets/projector_widget.dart';


class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final BlocLoading blocLoading = AppStateManager.of(context).blocLoading;
    // Solo limpia mensajes de loading, no navega
    Future<void>.delayed(const Duration(seconds: 2), () {
      blocLoading.clearMsg();
    });
    return const ProjectorWidget(child: Center(child: LogoVerticalWidget()));
  }
}
