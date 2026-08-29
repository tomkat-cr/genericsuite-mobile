import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../views/login.dart';
import 'locator_service.dart';

/*
  * Logout
  */
Future<void> logOut(BuildContext context) async {
  FlutterSecureStorage storage = storageLocator<FlutterSecureStorage>();

  // Delete user data to let the login page use the new user data
  await Future.wait([
    storage.delete(key: "jwt"),
    storage.delete(key: "api_key"),
    storage.delete(key: "user_data"),
  ]);

  if (!context.mounted) return;

  // Navigate to the login page
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}
