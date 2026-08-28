import 'package:flutter/material.dart';

/*
 * Child components support for the Flutter CRUD Editor (1-N relations).
 *
 * Mirrors genericsuite-fe's iterateChildComponents()
 * (generic.editor.rfc.formpage.jsx): each name in the JSON config's
 * "childComponents" array is resolved against the app-supplied
 * callbacks['childComponents'] registry, and the resulting widget receives
 * the parent row as parentData. On mobile the child opens full-screen
 * (Navigator.push) instead of rendering inline below the form, because a
 * nested CrudEditor carries its own Scaffold/AppFrame.
 */

typedef ChildComponentBuilder =
    Widget Function({
      required Map<String, dynamic> parentData,
      Map<String, dynamic>? props,
    });

/*
 * 'UsersFoodTimes' -> 'Users Food Times'
 */
String childComponentLabel(String name) =>
    name.replaceAllMapped(RegExp(r'(?<=[a-z0-9])(?=[A-Z])'), (m) => ' ');

/*
 * Build one tappable navigation section per child component.
 * Unregistered names render an error tile (same spirit as the fe's
 * "Component Not Found" handling).
 */
List<Widget> buildChildComponentSections({
  required BuildContext context,
  required Map<String, dynamic> editorConfig,
  required Map<String, dynamic> callbacks,
  required Map<String, dynamic> parentData,
}) {
  final Map<String, dynamic> registry = Map<String, dynamic>.from(
    callbacks['childComponents'] ?? {},
  );
  return List<Widget>.from(
    (editorConfig['childComponents'] as List).map((name) {
      final dynamic builder = registry[name];
      if (builder == null) {
        return ListTile(
          key: ValueKey('childComponent_$name'),
          leading: const Icon(Icons.error_outline, color: Colors.red),
          title: Text('Child component [$name] Not Found'),
        );
      }
      return Card(
        key: ValueKey('childComponent_$name'),
        child: ListTile(
          title: Text(childComponentLabel(name)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => builder(
                  parentData: parentData,
                  props: {'isChildComponent': true, 'showAppMenu': false},
                ),
              ),
            );
          },
        ),
      );
    }),
  );
}
