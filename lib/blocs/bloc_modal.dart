import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// BlocGeneral simple que maneja un Widget? para modales/alerts.
class BlocModal {
  BlocModal();
  final BlocGeneral<Widget?> _controller = BlocGeneral<Widget?>(null);

  Stream<Widget?> get stream => _controller.stream;

  /// Indica si hay un modal visible actualmente
  bool get isShowing => _controller.value != null;

  void showModal(Widget widget) {
    if (_controller.value == null) {
      _controller.value = widget;
    }
  }

  void hideModal() {
    _controller.value = null;
  }

  void dispose() {
    _controller.close();
  }
}
