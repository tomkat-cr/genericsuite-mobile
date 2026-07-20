import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/genericsuite.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaultThemeParams carries the Apple-clean design tokens', () {
    expect(defaultThemeParams['accentColor'], Colors.green);
    expect(defaultThemeParams['borderRadius'], 12.0);
    expect(defaultThemeParams['fontFamily'], 'Inter');
    expect(defaultThemeParams['textTheme'], isNull);
    expect(defaultThemeParams['textColor'], const Color(0xFF111111));
    expect(defaultThemeParams['scaffoldBackgroundColor'], Colors.white);
    expect(defaultThemeParams['appBarBackgroundColor'], Colors.white);
    // iOS system semantic colors
    expect(defaultThemeParams['errorBackgroundColor'], const Color(0xFFFF3B30));
    expect(defaultThemeParams['infoBackgroundColor'], const Color(0xFF007AFF));
    expect(
      defaultThemeParams['warningBackgroundColor'],
      const Color(0xFFFF9500),
    );
    expect(
      defaultThemeParams['successBackgroundColor'],
      const Color(0xFF34C759),
    );
    expect(defaultThemeParams['closeButtonPlacement'], 'bottom');
  });

  test('getThemeParams() returns the defaults and keeps the legacy keys', () {
    final params = AppCallablesSuper().getThemeParams();
    for (final key in defaultThemeParams.keys) {
      expect(params.containsKey(key), true, reason: 'missing key: $key');
    }
    // Legacy keys still present for existing consumer apps
    expect(params.containsKey('primarySwatch'), true);
    expect(params.containsKey('drawerBackgroundColor'), true);
  });

  test('buildGsMaterialTheme(defaultThemeParams) reflects the accent/radius '
      'tokens', () {
    final ThemeData theme = buildGsMaterialTheme(defaultThemeParams);
    expect(theme.colorScheme.primary, isNotNull);
    expect(
      (theme.elevatedButtonTheme.style?.backgroundColor?.resolve(
        <WidgetState>{},
      )),
      Colors.green,
    );
    final RoundedRectangleBorder shape =
        theme.elevatedButtonTheme.style?.shape?.resolve(<WidgetState>{})
            as RoundedRectangleBorder;
    expect(
      (shape.borderRadius as BorderRadius).topLeft,
      const Radius.circular(12.0),
    );
    expect(theme.scaffoldBackgroundColor, Colors.white);
  });
}
