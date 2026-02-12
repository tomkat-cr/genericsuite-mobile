import 'package:flutter/material.dart';

import 'crud_editor_commons.dart';
import 'http_service.dart';
import 'timestamp_utilities.dart';
import 'utilities.dart';

const gceSfTsDebug = false;

/*
 * Timestamp to Date convertion during Listing Database Post Read
 */
Future<Map<String, dynamic>> timestampDbListPostRead(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
  BuildContext? context,
) async {
  Map<String, dynamic> result = genericFuncArrayDefaultValue(data);
  result['fieldValues'] = [];
  for (var row in data) {
    for (var currentObj in editorConfig['fieldElements']) {
      if (row[currentObj['name']] == null) {
        continue;
      }
      switch (currentObj['type']) {
        case 'date':
        case 'datetime-local':
          dynamic timestamp = convertTimestampToInt(row[currentObj['name']]);
          row[currentObj['name']] = processTimestampToDate(
            timestamp,
            true,
            ' ',
          );
          break;
        default:
          break;
      }
    }
    result['fieldValues'].add(row);
  }
  return result;
}

/*
 * Timestamp to Date convertion during FormData Database Post Read
 */
Future<Map<String, dynamic>> timestampDbPostRead(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
  BuildContext? context,
) async {
  if (gceSfTsDebug) {
    logDebug('CRUD | timestampDbPostRead | data [1]: ${data.toString()}');
  }
  Map<String, dynamic> result = genericFuncArrayDefaultValue(data);
  result['fieldValues'] = {};
  Map<String, dynamic> row = Map<String, dynamic>.from(data);
  for (var currentObj in editorConfig['fieldElements']) {
    if (row[currentObj['name']] == null) {
      row[currentObj['name']] = '';
    }
    switch (currentObj['type']) {
      case 'date':
        // For date edition, we need only the date portion
        dynamic timestamp = convertTimestampToInt(row[currentObj['name']]);
        row[currentObj['name']] = processTimestampToDate(timestamp, true, ' ');
        break;
      case 'datetime-local':
        // For datetime-local edition, we need the date from time separation to be the 'T'
        dynamic timestamp = convertTimestampToInt(row[currentObj['name']]);
        row[currentObj['name']] = processTimestampToDate(timestamp, true, 'T');
        break;
      default:
        break;
    }
  }
  result['fieldValues'] = row;
  if (gceSfTsDebug) {
    logDebug(
      'CRUD | timestampDbPostRead | result PASSED: ${result.toString()}',
    );
  }
  return result;
}

/*
 * Date to Timestamp convertion during FormData Database Pre Writing
 */
Future<Map<String, dynamic>> timestampDbPreWrite(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
  BuildContext? context,
) async {
  if (gceSfTsDebug) {
    logDebug('CRUD | timestampDbPreWrite | data: ${data.toString()}');
  }
  Map<String, dynamic> result = genericFuncArrayDefaultValue(data);
  String fieldName = '--N/A--';
  dynamic fieldValue = '--N/A--';
  try {
    result['fieldValues'] = Map<String, dynamic>.from(data);
    for (var currentObj in editorConfig['fieldElements']) {
      fieldName = currentObj['name'];
      fieldValue = result['fieldValues'][fieldName];
      switch (currentObj['type']) {
        case 'date':
        case 'datetime-local':
          result['fieldValues'][fieldName] = processDateToTimestamp(fieldValue);
          break;
        default:
          break;
      }
    }
    if (result['fieldValues'].containsKey('update_date')) {
      result['fieldValues']['update_date'] = nowToTimestamp();
    }
  } catch (e, stackTrace) {
    result['error'] = e.toString();
    result['error_code'] = "FGCE-TSDPW-E001";
    await logError(
      'CRUD | timestampDbPreWrite | Field: $fieldName | Field Value: $fieldValue | Error: ${e.toString()} [${result['error_code']}]'
      '\nError Trace:\n${stackTrace.toString()}',
      result['error_code'],
    );
  }
  if (gceSfTsDebug) {
    logDebug(
      'CRUD | timestampDbPreWrite | result PASSED: ${result.toString()}',
    );
  }
  return result;
}
