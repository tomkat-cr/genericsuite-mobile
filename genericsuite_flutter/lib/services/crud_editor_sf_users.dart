import 'dart:math';

import 'package:flutter/material.dart';

import 'crud_editor_commons.dart';
import 'utilities.dart';

const gceSfUsrDebug = false;

// Default prefix for generated user API keys (React: REACT_APP_API_KEYS_PREFIX).
const apiKeysPrefix = 'sk-gsu-';

// Generate a long hex access token (React: generateAccessToken).
String generateAccessToken([int length = 64]) {
  final Random random = Random.secure();
  final List<int> bytes = List<int>.generate(
    length,
    (_) => random.nextInt(256),
  );
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

Future<Map<String, dynamic>> usersValidations(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
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

// Users api keys pre-form data load default values (dbPreRead)
Future<Map<String, dynamic>> usersApiKeyDbPreRead(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
  BuildContext? context,
) async {
  Map<String, dynamic> result = genericFuncArrayDefaultValue(data);
  switch (action) {
    case actionCreate:
      final String accessTokenWaw = generateAccessToken();
      final String accessToken = '$apiKeysPrefix$accessTokenWaw';
      if (gceSfUsrDebug) {
        await logDebug(
          '>>> UsersApiKeyGenerate | access_token: $accessToken'
          ' access_token_waw: $accessTokenWaw',
        );
      }
      final Map<String, dynamic> dataMap = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};
      result['fieldValues'] = {
        ...dataMap,
        'resultset': {'access_token': accessToken},
      };
      break;
  }
  if (gceSfUsrDebug) {
    await logDebug(
      '>>> UsersApiKeyGenerate | resp: $result data: $data action: $action',
    );
  }
  return result;
}
