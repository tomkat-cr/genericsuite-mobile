import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'general_messages.dart';
import 'locator_service.dart';
import 'utilities.dart';

const httpSvcDebug = false;
const debugJwtToken = false;
const debugConfigValues = false;

const useServerLog = true;

class HttpUtilities {
  HttpUtilities();

  String jwtToken = '';
  Map<String, dynamic> configItems = {};

  Future<Map<String, dynamic>> httpsCall(
    String requestType,
    String apiUrl,
    Map<String, dynamic> customHeaders,
    Map<String, dynamic> bodyParams,
    Map<String, dynamic> getParams, {
    bool useServerLog = true,
  }) async {
    return loadConfig().then((configStr) async {
      Map<String, dynamic> config = json.decode(configStr);
      String logErrorMessage = '';

      if (config['apiKey'] != null) {
        if (debugJwtToken) {
          logDebug('HttpUtilities | httpsCall | apiKey: ${config['apiKey']}');
        }
        jwtToken = config['apiKey'];
      } else {
        if (debugJwtToken) {
          logDebug(
            'HttpUtilities | httpsCall | jwtToken: ${config["jwtToken"]}',
          );
        }
        jwtToken = config["jwtToken"];
      }

      configItems = config["configItems"];

      if (debugJwtToken) {
        logDebug(
          'HttpUtilities | loadConfig() | jwtToken: $jwtToken | configItems: $configItems',
        );
      }

      // HttpClient client = HttpClient();
      // if (configItems['ENV'] == "local") {
      //   client.badCertificateCallback =
      //       ((X509Certificate cert, String host, int port) => true);
      // }

      Map<String, String> requestHeaders = {};

      String url = '${configItems['API_URL']}/$apiUrl';
      if (getParams.isNotEmpty) {
        url += '?';
        getParams.forEach((key, value) {
          url += '$key=${Uri.encodeComponent(value.toString())}&';
        });
        // Remove the last '&' or replace with a more efficient method
        url = url.substring(0, url.length - 1);
      }
      if (httpSvcDebug) {
        logDebug('HttpUtilities | httpsCall | url: $url');
      }

      if (jwtToken.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $jwtToken';
      }

      customHeaders.forEach((key, value) {
        requestHeaders[key] = value;
      });

      var jsonPayload = jsonEncode(bodyParams);
      if (bodyParams.isNotEmpty) {
        requestHeaders['Content-Type'] = 'application/json; charset=UTF-8';
      }

      if (httpSvcDebug) {
        logDebug(
          'HttpUtilities | httpsCall | Request Headers: ${requestHeaders.toString()}'
          '\n| Request Body: ${bodyParams.toString()}'
          '\n| Request Get Params: ${getParams.toString()}'
          '\n| Request URL: $url'
          '\n| Request Method: $requestType',
        );
      }

      http.Response response;
      Uri urlParsed = Uri.parse(url);
      try {
        switch (requestType.toLowerCase()) {
          case "get":
            response = await http.get(urlParsed, headers: requestHeaders);
            break;
          case "post":
            response = await http.post(
              urlParsed,
              headers: requestHeaders,
              body: jsonPayload,
            );
            break;
          case "put":
            response = await http.put(
              urlParsed,
              headers: requestHeaders,
              body: jsonPayload,
            );
            break;
          case "delete":
            response = await http.delete(
              urlParsed,
              headers: requestHeaders,
              body: jsonPayload,
            );
            break;
          case "patch":
            response = await http.patch(
              urlParsed,
              headers: requestHeaders,
              body: jsonPayload,
            );
            break;
          default:
            logErrorMessage =
                'HttpUtilities | httpsCall | Invalid request type: $requestType';
            if (useServerLog) {
              await logError(logErrorMessage, 'HC-E010');
            } else {
              logErrorRaw(logErrorMessage);
            }
            return {
              "error": true,
              "error_message": getApiErrorMessage('internalError'),
              "status_code": 500,
              "resultset": {},
            };
        }
      } catch (e) {
        logErrorRaw('HttpUtilities | httpsCall | Error [1]: $e');
        return {
          "error": true,
          "error_message": getApiErrorMessage('serverIsDown'),
          "status_code": 500,
          "resultset": {},
        };
      }

      if (httpSvcDebug) {
        logDebug(
          'HttpUtilities | httpsCall | response.statusCode: ${response.statusCode}',
        );
        logDebug('HttpUtilities | httpsCall | response.body: ${response.body}');
      }

      Map<String, dynamic> result;
      if (response.statusCode == 200 || response.statusCode == 201) {
        result = json.decode(response.body);
      } else {
        String errorMessage = "";
        try {
          final Map<String, dynamic> error = json.decode(response.body);
          errorMessage = error['detail'];
        } catch (e) {
          errorMessage = response.body;
        }
        if (errorMessage.isEmpty) {
          errorMessage = getApiErrorMessage('unknownError');
        }
        logErrorMessage =
            'HttpUtilities | httpsCall | Error [2]: $errorMessage | response: ${response.toString()}';
        if (useServerLog) {
          await logError(logErrorMessage, 'HC-E020');
        } else {
          logErrorRaw(logErrorMessage);
        }
        result = {
          "error": true,
          "error_message": getApiErrorMessage('serverError'),
          "error_detail": errorMessage,
          "status_code": response.statusCode,
          "resultset": {},
        };
      }

      if (httpSvcDebug) {
        logDebug('HttpUtilities | httpsCall | result: $result');
      }

      return result;
    });
  }
}

String getApiDataResponse(AsyncSnapshot snapshot) {
  String errorMessage = "";
  if (snapshot.hasError) {
    errorMessage = "An error occurred [GADR-E010]";
  }
  if (!snapshot.hasData) {
    errorMessage = "No data [GADR-E020]";
  }
  if (errorMessage.isNotEmpty) {
    return "$errorMessage | $snapshot";
  }
  var apiResponse = snapshot.data;
  if (apiResponse['error']) {
    return apiResponse['error_message'];
  }
  if (apiResponse['resultset'] is String) {
    return apiResponse['resultset'];
  }
  return apiResponse['resultset'].toString();
}

String bToA(str) {
  final bytes = utf8.encode(str);
  final base64Str = base64.encode(bytes);
  return base64Str;
}

Map<String, dynamic> getJwtPayload(String jwtTokenRaw) {
  if (debugJwtToken) {
    logDebug('http_service | getJwtPayload | jwtTokenRaw: $jwtTokenRaw');
  }
  var jwt = jwtTokenRaw.split(".");
  Map<String, dynamic> jwtPayload = {};
  if (jwt.length == 3) {
    jwtPayload = json.decode(
      ascii.decode(base64.decode(base64.normalize(jwt[1]))),
    );
  }
  return jwtPayload;
}

Future<String> loadConfig() async {
  final storage = storageLocator<FlutterSecureStorage>();
  String jwtToken = '';
  Map<String, dynamic> configItems = {};
  return storage.read(key: 'jwt').then((jwtTokenValue) {
    return storage.read(key: 'configItems').then((configItemsValue) {
      return storage.read(key: 'api_key').then((apiKeyValue) {
        if (debugJwtToken) {
          logDebug('http_service | loadConfig | jwtTokenValue: $jwtTokenValue');
          logDebug(
            'http_service | loadConfig | configItemsValue: $configItemsValue',
          );
        }
        String userId = "";
        if (jwtTokenValue != null) {
          jwtToken = jwtTokenValue;
          Map<String, dynamic> payload = getJwtPayload(jwtToken);
          if (debugJwtToken) {
            logDebug('http_service | loadConfig | payload: $payload');
          }
          if (payload.isNotEmpty) {
            userId = payload["public_id"];
          }
        }
        if (configItemsValue != null) {
          configItems = json.decode(configItemsValue);
        }
        String result = json.encode({
          'userId': userId,
          'jwtToken': jwtToken,
          'apiKey': apiKeyValue,
          'configItems': configItems,
        });
        if (debugConfigValues) {
          logDebug('http_service | loadConfig | result: $result');
        }
        return result;
      });
    });
  });
}

// Log functions

Future<void> logServer(String message, String errorCode, String logType) async {
  HttpUtilities api = HttpUtilities();
  String urlSuffix = "logs";
  String requestMethod = "POST";
  Map<String, dynamic> getParams = {};
  Map<String, dynamic> body = {
    'message': '$message ${errorCode.isNotEmpty ? '[$errorCode]' : ''}',
    'log_type': logType,
    'timestamp': nowToTimestamp(),
  };
  if (httpSvcDebug) {
    logDebug(
      'logServer | urlSuffix: $urlSuffix | requestMethod: $requestMethod | body: $body | getParams: $getParams',
    );
  }
  final apiResp = await api.httpsCall(
    requestMethod,
    urlSuffix,
    {},
    body,
    getParams,
    useServerLog: false,
  );
  if (httpSvcDebug) {
    logDebug('logServer | apiResp: $apiResp');
  }
}

Future<void> logInfo(String message) async {
  logInfoRaw(message);
  if (useServerLog) {
    logServer(message, '', 'INFO');
  }
}

Future<void> logWarning(String message) async {
  logWarningRaw(message);
  if (useServerLog) {
    logServer(message, '', 'WARNING');
  }
}

Future<void> logError(String message, String errorCode) async {
  logErrorRaw('$message [$errorCode]');
  if (useServerLog) {
    logServer(message, errorCode, 'ERROR');
  }
}
