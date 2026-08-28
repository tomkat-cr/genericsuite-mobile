import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/services/autocomplete_service.dart';

void main() {
  group('suggestionRowsFromResultset', () {
    test('keeps an already-decoded list of rows', () {
      final rows = suggestionRowsFromResultset([
        {'id': '1', 'description': 'Apple, raw'},
        {'id': '2', 'description': 'Apple juice'},
      ]);

      expect(rows.length, 2);
      expect(rows.first['description'], 'Apple, raw');
    });

    test('decodes a JSON string resultset the way CRUD listings do', () {
      final rows = suggestionRowsFromResultset(
        jsonEncode([
          {'id': '1', 'description': 'Apple, raw'},
        ]),
      );

      expect(rows, [
        {'id': '1', 'description': 'Apple, raw'},
      ]);
    });

    test('unwraps a nested resultset map', () {
      final rows = suggestionRowsFromResultset({
        'resultset': [
          {'id': '1', 'description': 'Apple, raw'},
        ],
        'totalPages': 1,
      });

      expect(rows.length, 1);
      expect(rows.first['id'], '1');
    });
  });

  group('suggestionOptionLabels', () {
    test('returns non-empty string labels for Autocomplete', () {
      final labels = suggestionOptionLabels([
        {'description': 'Apple, raw'},
        {'description': ''},
        {'description': null},
        {'food_name': 'ignored'},
      ], 'description');

      expect(labels, ['Apple, raw']);
    });
  });
}
