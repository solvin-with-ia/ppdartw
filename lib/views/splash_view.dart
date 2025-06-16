import 'package:flutter/material.dart';

import '../shared/device_utils.dart';
import '../ui/widgets/logo_vertical_widget.dart';
import '../ui/widgets/projector_widget.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProjectorWidget(
        child: Builder(
          builder: (BuildContext context) {
            getDeviceType(MediaQuery.of(context).size.width);
            return const Center(child: LogoVerticalWidget());
          },
        ),
      ),
    );
  }
}
