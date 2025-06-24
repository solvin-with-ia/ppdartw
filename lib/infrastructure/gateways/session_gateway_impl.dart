import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../domain/gateways/session_gateway.dart';
import '../../domain/services/service_session.dart';

class SessionGatewayImpl implements SessionGateway {
  SessionGatewayImpl(this.session);
  final ServiceSession session;

  @override
  Stream<Map<String, dynamic>?> get userStream =>
      session.userStream.map((UserModel? u) => u?.toJson());

  @override
  Map<String, dynamic>? get currentUser => session.currentUser?.toJson();

  @override
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    final UserModel? user = await session.signInWithGoogle();
    return user?.toJson();
  }

  @override
  Future<void> signOut() => session.signOut();
}
