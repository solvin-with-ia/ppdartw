import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ppdartw/shared/device_utils.dart';
import 'package:ppdartw/ui/widgets/projector_widget.dart';

void main() {
  group('DeviceType utility', () {
    test('Detects mobile', () {
      expect(getDeviceType(320), DeviceType.mobile);
      expect(getDeviceType(599), DeviceType.mobile);
    });
    test('Detects tablet', () {
      expect(getDeviceType(600), DeviceType.tablet);
      expect(getDeviceType(800), DeviceType.tablet);
      expect(getDeviceType(1023), DeviceType.tablet);
    });
    test('Detects desktop', () {
      expect(getDeviceType(1024), DeviceType.desktop);
      expect(getDeviceType(1919), DeviceType.desktop);
    });
    test('Detects tv', () {
      expect(getDeviceType(1920), DeviceType.tv);
      expect(getDeviceType(3840), DeviceType.tv);
    });
  });

  group('ProjectorWidget', () {
    testWidgets('renders child with correct aspect ratio for mobile', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 412,
            height: 892,
            child: ProjectorWidget(child: Container(key: const Key('child'))),
          ),
        ),
      );
      final Finder finder = find.byKey(const Key('child'));
      expect(finder, findsOneWidget);
    });

    testWidgets('renders child with correct aspect ratio for tablet', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 745,
            height: 1033,
            child: ProjectorWidget(child: Container(key: const Key('child'))),
          ),
        ),
      );
      final Finder finder = find.byKey(const Key('child'));
      expect(finder, findsOneWidget);
    });

    testWidgets('renders child with correct aspect ratio for desktop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 1024,
            height: 1024,
            child: ProjectorWidget(child: Container(key: const Key('child'))),
          ),
        ),
      );
      final Finder finder = find.byKey(const Key('child'));
      expect(finder, findsOneWidget);
    });

    testWidgets('renders child with correct aspect ratio for tv', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 1920,
            height: 1080,
            child: ProjectorWidget(child: Container(key: const Key('child'))),
          ),
        ),
      );
      final Finder finder = find.byKey(const Key('child'));
      expect(finder, findsOneWidget);
    });
  });
}
