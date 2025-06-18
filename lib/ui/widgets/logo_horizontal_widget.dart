import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';

class LogoHorizontalWidget extends StatelessWidget {
  const LogoHorizontalWidget({super.key, this.label = ''});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 149,
      height: 110,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 60,
            height: 60,
            child: Image.asset('assets/logo_w.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 21,
              child: InlineTextWidget(label),
            ),
          ),
        ],
      ),
    );
  }
}
