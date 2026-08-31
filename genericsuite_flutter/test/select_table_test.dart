import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/services/crud_editor_selector.dart';

void main() {
  final currentObj = {
    'name': 'user_id',
    'type': 'select_table',
    'related_table': 'users',
    'description_fields': ['firstname', 'lastname'],
  };

  test('select_table uses backend-resolved description when present', () {
    final result = getSelectDescription(
      currentObj: currentObj,
      dbRow: {'user_id': 'aaa', 'user_id_description': 'John Doe'},
      constants: {},
      selectFieldsOptionsPromises: {},
    );
    expect(result, 'John Doe');
  });

  test('select_table falls back to prefetched options map', () {
    final result = getSelectDescription(
      currentObj: currentObj,
      dbRow: {'user_id': 'aaa'},
      constants: {},
      selectFieldsOptionsPromises: {
        'user_id': {
          'promiseResult': {'aaa': 'John Doe'},
        },
      },
    );
    expect(result, 'John Doe');
  });

  test('select_table returns null for null FK', () {
    final result = getSelectDescription(
      currentObj: currentObj,
      dbRow: {},
      constants: {},
      selectFieldsOptionsPromises: {},
    );
    expect(result, null);
  });

  test('buildSelectTableDescriptionMap builds id->description map', () {
    final map = buildSelectTableDescriptionMap([
      {'_id': 'aaa', 'firstname': 'John', 'lastname': 'Doe'},
      {'_id': 'bbb', 'firstname': 'Jane'},
    ], currentObj);
    expect(map, {'aaa': 'John Doe', 'bbb': 'Jane'});
  });
}
