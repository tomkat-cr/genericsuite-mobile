import 'package:flutter/material.dart';

import 'app_drawer.dart';

import '../services/app_callables_super.dart';
import '../services/locator_service.dart';

class AppFrame extends StatelessWidget {
  final Function()? action;
  final bool showBackButton;
  final bool showAppMenu;

  const AppFrame({
    super.key,
    required this.body,
    this.title,
    this.floatingActionButton,
    this.action,
    this.showBackButton = false,
    this.showAppMenu = true,
  });

  final Widget body;
  final String? title;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final VoidCallback backButtonAction = action == null
        ? () {
            Navigator.of(context).pop();
          }
        : () => action!();

    final AppCallablesSuper appCallables = appCallablesLocator
        .get<AppCallablesSuper>();
    String appBarLogoPath = appCallables.getThemeParams()['appBarLogoPath'];
    double appBarLogoHeight = appCallables.getThemeParams()['appBarLogoHeight'];
    // double appBarLogoWidth = appCallables.getThemeParams()['appBarLogoWidth'];

    String appBarTitleText = appCallables.getThemeParams()['appBarTitleText'];
    double appBarTitleTextFontSize = appCallables
        .getThemeParams()['appBarTitleTextFontSize'];
    FontWeight appBarTitleTextFontWeight = appCallables
        .getThemeParams()['appBarTitleTextFontWeight'];

    return Scaffold(
      appBar: AppBar(
        leading: !showBackButton
            ? showAppMenu
                  ? null
                  : const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: backButtonAction,
              ),
        title: title != null
            ? Text(title!, style: const TextStyle(fontWeight: FontWeight.w600))
            : appBarLogoPath.isNotEmpty
            ? Image.asset(
                appBarLogoPath,
                fit: BoxFit.contain,
                height: appBarLogoHeight,
                // width: appBarLogoWidth,
              )
            : appBarTitleText.isNotEmpty
            ? Text(
                appBarTitleText,
                style: TextStyle(
                  fontSize: appBarTitleTextFontSize,
                  fontWeight: appBarTitleTextFontWeight,
                ),
              )
            : const SizedBox.shrink(),
      ),
      drawer: showAppMenu ? AppDrawer() : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
