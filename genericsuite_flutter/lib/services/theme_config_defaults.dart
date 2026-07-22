import 'package:flutter/material.dart';

// GenericSuite Mobile default theme tokens [GS-261].
//
// Design language: Apple-clean — white/neutral surfaces, near-black text,
// ONE accent color, 12 px corner radius, iOS system semantic colors.
// Typography intent: Inter (via google_fonts) for an SF-Pro-like feel.
//
// Consumer apps override AppCallablesSuper.getThemeParams(); CreateGsApp
// merges that map OVER defaultThemeParams, so apps may return only the keys
// they want to change.

const MaterialColor accentColor = Colors.green;

const double borderRadius = 12.0;

// Defines the border line's weight of Material inputDecorationTheme
// border and enabledBorder, and dividerTheme thickness
const double separatorWidth = 0.50;

// Vertical gap between stacked form fields so outlined focus rings do not
// overlap the previous field's border / floating label.
const double fieldVerticalSpacing = 12.0;

// Named shadcn_ui base scheme for buildGsShadTheme(). Valid values match
// ShadColorScheme.fromName: blue, gray, green, neutral, orange, red, rose,
// slate, stone, violet, yellow, zinc. Apps override via getThemeParams().
const String shadColorSchemeName = 'green';

// Typography tokens. 'Inter' triggers GoogleFonts.interTextTheme() in
// CreateGsApp; any other family name is applied verbatim. An app can also
// provide a full TextTheme via the 'textTheme' theme param (null = derive
// from fontFamily).
const String gsFontFamily = 'Inter';

const Color textColor = Color(0xFF111111); // near-black
const Color secondaryTextColor = Color(0xFF6E6E73); // iOS secondary label
const Color separatorColor = Color(0xFFD1D1D6); // iOS separator
const Color neutralSurfaceColor = Color(0xFFF2F2F7); // iOS systemGray6

// Legacy token, superseded by accentColor. Kept because existing apps
// reference it in their getThemeParams() overrides.
const MaterialColor primarySwatch = accentColor;
const Color scaffoldBackgroundColor = Colors.white;

const Color appBarBackgroundColor = Colors.white;
const Color appBarForegroundColor = textColor;

const Color drawerBackgroundColor = Colors.white;
const Color drawerForegroundColor = textColor;

// iOS system semantic colors
const Color errorBackgroundColor = Color(0xFFFF3B30); // systemRed
const Color errorForegroundColor = Colors.white;
const Color infoBackgroundColor = Color(0xFF007AFF); // systemBlue
const Color infoForegroundColor = Colors.white;
const Color warningBackgroundColor = Color(0xFFFF9500); // systemOrange
const Color warningForegroundColor = Colors.white;
const Color successBackgroundColor = Color(0xFF34C759); // systemGreen
const Color successForegroundColor = Colors.white;

const String closeButtonPlacement = "bottom"; // "bottom" or "right"

const Map<String, dynamic> defaultThemeParams = {
  'accentColor': accentColor,
  'borderRadius': borderRadius,
  'fieldVerticalSpacing': fieldVerticalSpacing,
  'fontFamily': gsFontFamily,
  'textTheme': null, // TextTheme? — app-provided full text theme
  'textColor': textColor,
  'secondaryTextColor': secondaryTextColor,
  'separatorColor': separatorColor,
  'neutralSurfaceColor': neutralSurfaceColor,
  'primarySwatch': primarySwatch,
  'scaffoldBackgroundColor': scaffoldBackgroundColor,
  'appBarBackgroundColor': appBarBackgroundColor,
  'appBarForegroundColor': appBarForegroundColor,
  'drawerBackgroundColor': drawerBackgroundColor,
  'drawerForegroundColor': drawerForegroundColor,
  'errorBackgroundColor': errorBackgroundColor,
  'errorForegroundColor': errorForegroundColor,
  'infoBackgroundColor': infoBackgroundColor,
  'infoForegroundColor': infoForegroundColor,
  'warningBackgroundColor': warningBackgroundColor,
  'warningForegroundColor': warningForegroundColor,
  'successBackgroundColor': successBackgroundColor,
  'successForegroundColor': successForegroundColor,
  'closeButtonPlacement': closeButtonPlacement,
  'shadColorSchemeName': shadColorSchemeName,
};
