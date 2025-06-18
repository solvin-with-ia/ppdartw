import 'dart:async';

import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../domains/usecases/session/get_user_stream_usecase.dart';
import '../domains/usecases/session/sign_in_with_google_usecase.dart';
import '../domains/usecases/session/sign_out_usecase.dart';

/// Bloc para manejar la sesión del usuario.
class BlocSession {
  BlocSession({
    required this.signInWithGoogleUsecase,
    required this.signOutUsecase,
    required this.getUserStreamUsecase,
  }) {
    getUserStreamUsecase().listen((Either<ErrorItem, UserModel?> either) {
      either.fold(
        (ErrorItem error) => _userBloc.value = null,
        (UserModel? user) => _userBloc.value = user,
      );
    });
  }
  final BlocGeneral<UserModel?> _userBloc = BlocGeneral<UserModel?>(null);
  final SignInWithGoogleUsecase signInWithGoogleUsecase;
  final SignOutUsecase signOutUsecase;
  final GetUserStreamUsecase getUserStreamUsecase;

  /// Getter para el usuario actual
  UserModel? get user => _userBloc.value;

  /// Stream del usuario para suscribirse a cambios
  Stream<UserModel?> get userStream => _userBloc.stream;

  /// Indica si la sesión está activa
  bool get isSessionActive => _userBloc.value != null;

  /// Iniciar sesión con Google
  Future<Either<ErrorItem, UserModel>> signInWithGoogle() async {
    final Either<ErrorItem, UserModel> result = await signInWithGoogleUsecase();
    result.fold((_) => null, (UserModel user) => _userBloc.value = user);
    return result;
  }

  /// Cerrar sesión
  Future<Either<ErrorItem, void>> signOut() async {
    final Either<ErrorItem, void> result = await signOutUsecase();
    _userBloc.value = null;
    return result;
  }

  void dispose() {
    _userBloc.dispose();
  }
}
