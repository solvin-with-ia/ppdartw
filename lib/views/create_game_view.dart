import 'package:flutter/material.dart';

import '../blocs/bloc_game.dart';
import '../domain/models/game_model.dart';
import '../shared/app_state_manager.dart';
import '../shared/device_utils.dart';
import '../ui/widgets/button_widget.dart';
import '../ui/widgets/forms/custom_input_widget.dart';
import '../ui/widgets/logo_horizontal_widget.dart';
import '../ui/widgets/projector_widget.dart';

class CreateGameView extends StatelessWidget {
  const CreateGameView({super.key});

  @override
  Widget build(BuildContext context) {
    final BlocGame blocGame = AppStateManager.of(context).blocGame;
    final bool isMobile =
        getDeviceType(MediaQuery.of(context).size.width) == DeviceType.mobile;
    return ProjectorWidget(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 32, top: 32, right: 32),
              child: LogoHorizontalWidget(label: 'Crear partida'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CustomInputWidget(
                        label: 'Nombre de la partida',
                        value: blocGame.selectedGame.name,
                        onChanged: (String value) =>
                            blocGame.updateGameName(value),
                        hintText: 'Ingresa el nombre de la partida',
                      ),
                      const SizedBox(height: 24),
                      StreamBuilder<GameModel>(
                        stream: blocGame.gameStream,
                        builder:
                            (
                              BuildContext context,
                              AsyncSnapshot<GameModel> asyncSnapshot,
                            ) {
                              return ButtonWidget(
                                label: 'Crear partida',
                                enabled: blocGame.isNameValid,
                                onTap: () {
                                  blocGame.createGame(
                                    name: blocGame.selectedGame.name,
                                  );
                                },
                              );
                            },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
