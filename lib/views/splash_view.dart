import 'package:flutter/material.dart';

import '../ui/widgets/logo_vertical_widget.dart';
import '../ui/widgets/projector_widget.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProjectorWidget(child: Center(child: LogoVerticalWidget()));
  }
}
