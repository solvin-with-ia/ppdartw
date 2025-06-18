import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../domains/repositories/session_repository.dart';

/// BlocSession controlado por BlocModule y BlocGeneral
class BlocSession extends BlocModule {
  BlocSession(this._sessionRepository) {
    _sessionRepository.userStream.listen((
      Either<ErrorItem, UserModel?> either,
    ) {
      either.fold(
        (ErrorItem error) => _userBloc.value = null,
        (UserModel? user) => _userBloc.value = user,
      );
    });
  }
  final BlocGeneral<UserModel?> _userBloc = BlocGeneral<UserModel?>(null);
  final SessionRepository _sessionRepository;

  /// Getter para el usuario actual
  UserModel? get user => _userBloc.value;

  /// Stream del usuario para suscribirse a cambios
  Stream<UserModel?> get userStream => _userBloc.stream;

  /// Indica si la sesión está activa
  bool get isSessionActive => _userBloc.value != null;

  /// Iniciar sesión con Google
  Future<Either<ErrorItem, UserModel>> signInWithGoogle() async {
    final Either<ErrorItem, UserModel> result = await _sessionRepository
        .signInWithGoogle();
    result.fold((_) => null, (UserModel user) => _userBloc.value = user);
    return result;
  }

  /// Cerrar sesión
  void signOut() {
    _sessionRepository.signOut();

    _userBloc.value = null;
  }

  @override
  void dispose() {
    _userBloc.dispose();
  }
}
