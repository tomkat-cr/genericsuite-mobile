import 'package:flutter/material.dart';

import '../views/homepage.dart';
import 'utilities.dart';

const rdSvDebug = false;

Widget getMainScreen(
  HomePageBodyBuilder homePageBodyBuilder,
  AlternateWidgetBuilder alternateWidgetBuilder, [
  bool? redirectToAlternateWidget = false,
]) {
  if (redirectToAlternateWidget == true) {
    if (rdSvDebug) {
      logDebug('>>>> Redirect to Alternate Widget...');
    }
    return alternateWidgetBuilder();
  } else {
    if (rdSvDebug) {
      logDebug('>>>> Redirect to HomePage...');
    }
    return HomePage(homePageBodyBuilder: homePageBodyBuilder);
  }
}

void redirectMainScreen(
  BuildContext context,
  HomePageBodyBuilder homePageBodyBuilder,
  AlternateWidgetBuilder alternateBodyBuilder, [
  bool? redirectToAlternateWidget = false,
]) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => getMainScreen(
        homePageBodyBuilder,
        alternateBodyBuilder,
        redirectToAlternateWidget,
      ),
    ),
  );
}
