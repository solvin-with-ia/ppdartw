import '../../domains/gateways/session_gateway.dart';
import '../services/fake_service_session.dart';

class FakeSessionGateway implements SessionGateway {
  final FakeServiceSession session;
  FakeSessionGateway(this.session);

  @override
  Stream<Map<String, dynamic>?> get userStream => session.userStream.map((u) => u?.toJson());

  @override
  Map<String, dynamic>? get currentUser => session.currentUser?.toJson();

  @override
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    final user = await session.signInWithGoogle();
    return user?.toJson();
  }

  @override
  Future<void> signOut() => session.signOut();
}
