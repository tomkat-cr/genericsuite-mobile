import 'package:flutter/material.dart';

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../views/homepage.dart';
import 'app_callables_super.dart';
import 'utilities.dart';

const redirectToCrud = false;
const rdSvDebug = false;

Widget getMainScreen(
  // storage,
  HomePageBodyBuilder homePageBodyBuilder,
  AlternateWidgetBuilder alternateWidgetBuilder,
  AppCallablesSuper appCallables,
) {
  if (redirectToCrud) {
    if (rdSvDebug) {
      logDebug('>>>> Redirect to CRUD...');
    }
    // return alternateWidgetBuilder(storage);
    return alternateWidgetBuilder();
  } else {
    if (rdSvDebug) {
      logDebug('>>>> Redirect to HomePage...');
    }
    return HomePage(
      // storage,
      homePageBodyBuilder,
      alternateWidgetBuilder,
      appCallables,
    );
  }
}

void redirectMainScreen(
  // FlutterSecureStorage storage,
  BuildContext context,
  HomePageBodyBuilder homePageBodyBuilder,
  AlternateWidgetBuilder alternateBodyBuilder,
  AppCallablesSuper appCallables,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => getMainScreen(
        // storage,
        homePageBodyBuilder,
        alternateBodyBuilder,
        appCallables,
      ),
    ),
  );
}
