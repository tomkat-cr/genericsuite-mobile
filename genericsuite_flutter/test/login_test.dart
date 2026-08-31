import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/genericsuite.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<dynamic> pumpLoginState(
    WidgetTester tester, {
    Map<String, dynamic>? params,
  }) async {
    await setUpTestLocators();
    await tester.pumpWidget(MaterialApp(home: LoginPage(params: params)));
    await tester.pumpAndSettle();
    // LoginPage always renders a hardcoded logo asset that doesn't exist in
    // this package's test bundle; drain that expected, harmless load error
    // so it doesn't get mistaken for (or mask) a real failure later.
    final pendingError = tester.takeException();
    if (pendingError != null) {
      expect(pendingError.toString(), contains('app_logo_circle.png'));
    }
    return tester.state(find.byType(LoginPage));
  }

  group('validateUserPass (dynamic-dispatched instance method)', () {
    testWidgets('rejects a username shorter than 4 characters', (tester) async {
      final state = await pumpLoginState(tester);
      final result = state.validateUserPass('abc', 'longenough');
      expect(result['error'], 'Invalid username');
    });

    testWidgets('rejects a password shorter than 2 characters', (tester) async {
      final state = await pumpLoginState(tester);
      final result = state.validateUserPass('gooduser', 'a');
      expect(result['error'], 'Invalid password');
    });

    testWidgets('accepts a username/password that both meet the minimum '
        'length', (tester) async {
      final state = await pumpLoginState(tester);
      final result = state.validateUserPass('gooduser', 'ok');
      expect(result['error'], '');
      expect(result['message'], '');
    });
  });

  group('LoginPage widget', () {
    testWidgets('renders username/password fields and the action buttons', (
      tester,
    ) async {
      await pumpLoginState(tester);

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    });

    testWidgets('shows a default welcome message keyed off getAppInfo() '
        'when params is non-null but has no onboardingMessage', (tester) async {
      await pumpLoginState(tester, params: const {});
      expect(find.text('Welcome to Test App'), findsOneWidget);
    });

    testWidgets('an explicit onboardingMessage param overrides the default', (
      tester,
    ) async {
      await pumpLoginState(
        tester,
        params: {'onboardingMessage': 'Custom greeting'},
      );
      expect(find.text('Custom greeting'), findsOneWidget);
      expect(find.text('Welcome to Test App'), findsNothing);
    });

    testWidgets(
      'tapping Log In with both fields empty shows the validation error '
      'via a SnackBar, without making a network call',
      (tester) async {
        await pumpLoginState(tester);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
        // The validation-error branch of _processLogin returns before any
        // HTTP call, so this must never hang waiting on the network.
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(SnackBar), findsOneWidget);
        // _processLogin surfaces validateUserPass()'s short `error` label
        // (not its longer `message`) as the SnackBar text.
        expect(find.text('Invalid username'), findsOneWidget);
      },
    );

    testWidgets('does not crash when disposed', (tester) async {
      await pumpLoginState(tester);
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
