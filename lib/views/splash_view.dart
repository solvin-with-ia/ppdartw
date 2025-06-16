import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';

import '../shared/device_utils.dart';
import '../ui/widgets/projector_widget.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProjectorWidget(
        child: Builder(
          builder: (BuildContext context) {
            final DeviceType deviceType = getDeviceType(
              MediaQuery.of(context).size.width,
            );
            return Center(
              child: InlineTextWidget(
                'Device: ${deviceType.name.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }
}
