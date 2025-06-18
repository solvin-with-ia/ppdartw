import 'package:flutter/material.dart';

import '../ui/widgets/button_widget.dart';
import '../ui/widgets/logo_horizontal_widget.dart';

class CreateGameView extends StatefulWidget {
  const CreateGameView({super.key});

  @override
  State<CreateGameView> createState() => _CreateGameViewState();
}

class _CreateGameViewState extends State<CreateGameView> {
  final TextEditingController _controller = TextEditingController();
  String _gameName = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNameValid = _gameName.trim().length >= 3;
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 32,
                top: 32,
                right: 32,
                bottom: 64,
              ),
              child: Row(
                mainAxisAlignment: isMobile
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: const <Widget>[
                  LogoHorizontalWidget(label: 'Crear partida'),
                  SizedBox(width: 16),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _controller,
                      onChanged: (String value) =>
                          setState(() => _gameName = value),
                      decoration: const InputDecoration(
                        labelText: 'Nombra la partida',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ButtonWidget(
                      label: 'Crear partida',
                      enabled: isNameValid,
                      onTap: isNameValid
                          ? () {
                              /* lógica futura */
                            }
                          : () {},
                    ),
                  ],
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
