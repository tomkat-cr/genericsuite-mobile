import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/widgets/crud_busy_body.dart';

void main() {
  testWidgets('keeps the form mounted while the loading spinner is shown',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CrudBusyBody(
            isLoading: true,
            child: Text('FORM STAYS'),
          ),
        ),
      ),
    );

    expect(find.text('FORM STAYS'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
      'does not throw an overlay assertion when loading starts while a '
      'dropdown is open', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ToggleBusyScaffold()));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsWidgets);

    final state = tester.state<_ToggleBusyScaffoldState>(
      find.byType(_ToggleBusyScaffold),
    );
    state.setLoading(true);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });
}

class _ToggleBusyScaffold extends StatefulWidget {
  const _ToggleBusyScaffold();

  @override
  State<_ToggleBusyScaffold> createState() => _ToggleBusyScaffoldState();
}

class _ToggleBusyScaffoldState extends State<_ToggleBusyScaffold> {
  bool _isLoading = false;

  void setLoading(bool value) => setState(() => _isLoading = value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CrudBusyBody(
        isLoading: _isLoading,
        child: DropdownButtonFormField<String>(
          key: const ValueKey('busy-dropdown'),
          initialValue: 'a',
          items: const [
            DropdownMenuItem(value: 'a', child: Text('Alpha')),
            DropdownMenuItem(value: 'b', child: Text('Beta')),
          ],
          onChanged: (_) {},
        ),
      ),
    );
  }
}
