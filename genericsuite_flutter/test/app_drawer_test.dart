import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/widgets/app_drawer.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('menuItemValidation (dynamic-dispatched instance method)', () {
    Future<dynamic> pumpDrawerState(WidgetTester tester) async {
      await setUpTestLocators();
      // Scaffold.drawer is only built once the drawer is opened, so mount
      // AppDrawer as the body instead — that also gives showScaffoldMessage
      // (called via the post-frame binding) a Scaffold to attach the
      // SnackBar to.
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppDrawer())),
      );
      // Drain _loadConfig()'s rejection and the resulting SnackBar's
      // post-frame callback fully, so no pending callback leaks into (and
      // fires against a disposed context in) the next test.
      await tester.pumpAndSettle();
      return tester.state(find.byType(AppDrawer));
    }

    testWidgets('rejects items with no title', (tester) async {
      final state = await pumpDrawerState(tester);
      expect(state.menuItemValidation(<String, dynamic>{}), '');
    });

    testWidgets(
      'rejects items with no location/path/on_click unless type == editor',
      (tester) async {
        final state = await pumpDrawerState(tester);
        expect(state.menuItemValidation(<String, dynamic>{'title': 'X'}), '');
        expect(
          state.menuItemValidation(<String, dynamic>{
            'title': 'X',
            'type': 'editor',
            'element': 'SomeEditor',
          }),
          'SomeEditor',
        );
      },
    );

    testWidgets('rejects items whose sec_group is not accepted', (
      tester,
    ) async {
      final state = await pumpDrawerState(tester);
      expect(
        state.menuItemValidation(<String, dynamic>{
          'title': 'X',
          'path': '/x',
          'sec_group': 'admins',
        }),
        '',
      );
    });

    testWidgets('defaults sec_group to the default user group', (tester) async {
      final state = await pumpDrawerState(tester);
      final item = <String, dynamic>{
        'title': 'X',
        'path': '/x',
        'element': 'X',
      };
      expect(state.menuItemValidation(item), 'X');
      expect(item['sec_group'], 'users');
    });

    testWidgets(
      'rejects items with no element/on_click/function (inconsistent)',
      (tester) async {
        final state = await pumpDrawerState(tester);
        expect(
          state.menuItemValidation(<String, dynamic>{
            'title': 'X',
            'path': '/x',
          }),
          '',
        );
      },
    );

    testWidgets('returns on_click when element is empty', (tester) async {
      final state = await pumpDrawerState(tester);
      final item = <String, dynamic>{'title': 'X', 'on_click': 'doThing'};
      expect(state.menuItemValidation(item), 'doThing');
    });

    testWidgets('returns element when present, over on_click', (tester) async {
      final state = await pumpDrawerState(tester);
      final item = <String, dynamic>{
        'title': 'X',
        'path': '/x',
        'element': 'ElementName',
        'on_click': 'doThing',
      };
      expect(state.menuItemValidation(item), 'ElementName');
    });
  });

  group('AppDrawer config loading', () {
    testWidgets(
      'shows a loading indicator, then recovers to an empty menu (with '
      'session-expired messaging) when config loading fails, without '
      'throwing — this is the new catchError/mounted-guard branch',
      (tester) async {
        await setUpTestLocators();

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: AppDrawer())),
        );

        // First frame: _isLoading is still true.
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // _loadConfig() fails (no app_main_menu.json asset bundled in this
        // package's tests), landing in the new .catchError() branch, which
        // must not throw even though the drawer isn't visible/open.
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });

  group('_buildMenu leading icon (item[callable] == null defensive fix)', () {
    testWidgets(
      'does not crash building a ListTile leading icon when callable is '
      'null for a non-title item',
      (tester) async {
        await setUpTestLocators();
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: AppDrawer())),
        );
        await tester.pumpAndSettle();

        final dynamic state = tester.state(find.byType(AppDrawer));
        // Simulate a menu item resolved from the JSON config whose element
        // name has no matching entry in getMenuCallables() — 'callable'
        // ends up null. Before the fix, item['callable']['icon'] would
        // throw a NoSuchMethodError on null during _buildMenu().
        state.menuConfig = <Map<String, dynamic>>[
          {'type': 'widget', 'title': 'Orphan Item', 'callable': null},
        ];
        state.setState(() {});
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('Orphan Item'), findsOneWidget);
        expect(find.byType(Icon), findsNothing);
      },
    );
  });
}
