import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/blocs/bloc_game.dart';
import 'package:ppdartw/blocs/bloc_loading.dart';
import 'package:ppdartw/blocs/bloc_modal.dart';
import 'package:ppdartw/blocs/bloc_navigator.dart';
import 'package:ppdartw/blocs/bloc_session.dart';
import 'package:ppdartw/blocs/bloc_theme.dart';
import 'package:ppdartw/domains/models/game_model.dart';
import 'package:ppdartw/domains/repositories/game_repository.dart';
import 'package:ppdartw/domains/repositories/session_repository.dart';
import 'package:ppdartw/domains/usecases/game/create_game_usecase.dart';
import 'package:ppdartw/domains/usecases/game/get_game_stream_usecase.dart';
import 'package:ppdartw/domains/usecases/session/get_user_stream_usecase.dart';
import 'package:ppdartw/domains/usecases/session/sign_in_with_google_usecase.dart';
import 'package:ppdartw/domains/usecases/session/sign_out_usecase.dart';
import 'package:ppdartw/shared/app_state_manager.dart';

class DummyBlocSession extends BlocSession {
  DummyBlocSession()
    : super(
        signInWithGoogleUsecase: SignInWithGoogleUsecase(
          _DummySessionRepository(),
        ),
        signOutUsecase: SignOutUsecase(_DummySessionRepository()),
        getUserStreamUsecase: GetUserStreamUsecase(_DummySessionRepository()),
      );

  @override
  UserModel? get user => const UserModel(
    id: '',
    displayName: '',
    email: '',
    photoUrl: '',
    jwt: <String, dynamic>{},
  );
}

class DummyGetGameStreamUsecase implements GetGameStreamUsecase {
  const DummyGetGameStreamUsecase();
  @override
  Stream<Either<ErrorItem, GameModel?>> call(String gameId) =>
      const Stream<Either<ErrorItem, GameModel?>>.empty();
  @override
  GameRepository get repository => throw UnimplementedError();
}

class DummyBlocGame extends BlocGame {
  DummyBlocGame({
    required super.blocModal,
    required super.blocNavigator,
    required super.getGameStreamUsecase,
  }) : super(
         blocSession: DummyBlocSession(),
         createGameUsecase: DummyCreateGameUsecase(),
       );

  @override
  Future<void> init() async {
    // Evita timers y lógica asíncrona en tests
  }
}

class DummyCreateGameUsecase extends CreateGameUsecase {
  DummyCreateGameUsecase() : super(_DummyGameRepository());
  @override
  Future<Either<ErrorItem, void>> call(GameModel game) async =>
      Right<ErrorItem, void>(null);
}

class _DummyGameRepository implements GameRepository {
  @override
  Future<Either<ErrorItem, void>> saveGame(GameModel game) async =>
      Right<ErrorItem, void>(null);
  @override
  Stream<Either<ErrorItem, GameModel?>> gameStream(String gameId) =>
      const Stream<Either<ErrorItem, GameModel?>>.empty();
  @override
  Stream<Either<ErrorItem, List<GameModel>>> gamesStream() =>
      const Stream<Either<ErrorItem, List<GameModel>>>.empty();
  @override
  Future<Either<ErrorItem, GameModel>> readGame(String gameId) async =>
      Right<ErrorItem, GameModel>(GameModel.empty());
}

class DummyBlocLoading extends BlocLoading {
  @override
  String get msg => '';
  @override
  Stream<String> get msgStream => const Stream<String>.empty();
}

class _DummySessionRepository implements SessionRepository {
  @override
  Stream<Either<ErrorItem, UserModel?>> get userStream =>
      const Stream<Either<ErrorItem, UserModel?>>.empty();

  @override
  UserModel? get currentUser => null;

  @override
  Future<Either<ErrorItem, UserModel>> signInWithGoogle() async =>
      Right<ErrorItem, UserModel>(
        const UserModel(
          id: '',
          displayName: '',
          email: '',
          photoUrl: '',
          jwt: <String, dynamic>{},
        ),
      );

  @override
  Future<Either<ErrorItem, void>> signOut() async =>
      Right<ErrorItem, void>(null);
}

// Dummy widget para pruebas
class DummyChild extends StatelessWidget {
  const DummyChild({super.key});
  @override
  Widget build(BuildContext context) => Container();
}

void main() {
  testWidgets('AppStateManager expone blocTheme, blocSession y blocNavigator', (
    WidgetTester tester,
  ) async {
    final BlocTheme blocTheme = BlocTheme();
    final BlocSession blocSession = DummyBlocSession();
    final BlocNavigator blocNavigator = BlocNavigator(blocSession);
    final DummyBlocLoading blocLoading = DummyBlocLoading();
    final BlocModal blocModal = BlocModal();
    final DummyBlocGame blocGame = DummyBlocGame(
      blocModal: blocModal,
      blocNavigator: blocNavigator,
      getGameStreamUsecase: const DummyGetGameStreamUsecase(),
    );
    await tester.pumpWidget(
      AppStateManager(
        blocTheme: blocTheme,
        blocSession: blocSession,
        blocGame: blocGame,
        blocNavigator: blocNavigator,
        blocLoading: blocLoading,
        blocModal: blocModal,
        child: const DummyChild(),
      ),
    );
    final BuildContext context = tester.element(find.byType(DummyChild));
    final AppStateManager manager = AppStateManager.of(context);
    expect(manager.blocTheme, blocTheme);
    expect(manager.blocSession, blocSession);
    expect(manager.blocNavigator, blocNavigator);
  });
}
