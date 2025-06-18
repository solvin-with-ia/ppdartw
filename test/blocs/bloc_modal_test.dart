import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ppdartw/blocs/bloc_modal.dart';

void main() {
  group('BlocModal', () {
    late BlocModal blocModal;
    setUp(() {
      blocModal = BlocModal();
    });
    tearDown(() {
      blocModal.dispose();
    });

    test('Inicialmente no muestra modal', () {
      expect(blocModal.isShowing, false);
    });

    test('showModal muestra el modal y isShowing es true', () {
      final Container widget = Container();
      blocModal.showModal(widget);
      expect(blocModal.isShowing, true);
    });

    test('hideModal oculta el modal y isShowing es false', () {
      final Container widget = Container();
      blocModal.showModal(widget);
      blocModal.hideModal();
      expect(blocModal.isShowing, false);
    });

    test('showModal no reemplaza modal si ya hay uno visible', () {
      final Container widget1 = Container(key: const Key('1'));
      final Container widget2 = Container(key: const Key('2'));
      blocModal.showModal(widget1);
      blocModal.showModal(widget2);
      expect(blocModal.isShowing, true);
      expect(blocModal.stream, emits(widget1));
    });
  });
}
