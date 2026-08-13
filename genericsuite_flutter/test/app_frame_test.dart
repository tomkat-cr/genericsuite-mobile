import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/genericsuite.dart';
import 'package:genericsuite/widgets/app_frame.dart';

import 'test_helpers.dart';

class _TitleTextThemeCallables extends StubAppCallables {
  @override
  Map<String, dynamic> getThemeParams() {
    final params = super.getThemeParams();
    return {
      ...params,
      'appBarLogoPath': '',
      'appBarTitleText': 'GS App Bar Title',
    };
  }
}

class _NoBrandingThemeCallables extends StubAppCallables {
  @override
  Map<String, dynamic> getThemeParams() {
    final params = super.getThemeParams();
    return {...params, 'appBarLogoPath': '', 'appBarTitleText': ''};
  }
}

Widget wrap(Widget child) => MaterialApp(home: child);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('an explicit title takes priority over the theme logo/text', (
    tester,
  ) async {
    await setUpTestLocators(appCallables: _TitleTextThemeCallables());

    await tester.pumpWidget(
      wrap(AppFrame(title: 'Explicit Title', body: const SizedBox())),
    );
    await tester.pump();

    expect(find.text('Explicit Title'), findsOneWidget);
    expect(find.text('GS App Bar Title'), findsNothing);
  });

  testWidgets(
    'falls back to appBarTitleText when no title/logo is configured',
    (tester) async {
      await setUpTestLocators(appCallables: _TitleTextThemeCallables());

      await tester.pumpWidget(wrap(AppFrame(body: const SizedBox())));
      await tester.pump();

      expect(find.text('GS App Bar Title'), findsOneWidget);
    },
  );

  testWidgets(
    'shows an empty app bar title slot when neither title, logo nor '
    'appBarTitleText are configured',
    (tester) async {
      await setUpTestLocators(appCallables: _NoBrandingThemeCallables());

      await tester.pumpWidget(wrap(AppFrame(body: const SizedBox())));
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    },
  );

  testWidgets('showBackButton renders a back arrow that pops the route', (
    tester,
  ) async {
    await setUpTestLocators(appCallables: _NoBrandingThemeCallables());
    bool actionCalled = false;

    await tester.pumpWidget(
      wrap(
        AppFrame(
          body: const SizedBox(),
          showBackButton: true,
          action: () => actionCalled = true,
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pump();

    expect(actionCalled, true);
  });

  testWidgets(
    'showAppMenu false hides the hamburger leading icon and omits the drawer',
    (tester) async {
      await setUpTestLocators(appCallables: _NoBrandingThemeCallables());

      await tester.pumpWidget(
        wrap(AppFrame(body: const SizedBox(), showAppMenu: false)),
      );
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, isNull);
    },
  );
}
