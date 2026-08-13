import 'package:flutter/material.dart';

/*
 * Route an item to its corresponding widget or function
 * according to the configuration in app's app_callables.dart
 */
Map<String, dynamic> routeItem(
  Map<String, dynamic> item,
  BuildContext context,
) {
  Map<String, dynamic> result = {
    'errorMessage': '',
    'errorCode': '',
    'infoMessage': '',
  };
  if (item['type'] == 'widget' &&
      (item['callable']['widget'] != null ||
          item['callable']['function'] != null)) {
    if (item['callable']['function'] != null) {
      Navigator.pop(context); // Close the drawer
      if (item['callable']['type'] != null &&
          item['callable']['type'] == 'sync') {
        // Sync function
        item['callable']['function'](context);
      } else {
        // Async function. E.g. logOut(context)
        item['callable']['function'](context)
            .then((value) {
              // Do nothing
              return result;
            })
            .catchError((error) {
              result['errorMessage'] =
                  "Error calling function: ${error.toString()}";
              result['errorCode'] = "AD-E030";
              return result;
            });
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => item['callable']['widget']()),
      );
    }
  } else {
    result['errorMessage'] = "${item['title']} is not implemented";
    result['errorCode'] = "AD-E020";
    Navigator.pop(context); // Close the drawer
  }
  return result;
}
