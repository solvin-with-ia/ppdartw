import 'package:flutter/material.dart';

import '../../shared/device_utils.dart';

/// Widget que proyecta el diseño en el tamaño adecuado según el dispositivo.
class ProjectorWidget extends StatelessWidget {
  const ProjectorWidget({
    required this.child,
    this.designWidth,
    this.designHeight,
    super.key,
  });

  final Widget child;
  final double? designWidth;
  final double? designHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;
        final DeviceType deviceType = getDeviceType(screenWidth);
        final DeviceDesign design = DeviceDesign.forType(deviceType);
        final double usedWidth = designWidth ?? design.width;
        final double usedHeight = designHeight ?? design.height;
        final double aspectRatio = usedWidth / usedHeight;
        double widthScale = screenWidth;
        double heightScale = widthScale / aspectRatio;
        if (heightScale > screenHeight) {
          heightScale = screenHeight;
          widthScale = heightScale * aspectRatio;
        }
        return Scaffold(
          body: Center(
            child: SizedBox(
              width: widthScale,
              height: heightScale,
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: FittedBox(
                  child: SizedBox(
                    width: usedWidth,
                    height: usedHeight,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
