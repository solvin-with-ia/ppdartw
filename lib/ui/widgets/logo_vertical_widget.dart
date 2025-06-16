import 'package:flutter/material.dart';

class LogoVerticalWidget extends StatelessWidget {
  const LogoVerticalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 149,
      height: 110,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 60,
            height: 60,
            child: Image.asset('assets/logo_w.png', fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 149,
            height: 42,
            child: Image.asset('assets/logotipo_w.png', fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}
