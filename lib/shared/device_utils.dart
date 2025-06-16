/// Tipos de dispositivo según el ancho de pantalla.
enum DeviceType { mobile, tablet, desktop, tv }

/// Utilidad para obtener el tipo de dispositivo según el ancho.
DeviceType getDeviceType(double width) {
  if (width >= 1920) {
    return DeviceType.tv;
  }
  if (width >= 1024) {
    return DeviceType.desktop;
  }
  if (width >= 600) {
    return DeviceType.tablet;
  }
  return DeviceType.mobile;
}

/// Tamaños de diseño recomendados por tipo de dispositivo.
class DeviceDesign {
  const DeviceDesign({required this.width, required this.height});
  final double width;
  final double height;

  static DeviceDesign forType(DeviceType type) {
    switch (type) {
      case DeviceType.mobile:
        return const DeviceDesign(width: 412, height: 892); // Figma mobile
      case DeviceType.tablet:
        return const DeviceDesign(width: 745, height: 1033); // Figma tablet
      case DeviceType.desktop:
        return const DeviceDesign(width: 1024, height: 1024); // Desktop horizontal
      case DeviceType.tv:
        return const DeviceDesign(width: 1920, height: 1080); // TV FHD
    }
  }
}
