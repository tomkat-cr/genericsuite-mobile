import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'crud_editor_commons.dart';

const gceSfUsrDebug = false;

Future<Map<String, dynamic>> usersValidations(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
  FlutterSecureStorage storage,
  BuildContext? context,
) async {
  Map<String, dynamic> result = genericFuncArrayDefaultValue(data);
  Map<String, dynamic> userData = params['currentUser'];
  switch (action) {
    case actionDelete:
      if (data['superuser'] == '1' && userData['superuser'] == '0') {
        result['error'] =
            '${result['error'] == '' ? '' : '<BR/>'}'
            'Super users can be deleted only by other Super users.';
      }
      if (data['id'] == userData['id']) {
        result['error'] =
            '${result['error'] == '' ? '' : '<BR/>'}'
            'You cannot delete yourself';
      }
      if (userData['superuser'] == '0' && data['id'] != userData['id']) {
        result['error'] =
            '${result['error'] == '' ? '' : '<BR/>'}'
            'You cannot delete other\'s records';
      }
      break;
    case actionUpdate:
      if (userData['superuser'] == '0' && data['id'] != userData['id']) {
        result['error'] =
            '${result['error'] == '' ? '' : '<BR/>'}'
            'You cannot modify other\'s records';
      }
      break;
    case actionCreate:
      if (userData['superuser'] == '0') {
        result['error'] =
            '${result['error'] == '' ? '' : '<BR/>'}'
            'You cannot create new users';
      }
      break;
    case actionRead:
    case actionList:
      break;
    default:
      break;
  }
  return result;
}

Future<Map<String, dynamic>> usersDbListPreRead(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
  FlutterSecureStorage storage,
  BuildContext? context,
) async {
  Map<String, dynamic> result = genericFuncArrayDefaultValue(data);
  Map<String, dynamic> userData = params['currentUser'];
  if (!userData.containsKey('superuser') ||
      userData['superuser'] == null ||
      userData['superuser'] != '1') {
    // Set a filter to retrieve only the current user
    result['fieldValues']['_id'] = userData['id'];
  }
  return result;
}

Future<Map<String, dynamic>> usersPasswordValidations(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
  FlutterSecureStorage storage,
  BuildContext? context,
) async {
  Map<String, dynamic> result = genericFuncArrayDefaultValue(data);
  switch (action) {
    case actionCreate:
      if (data['passcode'].isEmpty) {
        result['error'] = 'User needs a password';
      }
      break;
    case actionUpdate:
      if (data['passcode'].isNotEmpty) {
        if (data['passcode'] != data['passcode_repeat']) {
          result['error'] =
              '"New Password" and "Repeat New Password" must be same';
        }
      }
      break;
    default:
      break;
  }
  return result;
}

Future<Map<String, dynamic>> usersDbPreWrite(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
  FlutterSecureStorage storage,
  BuildContext? context,
) async {
  Map<String, dynamic> result = genericFuncArrayDefaultValue(data);
  // Avoid passing an empty password to the backend
  if (data['passcode'].trim() == '') {
    result['fieldsToDelete'].add('passcode');
  }
  // Avoid passing the repeat password field to the backend
  result['fieldsToDelete'].add('passcode_repeat');
  return result;
}
