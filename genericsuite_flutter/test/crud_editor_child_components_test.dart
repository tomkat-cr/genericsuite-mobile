import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/services/crud_editor_child_components.dart';
import 'package:genericsuite/services/crud_editor_commons.dart';
import 'package:genericsuite/services/form_field_service.dart';

void main() {
  testWidgets('renders one navigation card per registered child and pushes it '
      'with parentData on tap', (tester) async {
    Map<String, dynamic>? receivedParentData;
    Map<String, dynamic>? receivedProps;

    final editorConfig = {
      'childComponents': ['UsersFoodTimes'],
    };
    final callbacks = {
      'childComponents': {
        'UsersFoodTimes':
            ({
              required Map<String, dynamic> parentData,
              Map<String, dynamic>? props,
            }) {
              receivedParentData = parentData;
              receivedProps = props;
              return const Scaffold(body: Text('CHILD SCREEN'));
            },
      },
    };
    final parentData = {'_id': 'USER1', 'firstname': 'Carlos'};

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: buildChildComponentSections(
                context: context,
                editorConfig: editorConfig,
                callbacks: callbacks,
                parentData: parentData,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Users Food Times'), findsOneWidget);

    await tester.tap(find.text('Users Food Times'));
    await tester.pumpAndSettle();

    expect(find.text('CHILD SCREEN'), findsOneWidget);
    expect(receivedParentData, parentData);
    expect(receivedProps?['isChildComponent'], true);
    expect(receivedProps?['showAppMenu'], false);
  });

  testWidgets('shows an error tile when the child builder is not registered',
      (tester) async {
    final editorConfig = {
      'childComponents': ['MissingChild'],
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: buildChildComponentSections(
                context: context,
                editorConfig: editorConfig,
                callbacks: const {},
                parentData: const {'_id': 'X'},
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Child component [MissingChild] Not Found'),
      findsOneWidget,
    );
  });

  test('childComponentLabel splits CamelCase names', () {
    expect(childComponentLabel('UsersFoodTimes'), 'Users Food Times');
    expect(childComponentLabel('UsersApiKey'), 'Users Api Key');
  });

  Widget dataFormApp(String action) {
    final editorConfig = {
      'fieldElements': [
        {
          'name': 'firstname',
          'label': 'First Name',
          'type': 'text',
          'required': false,
          'readonly': false,
        },
      ],
      'childComponents': ['UsersFoodTimes'],
    };
    final callbacks = {
      'childComponents': {
        'UsersFoodTimes':
            ({
              required Map<String, dynamic> parentData,
              Map<String, dynamic>? props,
            }) => const Scaffold(body: Text('CHILD SCREEN')),
      },
    };
    return MaterialApp(
      home: Scaffold(
        body: DataFormBody(
          editorConfig: editorConfig,
          constants: const {},
          selectedItem: {'_id': 'USER1', 'firstname': 'Carlos'},
          callbacks: callbacks,
          currentUserData: const {},
          action: action,
          saveItem: (item) {},
          setEditMode: (mode) {},
          setError: (msg, code, [severity = 0]) {},
        ),
      ),
    );
  }

  testWidgets('DataFormBody shows child sections in update mode',
      (tester) async {
    await tester.pumpWidget(dataFormApp(actionUpdate));
    expect(find.text('Users Food Times'), findsOneWidget);
  });

  testWidgets('DataFormBody hides child sections in create mode',
      (tester) async {
    await tester.pumpWidget(dataFormApp(actionCreate));
    expect(find.text('Users Food Times'), findsNothing);
  });
}
