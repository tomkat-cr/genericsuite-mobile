import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/services/crud_editor_commons.dart';
import 'package:genericsuite/services/form_field_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Finder _suggestionField() {
  return find.descendant(
    of: find.byType(Autocomplete<String>),
    matching: find.byType(TextField),
  );
}

void main() {
  testWidgets(
    'typing in suggestion_dropdown stores the new value in selectedItem '
    'and submit() persists it',
    (tester) async {
      Map<String, dynamic>? saved;
      final formKey = GlobalKey<DataFormBodyState>();
      final selectedItem = <String, dynamic>{'food_name': 'old'};

      await tester.pumpWidget(
        ShadApp.custom(
          appBuilder: (context) => MaterialApp(
            home: Scaffold(
              body: DataFormBody(
                key: formKey,
                editorConfig: {
                  'fieldElements': [
                    {
                      'name': 'food_name',
                      'type': 'suggestion_dropdown',
                      'label': 'Food',
                      'suggestion_desc_fieldname': 'description',
                      'suggestion_id_fieldname': 'id',
                      'filter_api_url': 'fda_food_query',
                      'filter_search_param_name': 'food_name',
                      'filter_search_other_param': {'autocomplete': '1'},
                    },
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
      await tester.pump();

      await tester.enterText(_suggestionField(), 'Apple');

      expect(selectedItem['food_name'], 'Apple');
      expect(formKey.currentState!.submit(), isTrue);
      expect(saved!['food_name'], 'Apple');

      // Autocomplete starts a 500ms search debounce on each keystroke.
      // Advance it so the test binding does not see a pending timer.
      await tester.pump(const Duration(milliseconds: 500));
    },
  );
}
