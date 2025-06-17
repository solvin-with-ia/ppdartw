import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../repositories/session_repository.dart';

class SignInWithGoogleUsecase {
  const SignInWithGoogleUsecase(this.repository);
  final SessionRepository repository;

  Future<Either<ErrorItem, UserModel>> call() {
    return repository.signInWithGoogle();
  }
}
