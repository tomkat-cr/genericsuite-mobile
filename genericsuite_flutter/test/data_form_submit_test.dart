import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/services/crud_editor_commons.dart';
import 'package:genericsuite/services/form_field_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  testWidgets(
      'submit() writes current field values so popup-menu save does not '
      'send the values from when the form was opened', (tester) async {
    Map<String, dynamic>? saved;
    final formKey = GlobalKey<DataFormBodyState>();
    final selectedItem = <String, dynamic>{'name': 'old'};

    await tester.pumpWidget(
      ShadApp.custom(
        appBuilder: (context) => MaterialApp(
          home: Scaffold(
            body: DataFormBody(
              key: formKey,
              editorConfig: const {
                'fieldElements': [
                  {'name': 'name', 'type': 'text', 'label': 'Name'},
                ],
              },
              constants: const {},
              selectedItem: selectedItem,
              callbacks: const {},
              currentUserData: const {},
              action: actionUpdate,
              saveItem: (Map<String, dynamic> item) {
                saved = Map<String, dynamic>.from(item);
              },
              setEditMode: (bool newEditMode) {},
              setError: (String message, String code, [int severity = 0]) {},
              props: const {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'new');
    expect(formKey.currentState!.submit(), isTrue);
    expect(saved, {'name': 'new'});
  });
}
