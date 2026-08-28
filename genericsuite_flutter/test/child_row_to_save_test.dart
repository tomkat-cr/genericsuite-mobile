import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/services/crud_editor_commons.dart';

void main() {
  group('buildChildRowToSave', () {
    final masterConfig = {'type': 'master_listing'};

    final childArrayConfig = {
      'type': 'child_listing',
      'subType': 'array',
      'array_name': 'food_times',
      'endpointKeyNames': [
        {'parameterName': 'user_id', 'parentElementName': 'id'},
      ],
      'parentData': {'_id': 'USER1', 'firstname': 'Carlos'},
    };

    final childTableConfig = {
      'type': 'child_listing',
      'subType': 'table',
      'endpointKeyNames': [
        {'parameterName': 'user_id', 'parentElementName': 'id'},
      ],
      'parentData': {'_id': 'USER1'},
    };

    test('master_listing passes the row through unchanged', () {
      final result = buildChildRowToSave(
        editorConfig: masterConfig,
        action: actionUpdate,
        rowId: 'ROW1',
        submittedItem: {'name': 'a', 'resultset': 'junk'},
        initialValues: {'name': 'old'},
      );
      expect(result['rowId'], 'ROW1');
      expect(result['rowToSave'], {'name': 'a'}); // resultset stripped
    });

    test('child_listing/array wraps new and old values with parent key', () {
      final result = buildChildRowToSave(
        editorConfig: childArrayConfig,
        action: actionUpdate,
        rowId: 'ROW1',
        submittedItem: {'food_moment_id': 'fm2', 'food_time': '10:00'},
        initialValues: {'food_moment_id': 'fm1', 'resultset': 'junk'},
      );
      expect(result['rowId'], isNull); // array children never send a rowId
      expect(result['rowToSave'], {
        'user_id': 'USER1',
        'food_times': {'food_moment_id': 'fm2', 'food_time': '10:00'},
        'food_times_old': {'food_moment_id': 'fm1'},
      });
    });

    test('child_listing/table merges parent key into the child row', () {
      final result = buildChildRowToSave(
        editorConfig: childTableConfig,
        action: actionCreate,
        rowId: null,
        submittedItem: {'note': 'hello'},
        initialValues: {},
      );
      expect(result['rowId'], isNull);
      expect(result['rowToSave'], {'note': 'hello', 'user_id': 'USER1'});
    });

    test('child_listing/array delete sends only the old element', () {
      final result = buildChildRowToSave(
        editorConfig: childArrayConfig,
        action: actionDelete,
        rowId: 'ROW1',
        submittedItem: {'food_moment_id': 'fm1', 'food_time': '09:00'},
        initialValues: {'food_moment_id': 'fm1', 'food_time': '09:00'},
      );
      expect(result['rowId'], isNull);
      expect(result['rowToSave']['food_times_old'], {
        'food_moment_id': 'fm1',
        'food_time': '09:00',
      });
    });
  });
}
