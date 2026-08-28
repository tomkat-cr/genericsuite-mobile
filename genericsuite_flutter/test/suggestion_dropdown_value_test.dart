import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/services/autocomplete_service.dart';

void main() {
  group('applySuggestionTypedValue', () {
    test('writes the typed text onto the form field name', () {
      final selectedItem = <String, dynamic>{'food_name': 'old'};

      applySuggestionTypedValue(selectedItem, 'food_name', 'Apple');

      expect(selectedItem['food_name'], 'Apple');
    });
  });

  group('applySuggestionSelectedValue', () {
    test(
      'writes the form field and autocomplete_fields, not related-table keys',
      () {
        final selectedItem = <String, dynamic>{'food_name': 'old'};
        final encoded = jsonEncode({
          'id': 'fda-1',
          'description': 'Apple, raw',
          'calories_value': 52,
          'calories_unit': 'kcal',
        });

        applySuggestionSelectedValue(
          selectedItem: selectedItem,
          config: {
            'suggestion_desc_fieldname': 'description',
            'suggestion_name_fieldname': 'description',
            'autocomplete_fields': {
              'calories_value': 'calories_value',
              'calories_unit': 'calories_unit',
            },
          },
          fieldName: 'food_name',
          encodedValue: encoded,
        );

        expect(selectedItem, {
          'food_name': 'Apple, raw',
          'calories_value': 52,
          'calories_unit': 'kcal',
        });
      },
    );

    test(
      'does not copy related-table _id/name onto a child row (food_times)',
      () {
        final selectedItem = <String, dynamic>{
          'food_moment_id': '622d0c3484f18c6771bc4148',
          'food_time': '15:00 456',
          'meal_type': 'Breakfast',
          'meal_time': '09:00 AM',
        };
        final encoded = jsonEncode({
          '_id': {r'$oid': '655297a66767cc02a1d79a79'},
          'name': 'Other',
        });

        applySuggestionSelectedValue(
          selectedItem: selectedItem,
          config: {
            'suggestion_id_fieldname': '_id',
            'suggestion_desc_fieldname': 'name',
          },
          fieldName: 'meal_type',
          encodedValue: encoded,
        );

        expect(selectedItem, {
          'food_moment_id': '622d0c3484f18c6771bc4148',
          'food_time': '15:00 456',
          'meal_type': 'Other',
          'meal_time': '09:00 AM',
        });
        expect(selectedItem.containsKey('_id'), isFalse);
        expect(selectedItem.containsKey('name'), isFalse);
      },
    );

    test('does not write when the suggestion description is empty', () {
      final selectedItem = <String, dynamic>{'food_name': 'old'};

      applySuggestionSelectedValue(
        selectedItem: selectedItem,
        config: {
          'suggestion_desc_fieldname': 'description',
          'suggestion_name_fieldname': 'description',
        },
        fieldName: 'food_name',
        encodedValue: jsonEncode({'id': 'fda-1', 'description': ''}),
      );

      expect(selectedItem, {'food_name': 'old'});
    });
  });
}
