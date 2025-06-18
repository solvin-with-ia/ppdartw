import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ppdartw/blocs/bloc_loading.dart';

void main() {
  group('BlocLoading', () {
    late BlocLoading blocLoading;
    setUp(() {
      blocLoading = BlocLoading();
    });

    tearDown(() {
      blocLoading.dispose();
    });

    test('Inicialmente no está cargando', () {
      expect(blocLoading.isLoading, isFalse);
      expect(blocLoading.msg, '');
    });

    test('msg setter activa el loading y actualiza el mensaje', () async {
      blocLoading.msg = 'Cargando...';
      expect(blocLoading.isLoading, isTrue);
      expect(blocLoading.msg, 'Cargando...');
      // Stream emite el mensaje
      await expectLater(
        blocLoading.msgStream,
        emitsInOrder(<dynamic>['Cargando...']),
      );
    });

    test('clearMsg limpia el mensaje y desactiva el loading', () async {
      blocLoading.msg = 'Procesando';
      final List<String> emitted = <String>[];
      final StreamSubscription<String> sub = blocLoading.msgStream.listen(
        emitted.add,
      );
      blocLoading.clearMsg();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(blocLoading.isLoading, isFalse);
      expect(blocLoading.msg, '');
      expect(emitted.last, '');
      await sub.cancel();
    });

    test('dispose cierra el stream sin errores', () {
      expect(() => blocLoading.dispose(), returnsNormally);
    });
  });
}
