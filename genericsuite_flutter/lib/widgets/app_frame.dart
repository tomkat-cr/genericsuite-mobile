import 'package:flutter/material.dart';

import 'app_drawer.dart';

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
            ? Text(title!)
            : Image.asset(
                'assets/images/app_logo_horizontal.png',
                fit: BoxFit.contain,
                height: 32,
              ),
      ),
      drawer: showAppMenu ? AppDrawer() : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
