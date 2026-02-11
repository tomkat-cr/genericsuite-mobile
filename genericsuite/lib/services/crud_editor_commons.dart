import 'package:flutter/material.dart';

import 'http_service.dart';
import 'utilities.dart';

const gceComDebug = false;

const actionCreate = 'create';
const actionRead = 'read';
const actionUpdate = 'update';
const actionDelete = 'delete';
const actionList = 'list';

/*
 * Custom callback type
 */
typedef CrudCallback =
    Future<Map<String, dynamic>> Function(
      dynamic data,
      Map<String, dynamic> editorConfig,
      String action,
      Map<String, dynamic> params,
      // FlutterSecureStorage storage,
      BuildContext? context,
    );

/*
 * Standard custom callback result structure
 */
Map<String, dynamic> stdCrudCallbackResult() {
  return {
    "error": '',
    "error_code": '',
    "fieldMsg": {},
    "fieldValues": {},
    "fieldsToDelete": [],
    "otherData": {},
  };
}

/*
 * Generic custom callback result default value, assigning the data to the
 * fieldValues key
 */
Map<String, dynamic> genericFuncArrayDefaultValue(dynamic data) {
  Map<String, dynamic> result = stdCrudCallbackResult();
  result['fieldValues'] = data;
  return result;
}

/*
 * Scaffold for CRUD callbacks (specific functions)
 */
Future<Map<String, dynamic>> voidCrudCallback(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
  // FlutterSecureStorage storage,
  BuildContext? context,
) async {
  Map<String, dynamic> result = genericFuncArrayDefaultValue(data);
  // final FlutterSecureStorage storage = locator<FlutterSecureStorage>();

  if (context == null || context.mounted == false) return result;
  switch (action) {
    case actionDelete:
    case actionUpdate:
    case actionCreate:
    case actionRead:
    case actionList:
      break;
    default:
      break;
  }
  // Error example
  if (data['error_message'].isNotEmpty) {
    result['error'] = data['error_message'];
    result['error_code'] = data.containsKey('error_code')
        ? data['error_code']
        : 'Example-Error-Code';
    return result;
  }
  return result;
}

// class CrudCallbacks {
//   final Map<String, CrudCallback>? specificCallbacks;
//   CrudCallbacks({
//     this.specificCallbacks,
//   });
// }

/*
 * Check if the custom callback type is a listing callable
 */
bool isAListingCallable(String funcType) =>
    (['dbListPostRead'].contains(funcType));

/*
 * Reduce all custom callbacks responses called in a single object with the
 * estrucuture of the stdCrudCallbackResult
 */
Future<Map<String, dynamic>> reduceAllResponses(
  String funcType,
  List<dynamic> responses,
  dynamic data,
  // FlutterSecureStorage storage,
) async {
  bool listTypeFieldValues = isAListingCallable(funcType);

  if (gceComDebug) {
    logDebug(
      'CRUD_commons | reduceAllResponses | funcType: $funcType, listTypeFieldValues: $listTypeFieldValues',
    );
  }

  Map<String, dynamic> defaultValues = genericFuncArrayDefaultValue(data);
  Map<String, dynamic> responsesReduced = defaultValues;
  try {
    for (Map<String, dynamic> response in responses) {
      response = {...defaultValues, ...response};
      responsesReduced['error'] +=
          (responsesReduced['error'] != '' && response['error'] != ''
              ? ', '
              : '') +
          response['error'];
      responsesReduced['fieldMsg'] = Map<String, dynamic>.from({
        ...responsesReduced['fieldMsg'],
        ...response['fieldMsg'],
      });

      // Merge fieldValues while preserving array values,
      // to prevent data losing when following fieldValues has same key but empty.
      // E.g. fieldValues["resultset"] may contains 'client_id' and 'client_secret' or another fields...
      // and following response may contains fieldValues["resultset"] = {}
      if (listTypeFieldValues) {
        // Get the last response fieldValues. because list cannot be merged.
        responsesReduced['fieldValues'] = response['fieldValues'];
      } else {
        Map<String, dynamic> mergedFieldValues = Map<String, dynamic>.from(
          responsesReduced['fieldValues'],
        );
        if (gceComDebug) {
          logDebug(
            'CRUD_commons | reduceAllResponses | funcType: $funcType | MAP Merge of fieldValues'
            '\nresponse:\n$response'
            '\nmergedFieldValues:\n$mergedFieldValues',
          );
        }
        for (MapEntry<String, dynamic> entry in Map<String, dynamic>.from(
          response['fieldValues'],
        ).entries) {
          String key = entry.key;
          dynamic value = entry.value;
          if (mergedFieldValues[key] is Map &&
              value is Map &&
              value.isNotEmpty) {
            if (!mergedFieldValues.containsKey(key) ||
                mergedFieldValues[key] == null) {
              mergedFieldValues[key] = {};
            }
            for (var entry2 in value.entries) {
              String key2 = entry2.key;
              dynamic value2 = entry2.value;
              mergedFieldValues[key][key2] = value2;
            }
            continue;
          }
          mergedFieldValues[key] = value;
        }
        responsesReduced['fieldValues'] = mergedFieldValues;
      }

      responsesReduced['fieldsToDelete'] = [
        ...responsesReduced['fieldsToDelete'],
        ...response['fieldsToDelete'],
      ];

      responsesReduced['otherData'] = Map<String, dynamic>.from({
        ...responsesReduced['otherData'],
        ...response['otherData'],
      });
    }
  } catch (e, stackTrace) {
    responsesReduced['error'] = e.toString();
    responsesReduced['error_code'] = 'FGCE-RAR-010';
    await logError(
      'CRUD_commons | reduceAllResponses | funcType: $funcType | ERROR: $e'
      '\nError Trace:\n${stackTrace.toString()}',
      responsesReduced['error_code'],
      // storage,
    );
  }
  return responsesReduced;
}
