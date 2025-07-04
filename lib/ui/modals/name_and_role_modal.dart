import 'package:flutter/material.dart';

import '../../blocs/bloc_game.dart';
import '../../domain/enums/role.dart';
import '../../domain/models/game_model.dart';
import '../../shared/device_utils.dart';
import '../widgets/button_widget.dart';
import '../widgets/forms/custom_input_widget.dart';

class NameAndRoleModal extends StatelessWidget {
  const NameAndRoleModal({required this.blocGame, super.key});

  final BlocGame blocGame;

  @override
  Widget build(BuildContext context) {
    final bool isMobile =
        getDeviceType(MediaQuery.of(context).size.width) == DeviceType.mobile;
    final double modalWidth = isMobile ? 340 : 480;
    final double maxModalHeight = MediaQuery.of(context).size.height * 0.9;
    return StreamBuilder<GameModel>(
      stream: blocGame.gameStream,
      builder: (_, __) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: modalWidth,
                maxHeight: maxModalHeight,
              ),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1036),
                borderRadius: BorderRadius.circular(28),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.5),
                    blurRadius: 32,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: Colors.purpleAccent.shade100,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tu nombre',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomInputWidget(
                    label: 'Tu nombre',
                    value: blocGame.selectedGame.name,
                    onChanged: blocGame.setName,
                    hintText: 'Ingresa tu nombre',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _RoleRadio(
                        label: 'Jugador',
                        value: Role.jugador,
                        groupValue: blocGame.roleDraft,
                        onChanged: blocGame.selectRoleDraft,
                      ),
                      const SizedBox(width: 32),
                      _RoleRadio(
                        label: 'Espectador',
                        value: Role.espectador,
                        groupValue: blocGame.roleDraft,
                        onChanged: blocGame.selectRoleDraft,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 180,
                    height: 44,
                    child: ButtonWidget(
                      label: 'Continuar',
                      onTap: blocGame.confirmRoleSelection,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoleRadio extends StatelessWidget {
  const _RoleRadio({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });
  final String label;
  final Role value;
  final Role? groupValue;
  final ValueChanged<Role> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(width: 8),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.purpleAccent : Colors.white54,
                width: 2,
              ),
              color: Colors.transparent,
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purpleAccent,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
