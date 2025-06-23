import 'package:flutter/material.dart';

import '../../blocs/bloc_game.dart';

/// Widget que reacciona al stream de BlocNavigator y muestra la vista correspondiente.
import '../../blocs/bloc_loading.dart';
import '../../blocs/bloc_modal.dart';
import '../../blocs/bloc_navigator.dart';
import '../../blocs/bloc_session.dart';
import '../../shared/app_state_manager.dart';
import '../../views/central_stage_view.dart';
import '../../views/create_game_view.dart';
import '../../views/enum_views.dart';
import '../../views/splash_view.dart';
import 'backdrop_widget.dart';
import 'loading_widget.dart';

class ProjectViewsWidget extends StatelessWidget {
  const ProjectViewsWidget({
    required this.blocNavigator,
    required this.blocLoading,
    super.key,
  });
  final BlocNavigator blocNavigator;
  final BlocLoading blocLoading;

  @override
  Widget build(BuildContext context) {
    final BlocModal? blocModal = AppStateManager.of(context).blocModal;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          StreamBuilder<EnumViews>(
            stream: blocNavigator.viewStream,
            initialData: blocNavigator.currentView,
            builder: (BuildContext context, AsyncSnapshot<EnumViews> snapshot) {
              final EnumViews view = blocNavigator.currentView;
              switch (view) {
                case EnumViews.splash:
                  return const SplashView();
                case EnumViews.createGame:
                  return const CreateGameView();
                case EnumViews.centralStage:
                  // Obtén el usuario y el juego actual del AppStateManager
                  final BlocGame blocGame = AppStateManager.of(
                    context,
                  ).blocGame;
                  final BlocSession blocSession = AppStateManager.of(
                    context,
                  ).blocSession;
                  return CentralStageView(
                    blocGame: blocGame,
                    blocSession: blocSession,
                  );
              }
            },
          ),
          StreamBuilder<String>(
            stream: blocLoading.msgStream,
            initialData: blocLoading.msg,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              final String msg = snapshot.data ?? '';
              if (msg.isEmpty) {
                return const SizedBox.shrink();
              }
              return LoadingWidget(loadingMsg: msg);
            },
          ),
          if (blocModal != null)
            StreamBuilder<Widget?>(
              stream: blocModal.stream,
              builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
                final Widget? modal = snapshot.data;
                if (modal == null) {
                  return const SizedBox.shrink();
                }
                return BackdropWidget(child: modal);
              },
            ),
        ],
      ),
    );
  }
}
