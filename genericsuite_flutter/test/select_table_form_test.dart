import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/services/form_field_service.dart';

const String _actionRead = 'read';
const String _actionUpdate = 'update';

Widget _buildTestWidget({required bool readOnly}) {
  final editorConfig = {
    'fieldElements': [
      {
        'name': 'user_id',
        'type': 'select_table',
        'related_table': 'users',
        'label': 'User',
        'readonly': readOnly,
      },
    ],
    'selectFieldsOptionsPromises': {
      'user_id': {
        'promiseResult': {'aaa': 'John Doe', 'bbb': 'Jane Roe'},
      },
    },
  };
  final selectedItem = {'user_id': 'aaa', 'user_id_description': 'John Doe'};

  return MaterialApp(
    home: Scaffold(
      body: DataFormBody(
        editorConfig: editorConfig,
        constants: const {},
        selectedItem: selectedItem,
        callbacks: const {},
        currentUserData: const {},
        action: readOnly ? _actionRead : _actionUpdate,
        saveItem: (Map<String, dynamic> item) {},
        setEditMode: (bool newEditMode) {},
        setError: (String message, String code, [int severity = 0]) {},
        props: const {},
      ),
    ),
  );
}

void main() {
  testWidgets('select_table read-only shows description text',
      (tester) async {
    await tester.pumpWidget(_buildTestWidget(readOnly: true));
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
  });

  testWidgets('select_table edit mode shows dropdown with options',
      (tester) async {
    await tester.pumpWidget(_buildTestWidget(readOnly: false));
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.text('Jane Roe'), findsWidgets);
  });
}
