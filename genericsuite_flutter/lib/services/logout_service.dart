import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../views/homepage.dart';
import '../views/login.dart';
import 'app_callables_super.dart';
import 'locator_service.dart';

/*
  * Logout
  */
void logOut(
  BuildContext context,
  HomePageBodyBuilder homePageBodyBuilder,
  AlternateWidgetBuilder alternateWidgetBuilder,
  AppCallablesSuper appCallables,
) {
  FlutterSecureStorage storage = locator<FlutterSecureStorage>();

  // Delete user data to let the login page use the new user data
  storage.delete(key: "jwt");
  storage.delete(key: "api_key");
  storage.delete(key: "user_data");

  // Navigate to the login page
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) =>
          LoginPage(homePageBodyBuilder, alternateWidgetBuilder, appCallables),
    ),
  );
}
