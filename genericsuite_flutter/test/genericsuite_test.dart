import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/genericsuite.dart';

void main() {
  test('AppCallablesSuper class', () {
    final appCallablesInstance = AppCallablesSuper();
    expect(
      appCallablesInstance.getThemeParams()['primarySwatch'],
      primarySwatch,
    );
  });
}
