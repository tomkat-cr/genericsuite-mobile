import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'http_service.dart';
import 'locator_service.dart';
import 'utilities.dart';

const cusDebug = false;

String getBestApiKey(List<dynamic> userDataApiKeys) {
  String result = '';
  // Check that entry exists
  if (userDataApiKeys.isEmpty) {
    return result;
  }
  if (cusDebug) {
    logDebug('getBestApiKey | userDataApiKeys: ${userDataApiKeys.toString()}');
  }
  for (var key in userDataApiKeys) {
    if (key['active'] == "1") {
      result = key['access_token'];
      if (cusDebug) {
        logDebug('getBestApiKey | result: $result');
      }
      return result;
    }
  }
  return result;
}

// Future<Map<String, dynamic>> getCurrentUserData(FlutterSecureStorage storage) {
Future<Map<String, dynamic>> getCurrentUserData() {
  FlutterSecureStorage storage = locator<FlutterSecureStorage>();

  // return loadConfig(storage).then((configStr) {
  return loadConfig().then((configStr) {
    Map<String, dynamic> config = json.decode(configStr);
    Map<String, dynamic> userData = {
      'config': config,
      'currentUserId': '',
      'apiKey': '',
      'userData': {},
      'error': false,
      'errorMessage': "",
    };

    String jwtToken = config["jwtToken"];
    if (jwtToken.isEmpty) {
      userData['error'] = true;
      userData['errorMessage'] = "Session expired. Please log in again.";
      return Future.value(userData);
    }

    Map<String, dynamic> payload = getJwtPayload(jwtToken);
    userData['currentUserId'] = payload["public_id"];

    String apiUrlUsersGetData = "users/current_user_d";
    if (cusDebug) {
      logDebug('getCurrentUserData | apiUrlUsersGetData: $apiUrlUsersGetData');
    }
    // var api = HttpUtilities(storage);
    var api = HttpUtilities();
    return api.httpsCall("get", apiUrlUsersGetData, {}, {}, {}).then((data) {
      if (data['error']) {
        return logError(
          'getCurrentUserData | ERROR [1] | data: ${data.toString()}',
          'GCUD-E010',
          // storage,
        ).then((_) {
          userData['error'] = true;
          userData['errorMessage'] = data['error_message'];
          return userData;
        });
      }

      if (cusDebug) {
        logDebug('getCurrentUserData | SUCCESS [1]');
      }

      userData['userData'] = data['resultset'];
      if (cusDebug) {
        logDebug('getCurrentUserData | userData has been SET');
      }

      if (config['apiKey'] != null) {
        userData['apiKey'] = config['apiKey'];
        return userData;
      }

      apiUrlUsersGetData = "users_api_keys";
      Map<String, dynamic> getParams = {"user_id": userData['currentUserId']};

      if (cusDebug) {
        logDebug(
          'getCurrentUserData | apiUrlUsersGetData: $apiUrlUsersGetData'
          ' | getParams: ${getParams.toString()}',
        );
      }

      return api
          .httpsCall("get", apiUrlUsersGetData, {}, {}, getParams)
          .then((data) {
            if (data['error']) {
              logError(
                'getCurrentUserData | ERROR [2] | data: ${data.toString()}',
                'GCUD-E020',
                // storage,
              ).then((_) {
                // Pass
              });
              if (data['error'] == 'Not Found') {
                return userData;
              }
              userData['error'] = true;
              userData['errorMessage'] = data['error_message'];
              return userData;
            }

            if (cusDebug) {
              logDebug('getCurrentUserData | SUCCESS [2]');
            }

            List<dynamic> userDataApiKeys = json.decode(data['resultset']);
            String apiKey = getBestApiKey(userDataApiKeys);
            if (cusDebug) {
              logDebug('getCurrentUserData | apiKey: $apiKey');
            }

            if (apiKey.isNotEmpty) {
              storage.write(key: "api_key", value: apiKey).then((value) {
                if (cusDebug) {
                  logDebug('getCurrentUserData | storage.apiKey has been SET');
                }
              });
            }

            return userData;
          })
          .catchError((error) {
            logError(
              'getCurrentUserData | ERROR [3] | error: $error',
              'GCUD-E030',
              // storage,
            ).then((_) {
              // Pass
            });
            userData['error'] = true;
            userData['errorMessage'] = error.toString();
            return userData;
          });
    });
  });
}
