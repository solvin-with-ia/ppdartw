import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../repositories/session_repository.dart';

class SignOutUsecase {
  const SignOutUsecase(this.repository);
  final SessionRepository repository;

  Future<Either<ErrorItem, void>> call() {
    return repository.signOut();
  }
}
