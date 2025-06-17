import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../domains/gateways/session_gateway.dart';
import '../../domains/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  const SessionRepositoryImpl(this.gateway);
  final SessionGateway gateway;

  @override
  Stream<Either<ErrorItem, UserModel?>> get userStream {
    return gateway.userStream.map((Map<String, dynamic>? json) {
      if (json == null) {
        return Right<ErrorItem, UserModel?>(null);
      }
      return Right<ErrorItem, UserModel?>(UserModel.fromJson(json));
    });
  }

  @override
  UserModel? get currentUser {
    final Map<String, dynamic>? json = gateway.currentUser;
    return json == null ? null : UserModel.fromJson(json);
  }

  @override
  Future<Either<ErrorItem, UserModel>> signInWithGoogle() async {
    try {
      final Map<String, dynamic>? json = await gateway.signInWithGoogle();
      if (json == null) {
        return Left<ErrorItem, UserModel>(
          const ErrorItem(
            title: 'Sign In Error',
            code: 'SIGN_IN_NULL',
            description: 'No user returned from sign in',
          ),
        );
      }
      return Right<ErrorItem, UserModel>(UserModel.fromJson(json));
    } catch (e) {
      return Left<ErrorItem, UserModel>(
        ErrorItem(
          title: 'Sign In Error',
          code: 'SIGN_IN_ERROR',
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<ErrorItem, void>> signOut() async {
    await gateway.signOut();
    return Right<ErrorItem, void>(null);
  }
}
