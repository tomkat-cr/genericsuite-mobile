import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Diagnostic: does Autocomplete still show options with the same
/// fieldViewBuilder + Form + ListView setup used by suggestion_dropdown?
void main() {
  Future<void> pumpAutocomplete(
    WidgetTester tester, {
    required AutocompleteFieldViewBuilder? fieldViewBuilder,
  }) async {
    await tester.pumpWidget(
      ShadApp.custom(
        appBuilder: (context) => MaterialApp(
          home: Scaffold(
            body: Form(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Autocomplete<String>(
                    optionsBuilder: (value) async {
                      if (value.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return const ['Apple, raw', 'Apple juice'];
                    },
                    fieldViewBuilder:
                        fieldViewBuilder ??
                        (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            onChanged: (_) {},
                            onSaved: (_) {},
                            onFieldSubmitted: (_) => onFieldSubmitted(),
                          );
                        },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'custom fieldViewBuilder still shows options after async optionsBuilder',
    (tester) async {
      await pumpAutocomplete(tester, fieldViewBuilder: null);

      await tester.enterText(find.byType(TextField), 'App');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Apple, raw'), findsOneWidget);
      expect(find.text('Apple juice'), findsOneWidget);
    },
  );
}
