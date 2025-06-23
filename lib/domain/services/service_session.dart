import 'package:jocaagura_domain/jocaagura_domain.dart';

abstract class ServiceSession {
  /// Stream reactivo del usuario autenticado actual.
  Stream<UserModel?> get userStream;

  /// Usuario autenticado actual (puede ser null si no hay sesión activa).
  UserModel? get currentUser;

  /// Inicia sesión usando Google OAuth2 (o simulado en fake).
  Future<UserModel?> signInWithGoogle();

  /// Cierra la sesión actual.
  Future<void> signOut();
}
