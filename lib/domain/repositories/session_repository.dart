import 'package:jocaagura_domain/jocaagura_domain.dart';

abstract class SessionRepository {
  Stream<Either<ErrorItem, UserModel?>> get userStream;
  UserModel? get currentUser;
  Future<Either<ErrorItem, UserModel>> signInWithGoogle();
  Future<Either<ErrorItem, void>> signOut();
}
