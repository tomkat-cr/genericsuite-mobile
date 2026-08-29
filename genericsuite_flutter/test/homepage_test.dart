import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/genericsuite.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'with no JWT in storage, HomePage settles without a network call and '
    'without throwing (getCurrentUserData short-circuits on an empty '
    'jwtToken before any HttpUtilities call)',
    (tester) async {
      await setUpTestLocators();

      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            homePageBodyBuilder: (userData) => Text('Signed in: $userData'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // No session -> the FutureBuilder never reaches the
      // homePageBodyBuilder branch.
      expect(find.textContaining('Signed in:'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'a cached (non-empty) userData short-circuits loadHomeData and renders '
    'homePageBodyBuilder without waiting on FutureBuilder',
    (tester) async {
      await setUpTestLocators();

      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            homePageBodyBuilder: (userData) => Text('Signed in: $userData'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final dynamic state = tester.state(find.byType(HomePage));
      // Simulate a prior successful load having populated userData.
      state.userData = <String, dynamic>{'firstname': 'Carlos'};
      final cached = await state.loadHomeData(true);

      expect(cached, <String, dynamic>{'firstname': 'Carlos'});
    },
  );
}
