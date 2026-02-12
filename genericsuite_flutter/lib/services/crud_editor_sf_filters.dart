import 'package:flutter/material.dart';

import 'crud_editor_commons.dart';
import 'utilities.dart';

const gceSfFilDebug = false;

Future<Map<String, dynamic>> mandatoryFiltersDbListPreRead(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
  BuildContext? context,
) async {
  Map<String, dynamic> result = genericFuncArrayDefaultValue(data);
  if (editorConfig.containsKey('mandatoryFilters') &&
      editorConfig['mandatoryFilters'] != null) {
    result['fieldValues'] = replaceSpecialVars(
      editorConfig['mandatoryFilters'],
      params['currentUser'],
    );
  }
  if (gceSfFilDebug) {
    logDebug(
      ">>> mandatoryFiltersDbListPreRead | resp: ${result['fieldValues']}",
    );
  }
  return result;
}

Future<Map<String, dynamic>> mandatoryFiltersDbPreRead(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
  BuildContext? context,
) async {
  Map<String, dynamic> result = genericFuncArrayDefaultValue(data);
  if (editorConfig.containsKey('mandatoryFilters') &&
      editorConfig['mandatoryFilters'] != null) {
    result['fieldValues'] = {
      'resultset': {
        ...data,
        ...replaceSpecialVars(
          editorConfig['mandatoryFilters'],
          params['currentUser'],
        ),
      },
    };
  }
  if (gceSfFilDebug) {
    logDebug(">>> mandatoryFiltersDbPreRead | resp: ${result['fieldValues']}");
  }
  return result;
}
