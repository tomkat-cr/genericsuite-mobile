import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/services/crud_editor_commons.dart';
import 'package:genericsuite/services/crud_editor_sf_timestamps.dart';
import 'package:genericsuite/services/form_field_service.dart';
import 'package:genericsuite/services/timestamp_utilities.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// 2026-03-15 00:00:00 UTC and 2026-03-15 21:30:00 UTC.
const epochMidnight = 1773532800;
const epochEvening = 1773610200;

Map<String, dynamic> configFor(String type) => {
  'fieldElements': [
    {'name': 'when', 'type': type, 'label': 'When'},
  ],
};

void main() {
  group('timestampToDate uses the UTC calendar', () {
    test('formats stay the same and have no zone tail', () {
      expect(timestampToDate(timestamp: epochEvening), '2026-03-15');
      expect(
        timestampToDate(
          timestamp: epochEvening,
          fullDateTime: true,
          separator: ' ',
        ),
        '2026-03-15 21:30:00',
      );
      expect(
        timestampToDate(
          timestamp: epochEvening,
          fullDateTime: true,
          separator: 'T',
        ),
        '2026-03-15T21:30:00',
      );
      expect(
        timestampToDate(
          timestamp: epochEvening,
          fullDateTime: true,
          separator: ' ',
          militaryTime: false,
        ),
        '2026-03-15 9:30 PM',
      );
      expect(
        timestampToDate(
          timestamp: epochEvening,
          fullDateTime: true,
          militaryTime: false,
        ),
        '2026-03-15T9:30 PM',
      );
      expect(
        timestampToDate(timestamp: epochEvening, fullDateTime: true),
        '2026-03-15T21:30:00.000',
      );
    });
  });

  group('read then save returns the same epoch', () {
    for (final type in ['date', 'datetime-local']) {
      for (final epoch in [epochMidnight, epochEvening]) {
        test('$type $epoch, 3 times', () async {
          final config = configFor(type);
          dynamic value = epoch;
          for (var i = 0; i < 3; i++) {
            final read = await timestampDbPostRead(
              {'when': value},
              config,
              actionUpdate,
              {},
              null,
            );
            final shown = read['fieldValues']['when'];
            final saved = await timestampDbPreWrite(
              {'when': shown},
              config,
              actionUpdate,
              {},
              null,
            );
            expect(saved['error'], isEmpty);
            value = saved['fieldValues']['when'];
            expect(value, epoch, reason: 'pass ${i + 1}, shown: $shown');
          }
        });
      }
    }
  });

  test('timestampDbListPostRead shows the UTC date', () async {
    final result = await timestampDbListPostRead(
      <Map<String, dynamic>>[
        {'when': epochMidnight},
      ],
      configFor('date'),
      actionUpdate,
      {},
      null,
    );
    final shown = result['fieldValues'][0]['when'] as String;
    expect(shown, startsWith('2026-03-15'));
    expect(shown, '2026-03-15 00:00:00');
  });

  testWidgets('a yyyy-MM-dd value is shown and is not replaced by now', (
    tester,
  ) async {
    final selectedItem = <String, dynamic>{'when': '2026-03-15'};
    await tester.pumpWidget(
      ShadApp.custom(
        appBuilder: (context) => MaterialApp(
          home: Scaffold(
            body: DataFormBody(
              editorConfig: configFor('date'),
              constants: const {},
              selectedItem: selectedItem,
              callbacks: const {},
              currentUserData: const {},
              action: actionUpdate,
              saveItem: (Map<String, dynamic> item) {},
              setEditMode: (bool newEditMode) {},
              setError: (String message, String code, [int severity = 0]) {},
              props: const {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller!.text, '2026-03-15');
    expect(selectedItem['when'], '2026-03-15');
  });
}
