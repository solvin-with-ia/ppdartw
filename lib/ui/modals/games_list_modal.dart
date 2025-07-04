import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';

import '../../domain/models/game_model.dart';

class GamesListModal extends StatelessWidget {
  const GamesListModal({
    required this.games,
    required this.onSelect,
    required this.onCancel,
    super.key,
  });
  final List<GameModel> games;
  final void Function(GameModel) onSelect;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Selecciona una partida',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (games.isEmpty)
              const Text(
                'No hay partidas disponibles',
                textAlign: TextAlign.center,
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: games.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int idx) {
                    final GameModel game = games[idx];
                    return ListTile(
                      title: Text(game.name),
                      subtitle: const InlineTextWidget(
                        'Admin:  0{game.admin.name}',
                      ),
                      onTap: () => onSelect(game),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            TextButton(onPressed: onCancel, child: const Text('Cancelar')),
          ],
        ),
      ),
    );
  }
}
