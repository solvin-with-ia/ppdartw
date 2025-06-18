import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Bloc para manejar mensajes de loading global.
class BlocLoading {
  BlocLoading() : _msg = BlocGeneral<String>('');

  final BlocGeneral<String> _msg;

  /// Stream para escuchar cambios en el mensaje de loading.
  Stream<String> get msgStream => _msg.stream;

  /// Mensaje actual de loading.
  String get msg => _msg.value;

  /// Actualiza el mensaje de loading. Si es vacío, se oculta el loading.
  set msg(String value) => _msg.value = value;

  /// Limpia el mensaje de loading y dispara la lógica de cierre.
  void clearMsg() => _msg.value = '';

  /// Indica si hay loading activo.
  bool get isLoading => _msg.value.isNotEmpty;

  void dispose() => _msg.dispose();
}
