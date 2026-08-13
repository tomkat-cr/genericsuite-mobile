import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/widgets/error_reporter_widget.dart';

void main() {
  testWidgets(
    'ErrorReporter does not call ScaffoldMessenger during build '
    '(showSnackBar deferred to the post-frame callback)',
    (tester) async {
      // Regression test: showSnackBar() used to be called synchronously
      // inside build(), which throws
      // "setState() or markNeedsBuild() called during build" because
      // ScaffoldMessenger schedules a rebuild of its own state while this
      // widget's own build is still in progress. pumpWidget must not throw.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ErrorReporter(message: 'boom')),
        ),
      );

      // Immediately after the first build (before the post-frame callback
      // has run) the SnackBar must not be visible yet.
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);

      // Once the post-frame callback fires, the SnackBar shows the message.
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Error: boom'), findsOneWidget);
    },
  );

  testWidgets('ErrorReporter renders nothing visible besides the SnackBar '
      'when showScaffold is true', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ErrorReporter(message: 'x'))),
    );
    await tester.pump();

    // The inline Column/ButtonBack fallback (the showScaffold == false
    // branch) must not be rendered here.
    expect(find.widgetWithText(ElevatedButton, 'Back'), findsNothing);
  });

  testWidgets(
    'ErrorReporter does not crash when its widget tree is replaced before '
    'settling',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ErrorReporter(message: 'unmount-me')),
        ),
      );

      // Replace the tree right away, exercising the context.mounted guard
      // around the deferred showSnackBar call.
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );
}
