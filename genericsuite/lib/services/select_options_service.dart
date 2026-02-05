import 'package:flutter/material.dart';
import 'package:genericsuite/services/utilities.dart';

const gceSoDebug = false;

List<DropdownMenuItem<String>> putSelectOptionsFromArray({
  required Map<String, dynamic> selectElements,
  // String titleFieldName = "title",
  // String valueFieldName = "value",
}) {
  if (gceSoDebug) {
    logDebug("putSelectOptionsFromArray | Select Elements: $selectElements");
  }
  List<DropdownMenuItem<String>> options = [];
  options.add(
    const DropdownMenuItem(
      key: ValueKey(""),
      value: '',
      child: Text('Select an option...'),
    ),
  );
  if (gceSoDebug) {
    logDebug(
      "putSelectOptionsFromArray | Dropdown BLANK MenuItem added: ${options.last}",
    );
  }

  for (var key in selectElements.keys) {
    if (gceSoDebug) {
      logDebug(
        "putSelectOptionsFromArray | Key: $key | Value: ${selectElements[key]}",
      );
    }
    options.add(
      DropdownMenuItem(
        key: ValueKey(key),
        value: key.toString(),
        child: Text(selectElements[key].toString()),
      ),
    );
    if (gceSoDebug) {
      logDebug(
        "putSelectOptionsFromArray | Dropdown MenuItem added: ${options.last}",
      );
    }
  }
  return options;
}

String getSelectOptionLabel(dynamic selectElements, String value) {
  if (gceSoDebug) {
    logDebug(
      "getSelectOptionLabel | Value: $value | Select Elements: $selectElements",
    );
  }
  if (selectElements == null || selectElements[value] == null) {
    return "--$value--";
  }
  return selectElements[value].toString();
}
