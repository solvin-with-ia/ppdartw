abstract class SessionGateway {
  Stream<Map<String, dynamic>?> get userStream;
  Map<String, dynamic>? get currentUser;
  Future<Map<String, dynamic>?> signInWithGoogle();
  Future<void> signOut();
}
