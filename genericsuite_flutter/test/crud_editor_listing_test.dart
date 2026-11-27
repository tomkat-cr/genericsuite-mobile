import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/services/crud_editor_listing.dart';
import 'package:genericsuite/services/theme_config_defaults.dart';
import 'package:genericsuite/services/timestamp_utilities.dart';

void main() {
  group('toNonNegativeInt', () {
    test('accepts int, num and numeric String', () {
      expect(toNonNegativeInt(2, 9), 2);
      expect(toNonNegativeInt(3.0, 9), 3);
      expect(toNonNegativeInt('4', 9), 4);
      expect(toNonNegativeInt(' 5 ', 9), 5);
    });
    test('invalid values use the fallback; negative gives 0', () {
      expect(toNonNegativeInt('abc', 9), 9);
      expect(toNonNegativeInt(null, 9), 9);
      expect(toNonNegativeInt(true, 9), 9);
      expect(toNonNegativeInt(-3, 9), 0);
      expect(toNonNegativeInt('-3', 9), 0);
    });
  });

  group('resolveListingCols', () {
    test('uses the default when no JSON and no props', () {
      expect(
        resolveListingCols(
          key: 'colsForListingLine1',
          props: null,
          editorConfig: {},
          defaultValue: 1,
        ),
        1,
      );
    });
    test('reads the JSON value', () {
      expect(
        resolveListingCols(
          key: 'colsForListingLine2',
          props: null,
          editorConfig: {'colsForListingLine2': '2'},
          defaultValue: 0,
        ),
        2,
      );
    });
    test('props override the JSON', () {
      expect(
        resolveListingCols(
          key: 'colsForListingLine1',
          props: {'colsForListingLine1': 3},
          editorConfig: {'colsForListingLine1': 2},
          defaultValue: 1,
        ),
        3,
      );
    });
    test('invalid JSON value uses the default', () {
      expect(
        resolveListingCols(
          key: 'colsForListingLine1',
          props: null,
          editorConfig: {'colsForListingLine1': 'x'},
          defaultValue: 1,
        ),
        1,
      );
    });
  });

  group('clampListingCols', () {
    test('line1 + line2 does not pass the listing fields count', () {
      final r = clampListingCols(2, 5, 4);
      expect(r.line1, 2);
      expect(r.line2, 2);
      final r2 = clampListingCols(9, 1, 3);
      expect(r2.line1, 3);
      expect(r2.line2, 0);
    });
    test('title fallback: line1 0 becomes 1', () {
      final r = clampListingCols(0, 2, 3);
      expect(r.line1, 1);
      expect(r.line2, 2);
    });
    test('no listing fields keeps non-negative values', () {
      final r = clampListingCols(0, 0, 0);
      expect(r.line1, 0);
      expect(r.line2, 0);
    });
  });

  group('formatListingValue', () {
    test('select shows the label, or the raw value without a label', () {
      final field = {'name': 'role', 'type': 'select'};
      expect(
        formatListingValue(field, {'role': 'a'}, selectOptions: {'a': 'Admin'}),
        'Admin',
      );
      expect(
        formatListingValue(field, {'role': 'z'}, selectOptions: {'a': 'Admin'}),
        'z',
      );
      expect(formatListingValue(field, {'role': 'z'}), 'z');
    });
    test('select_table uses description, then options, then raw', () {
      final field = {'name': 'owner', 'type': 'select_table'};
      expect(
        formatListingValue(field, {'owner': '1', 'owner_description': 'Ann'}),
        'Ann',
      );
      expect(
        formatListingValue(field, {'owner': '1'}, selectOptions: {'1': 'Bob'}),
        'Bob',
      );
      expect(formatListingValue(field, {'owner': '1'}), '1');
    });
    test('date and datetime formats', () {
      final d = {'name': 'd', 'type': 'date'};
      final dt = {'name': 'd', 'type': 'datetime-local'};
      expect(formatListingValue(d, {'d': '2026-03-04T10:20:30'}), '2026-03-04');
      expect(
        formatListingValue(dt, {'d': '2026-03-04 10:20:30'}),
        '2026-03-04 10:20',
      );
      final epoch = DateTime.utc(2026, 3, 4, 10, 20).millisecondsSinceEpoch;
      expect(formatListingValue(dt, {'d': epoch}), '2026-03-04 10:20');
      // Epoch seconds near midnight UTC keep the UTC calendar date, the
      // same as timestampToDate() in the form (no device zone shift).
      final seconds =
          DateTime.utc(2026, 3, 4, 0, 30).millisecondsSinceEpoch ~/ 1000;
      expect(formatListingValue(d, {'d': seconds}), '2026-03-04');
      expect(
        formatListingValue(d, {'d': seconds}),
        timestampToDate(timestamp: seconds),
      );
      expect(formatListingValue(d, {'d': 'not a date'}), 'not a date');
    });
    test('boolean shows Yes / No', () {
      final b = {'name': 'b', 'type': 'boolean'};
      expect(formatListingValue(b, {'b': true}), 'Yes');
      expect(formatListingValue(b, {'b': false}), 'No');
      expect(
        formatListingValue({'name': 'b', 'type': 'checkbox'}, {'b': 'true'}),
        'Yes',
      );
      expect(formatListingValue(b, {'b': 0}), 'No');
    });
    test('null and empty values give an empty string', () {
      for (final type in [
        'text',
        'select',
        'date',
        'boolean',
        'select_table',
      ]) {
        final f = {'name': 'x', 'type': type};
        expect(formatListingValue(f, {}), '');
        expect(formatListingValue(f, {'x': null}), '');
        expect(formatListingValue(f, {'x': ''}), '');
      }
    });
    test('other types show the raw value', () {
      expect(
        formatListingValue({'name': 'n', 'type': 'number'}, {'n': 5}),
        '5',
      );
    });
  });

  group('joinListingValues', () {
    test('joins non-empty values with the separator', () {
      expect(joinListingValues(['a', '', 'b', '  '], ' · '), 'a · b');
      expect(joinListingValues(['a', 'b'], ' | '), 'a | b');
      expect(joinListingValues(['', ''], ' · '), '');
    });
  });

  group('row colors', () {
    test('defaults: even gray, odd transparent', () {
      expect(listingRowBackgroundColor(0, null), const Color(0xFFE5E7EB));
      expect(listingRowBackgroundColor(1, {}), Colors.transparent);
      expect(listingRowBackgroundColor(2, {}), const Color(0xFFE5E7EB));
      expect(listingRowTextColor(0, {}), textColor);
      expect(listingRowTextColor(1, {}), textColor);
    });
    test('overrides from theme params, other keys use defaults', () {
      final params = <String, dynamic>{
        'listingRowEvenBackgroundColor': Colors.red,
        'listingRowOddBackgroundColor': Colors.blue,
        'listingRowOddTextColor': Colors.white,
      };
      expect(listingRowBackgroundColor(0, params), Colors.red);
      expect(listingRowBackgroundColor(1, params), Colors.blue);
      expect(listingRowTextColor(1, params), Colors.white);
      expect(listingRowTextColor(0, params), textColor);
      expect(
        getListingThemeParam(params, 'listingRowSubtitleColor'),
        secondaryTextColor,
      );
    });
  });
}
