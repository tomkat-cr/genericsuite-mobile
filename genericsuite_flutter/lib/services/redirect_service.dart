import 'package:flutter/material.dart';

import '../views/homepage.dart';
import 'app_callables_super.dart';
import 'utilities.dart';

const redirectToCrud = false;
const rdSvDebug = false;

Widget getMainScreen(
  HomePageBodyBuilder homePageBodyBuilder,
  AlternateWidgetBuilder alternateWidgetBuilder,
  AppCallablesSuper appCallables,
) {
  if (redirectToCrud) {
    if (rdSvDebug) {
      logDebug('>>>> Redirect to CRUD...');
    }
    return alternateWidgetBuilder();
  } else {
    if (rdSvDebug) {
      logDebug('>>>> Redirect to HomePage...');
    }
    return HomePage(homePageBodyBuilder, alternateWidgetBuilder, appCallables);
  }
}

void redirectMainScreen(
  BuildContext context,
  HomePageBodyBuilder homePageBodyBuilder,
  AlternateWidgetBuilder alternateBodyBuilder,
  AppCallablesSuper appCallables,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => getMainScreen(
        homePageBodyBuilder,
        alternateBodyBuilder,
        appCallables,
      ),
    ),
  );
}
