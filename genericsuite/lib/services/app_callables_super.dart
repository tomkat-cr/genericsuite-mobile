import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'theme_config_defaults.dart';

class AppCallablesSuper {
  /*
   * Get the theme parameters
   */
  Map<String, dynamic> getThemeParams() {
    return {
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
    };
  }

  /*
   * Get the menu callables and other options
   */
  Map<String, dynamic> getMenuCallables() {
    throw UnimplementedError();
  }

  Map<String, dynamic> getUserCallbacks(
    FlutterSecureStorage storage,
    BuildContext context,
  ) {
    return {'specificFunctions': {}, "components": {}, "childComponents": {}};
  }
}
