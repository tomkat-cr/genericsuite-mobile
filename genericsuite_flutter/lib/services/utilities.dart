import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

const utDebug = false;

// ObjectId functions

String getId(dynamic fieldId) {
  if (fieldId is String) {
    return fieldId;
  }
  if (fieldId is Map && fieldId.containsKey('\$oid')) {
    return fieldId['\$oid'];
  }
  return '';
}

void convertObjectId(Map<String, dynamic> recordset) {
  if (recordset['_id'] is Map<String, dynamic>) {
    recordset['_id'] = getId(recordset['_id']);
  }
}

// JSON file functions

Map<String, dynamic> fixMapString(var map) {
  return Map<String, dynamic>.from(map);
}

Future<Map<String, dynamic>> getJsonFile(String filePath) async {
  String content = await rootBundle.loadString(filePath);
  return fixMapString(json.decode(content));
}

Future<List<Map<String, dynamic>>> getJsonFileList(String filePath) async {
  String content = await rootBundle.loadString(filePath);
  List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
    json.decode(content),
  );
  return list.map((item) => fixMapString(item)).toList();
}

Future<Map<String, dynamic>> getAppConstants() {
  return getJsonFile("assets/config_dbdef/frontend/app_constants.json");
}

Future<Map<String, dynamic>> getGeneralConstants() {
  return getJsonFile("assets/config_dbdef/frontend/general_constants.json");
}

Future<Map<String, dynamic>> getAllConstants() async {
  Map<String, dynamic> appConstants = await getAppConstants();
  Map<String, dynamic> generalConstants = await getGeneralConstants();
  return {...appConstants, ...generalConstants};
}

// General date/time functions

int nowToTimestamp() {
  return DateTime.now().millisecondsSinceEpoch;
}

String getTimeStampFormatted([int timestamp = 0]) {
  // Define the desired format using a pattern
  // HH is for 24-hour format (00-23)
  // hh is for 12-hour format (01-12)
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  if (timestamp == 0) {
    timestamp = DateTime.now().millisecondsSinceEpoch;
  }

  // Format the DateTime object into a String
  final String formattedDate = formatter.format(
    DateTime.fromMillisecondsSinceEpoch(timestamp),
  );
  return formattedDate;
}

String getDateTime([int timestamp = 0]) {
  if (timestamp == 0) {
    return getTodayDateTime();
  }
  return getTimeStampFormatted(timestamp);
}

String getTodayDateTime() {
  return getTimeStampFormatted();
}

// Misc

String getValueToEdit(
  var itemValue,
  var defaultValue, [
  Map<String, dynamic>? userData = const {},
]) {
  Map<String, dynamic> vars = {
    'defaultValueString': defaultValue.toString(),
    'itemValueString': itemValue.toString(),
  };
  for (var key in vars.keys) {
    switch (vars[key]) {
      case "CurrentUserId":
      case "{CurrentUserId}":
        vars[key] = userData!.containsKey('id') ? userData['id'] : vars[key];
        break;
      case 'current_timestamp':
        vars[key] = getTimeStampFormatted();
        break;
      default:
        break;
    }
  }
  return itemValue == null || vars['itemValueString'].isEmpty
      ? vars['defaultValueString']
      : vars['itemValueString'];
}

Map<String, dynamic> replaceSpecialVars(
  Map<String, dynamic> params,
  Map<String, dynamic> currentUser,
) {
  params.forEach((key, value) {
    if (value == "{CurrentUserId}") {
      params[key] = currentUser['id'];
    }
    if (value == "{current_timestamp}") {
      params[key] = nowToTimestamp();
    }
  });
  return params;
}

dynamic defaultValue(
  Map<String, dynamic> map,
  String key, [
  dynamic defaultValue = "",
]) {
  if (map.containsKey(key)) {
    return map[key];
  }
  return defaultValue;
}

// Log functions

Future<void> logDebug(String message) async {
  log("[DEBUG] ${getDateTime()} - $message");
}

Future<void> logInfoRaw(String message) async {
  log("[INFO] ${getDateTime()} - $message");
}

Future<void> logWarningRaw(String message) async {
  log("[WARNING] ${getDateTime()} - $message");
}

Future<void> logErrorRaw(String message) async {
  log("[ERROR] ${getDateTime()} - $message");
}
