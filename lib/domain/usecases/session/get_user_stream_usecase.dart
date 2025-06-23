import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../repositories/session_repository.dart';

class GetUserStreamUsecase {
  const GetUserStreamUsecase(this.repository);
  final SessionRepository repository;

  Stream<Either<ErrorItem, UserModel?>> call() {
    return repository.userStream;
  }
}
