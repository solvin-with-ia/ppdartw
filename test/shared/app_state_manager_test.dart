import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/blocs/bloc_loading.dart';
import 'package:ppdartw/blocs/bloc_navigator.dart';
import 'package:ppdartw/blocs/bloc_theme.dart';
import 'package:ppdartw/domains/blocs/bloc_session.dart';
import 'package:ppdartw/domains/repositories/session_repository.dart';
import 'package:ppdartw/shared/app_state_manager.dart';

class DummyChild extends StatelessWidget {
  const DummyChild({super.key});
  @override
  Widget build(BuildContext context) => Container();
}

class DummyBlocSession extends BlocSession {
  DummyBlocSession() : super(_DummySessionRepository());
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

void main() {
  testWidgets('AppStateManager expone blocTheme, blocSession y blocNavigator', (
    WidgetTester tester,
  ) async {
    final BlocTheme blocTheme = BlocTheme();
    final BlocSession blocSession = DummyBlocSession();
    final BlocNavigator blocNavigator = BlocNavigator(blocSession);
    final DummyBlocLoading blocLoading = DummyBlocLoading();
    await tester.pumpWidget(
      AppStateManager(
        blocTheme: blocTheme,
        blocSession: blocSession,
        blocNavigator: blocNavigator,
        blocLoading: blocLoading,
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
