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
    expect(defaultThemeParams['shadColorSchemeName'], 'green');
    expect(shadColorSchemeName, 'green');
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

  test('buildGsShadTheme maps GS tokens and keeps named-base selection', () {
    final theme = buildGsShadTheme({
      ...defaultThemeParams,
      'fontFamily': 'Roboto', // Use system font to avoid Google Fonts loading
      'shadColorSchemeName': 'slate',
      'accentColor': Colors.teal,
    });
    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.primary, Colors.teal);
    expect(theme.colorScheme.ring, Colors.teal);
    expect(theme.colorScheme.primaryForeground, Colors.white);
    expect(theme.colorScheme.background, Colors.white);
    expect(theme.colorScheme.foreground, const Color(0xFF111111));
    expect(theme.colorScheme.mutedForeground, const Color(0xFF6E6E73));
    expect(theme.colorScheme.destructive, const Color(0xFFFF3B30));
    expect(theme.colorScheme.destructiveForeground, Colors.white);
    expect(theme.colorScheme.border, const Color(0xFFD1D1D6));
    expect(theme.colorScheme.input, const Color(0xFFD1D1D6));
    expect(theme.colorScheme.secondary, const Color(0xFFF2F2F7));
    expect(theme.colorScheme.muted, const Color(0xFFF2F2F7));
    expect(theme.colorScheme.accent, const Color(0xFFF2F2F7));
    // selection left from named slate base (must not equal teal brand)
    expect(theme.colorScheme.selection, isNot(Colors.teal));
    expect(theme.radius, BorderRadius.circular(12.0));
  });

  test('buildGsShadTheme falls back to green for invalid scheme names', () {
    final theme = buildGsShadTheme({
      ...defaultThemeParams,
      'fontFamily': 'Roboto', // Use system font to avoid Google Fonts loading
      'shadColorSchemeName': 'not-a-real-scheme',
      'accentColor': Colors.orange,
    });
    expect(theme.colorScheme.primary, Colors.orange);
    expect(theme.colorScheme.ring, Colors.orange);
    // Green base keeps a non-null selection; fallback must not throw.
    expect(theme.colorScheme.selection, isNotNull);
  });
}
