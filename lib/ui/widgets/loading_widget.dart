import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';
import 'backdrop_widget.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({required this.loadingMsg, super.key});
  final String loadingMsg;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropWidget(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            InlineTextWidget(
              loadingMsg,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
