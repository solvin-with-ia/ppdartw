import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../domains/services/service_session.dart';

/// FakeServiceSession simula autenticación controlada para desarrollo/testing.
class FakeServiceSession implements ServiceSession {
  final BlocGeneral<UserModel?> _bloc = BlocGeneral<UserModel?>(null);
  UserModel? _user;

  @override
  Stream<UserModel?> get userStream => _bloc.stream;

  @override
  UserModel? get currentUser => _user;

  @override
  Future<UserModel?> signInWithGoogle() async {
    // Simula un usuario autenticado
    _user = const UserModel(
      id: 'fake_user',
      displayName: 'Fake User',
      photoUrl: 'https://fake.com/photo.png',
      email: 'fake@fake.com',
      jwt: <String, dynamic>{},
    );
    _bloc.value = _user;
    return _user;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _bloc.value = null;
  }
}
