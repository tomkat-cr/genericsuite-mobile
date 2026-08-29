import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'redirect_service.dart';
import 'theme_config_defaults.dart';

class AppCallablesSuper {
  /*
   * Get the theme parameters. Override in the app's AppCallables to
   * customize; only the keys you return are changed — CreateGsApp merges
   * this map over defaultThemeParams.
   */
  Map<String, dynamic> getThemeParams() {
    return Map<String, dynamic>.from(defaultThemeParams);
  }

  /*
   * Get the storage. This can be overridden in the app callables
   * to provide a custom storage implementation. E.g.
   * // Strict biometric enforcement
   * final storage = FlutterSecureStorage(
   *   aOptions: AndroidOptions.biometric(
   *     enforceBiometrics: true, // Requires biometric/PIN
   *     biometricPromptTitle: 'Authentication Required',
   *   ),
   * );
   */
  FlutterSecureStorage getStorage() {
    return FlutterSecureStorage();
  }

  /*
   * Get the app info
   */
  Map<String, dynamic> getAppInfo() {
    // Example:
    // return {
    //   "name": "GS Mobile app"
    //   "description": "GenericSuite Mobile app"
    //   "version": "1.0.0"
    //   "build": "1"
    // };
    throw UnimplementedError();
  }

  /*
   * Get the menu callables and other options
   */
  Map<String, dynamic> getMenuCallables() {
    // Example:
    // return {
    //   "HomePage": {
    //     "widget": () =>
    //         HomePage(homePageBodyBuilder: (userData) => HomePageBody(userData)),
    //     "icon": Icons.dashboard,
    //     "args": {}
    //   },
    //   "UserProfileEditor": {
    //     "widget": () => UserProfile(),
    //     "icon": Icons.person,
    //     "args": {}
    //   },
    //   "BillingEditor": {"widget": null, "icon": Icons.payment, "args": {}},
    //   "|about|": {"widget": () => About(), "icon": Icons.info, "args": {}},
    //   "logout": {
    //     "function": (context) => logOut(context),
    //     // "type": "sync" || "async" (default),
    //     "icon": Icons.logout,
    //     "args": {}
    //   },
    // };
    throw UnimplementedError();
  }

  /*
   * Get the main screen elements
   */
  Map<String, dynamic> getMainScreenElements() {
    // Example:
    // return {
    //   "mainScreen": () => HomePage(homePageBodyBuilder: (userData) => HomePageBody(userData)),
    //   "alternateScreen": () => AnyOtherWidget(),
    //   "redirect": false, // or true to redirect to alternate screen
    //   "icon": Icons.dashboard,
    //   "args": {},
    // };
    return {
      "mainScreen": (userData) => Text('Main Screen\n$userData'),
      "alternateScreen": () => Text('Alternate Screen'),
      "icon": Icons.dashboard,
      "redirect": false, // or true to redirect to alternate screen
      "args": {},
    };
  }

  /*
   * Get the getMainScreen widget
   */
  Widget mainScreenWidget() {
    // Example:
    // return getMainScreen(
    //   (userData) => HomePageBody(userData),
    //   () => AnyOtherWidget(),
    //   false, // or true to redirect to alternate screen
    // );
    Map<String, dynamic> elements = getMainScreenElements();
    return getMainScreen(
      elements['mainScreen'],
      elements['alternateScreen'],
      elements['redirect'],
    );
  }

  /*
   * Run redirectMainScreen
   */
  void runRedirectMainScreen(BuildContext context) {
    // Example:
    // redirectMainScreen(
    //   context,
    //   (userData) => HomePageBody(userData),
    //   () => AnyOtherWidget(),
    //   false, // or true to redirect to alternate screen
    // );
    Map<String, dynamic> elements = getMainScreenElements();
    redirectMainScreen(
      context,
      elements['mainScreen'],
      elements['alternateScreen'],
      elements['redirect'],
    );
  }

  /*
   * Get the user management related callbacks
   */
  Map<String, dynamic> getUserCallbacks(
    BuildContext context,
    dynamic userData,
  ) {
    // Example:
    // return {'specificFunctions': {}, "components": {}, "childComponents": {}};
    throw UnimplementedError();
  }
}
