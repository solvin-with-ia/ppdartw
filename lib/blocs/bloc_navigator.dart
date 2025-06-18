import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../views/enum_views.dart';
import 'bloc_session.dart';

/// Bloc para manejar la navegación reactiva entre vistas principales de la app.
class BlocNavigator {
  BlocNavigator(this._blocSession) {
    // Inicializa la vista inicial según el estado de sesión.
    _blocSession.userStream.listen((UserModel? user) {
      if (user == null) {
        goTo(EnumViews.splash);
      } else {
        // Aquí puedes decidir a qué vista protegida ir por defecto
        // goTo(EnumViews.home); // Ejemplo si existiera
      }
    });
  }

  final BlocSession _blocSession;
  final BlocGeneral<EnumViews> _viewBloc = BlocGeneral<EnumViews>(
    EnumViews.splash,
  );

  /// Stream para escuchar los cambios de vista.
  Stream<EnumViews> get viewStream => _viewBloc.stream;

  /// Getter para la vista actual.
  EnumViews get currentView => _viewBloc.value;

  /// Cambia la vista actual. Puedes agregar lógica de protección aquí.
  void goTo(EnumViews view) {
    // Ejemplo de protección: si requiere sesión y no hay usuario, ir a splash
    if (_isProtected(view) && _blocSession.user == null) {
      _viewBloc.value = EnumViews.splash;
      return;
    }
    _viewBloc.value = view;
  }

  bool _isProtected(EnumViews view) {
    // Aquí defines qué vistas requieren sesión iniciada
    // Por ahora solo splash es pública
    switch (view) {
      case EnumViews.splash:
        return true;
      case EnumViews.createGame:
        return false;
      // case EnumViews.home:
      //   return true;
    }
  }

  void dispose() {
    _viewBloc.dispose();
  }
}
