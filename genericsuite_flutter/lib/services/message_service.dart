import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'app_callables_super.dart';
// import 'theme_config.dart';
import 'utilities.dart';

const msSvDebug = false;

const severityLow = 0;
const severityMedium = 1;
const severityHigh = 2;

const typeInfo = 'info';
const typeError = 'error';

const defaultDuration = Duration(seconds: 40);

Future<bool> showScaffoldMessage(
  String message,
  BuildContext context,
  String type,
  AppCallablesSuper appCallables, [
  bool waitForOk = true,
]) {
  final Completer<bool> response = Completer<bool>();
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final snackBar = SnackBar(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    backgroundColor: type == typeError
        ? Colors.red[900]
        : type == typeInfo
        ? Colors.lightBlue
        : Colors.blueGrey[900],
    behavior: SnackBarBehavior.floating,
    // Stay until user clicks 'Close' or Close automatically after defaultDuration
    duration: waitForOk ? const Duration(days: 365) : defaultDuration,
    content: appCallables.getThemeParams()['closeButtonPlacement'] == "bottom"
        ? Column(
            children: [
              Text(
                message,
                style: TextStyle(
                  color: type == typeError
                      ? Colors.white
                      : type == typeInfo
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  scaffoldMessenger.hideCurrentSnackBar();
                  if (!response.isCompleted) {
                    response.complete(true); // User chose to close the SnackBar
                  }
                },
                child: const Text('Close'),
              ),
            ],
          )
        : Text(message),
    action: appCallables.getThemeParams()['closeButtonPlacement'] == "bottom"
        ? null
        : SnackBarAction(
            label: 'Close',
            onPressed: () {
              scaffoldMessenger.hideCurrentSnackBar();
              if (!response.isCompleted) {
                response.complete(true); // User chose to close the SnackBar
              }
            },
          ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  return response.future;
}

// Scaffold messages

/*
  * Show scaffold messages
  */
void showScaffoldMessages(
  BuildContext context,
  Map<String, dynamic> messages,
  AppCallablesSuper appCallables,
) {
  if (msSvDebug) {
    logDebug('CRUD | showScaffoldMessages | messages: ${messages.toString()}');
  }
  if (!messages.containsKey('errorWaitForOk') ||
      messages['errorWaitForOk'] == null) {
    messages['errorWaitForOk'] = true;
  }
  if (messages.containsKey('errorMessage') &&
      messages['errorMessage']?.isNotEmpty) {
    showScaffoldMessage(
      '${messages['errorMessage']}${messages['errorCode']?.isNotEmpty ? '\n${messages['errorCode']}' : ''}',
      context,
      typeError,
      appCallables,
      messages['errorWaitForOk'],
    );
  }
  if (messages.containsKey('infoMessage') &&
      messages['infoMessage']?.isNotEmpty) {
    showScaffoldMessage(
      messages['infoMessage'],
      context,
      typeInfo,
      appCallables,
      false,
    );
  }
}

/*
  * Schedule bindings, to show error and info messages after the widget is built
  */
void scheduleMessagesBindings(
  BuildContext context,
  Map<String, dynamic> messages,
  AppCallablesSuper appCallables,
) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    showScaffoldMessages(context, messages, appCallables);
  });
}
