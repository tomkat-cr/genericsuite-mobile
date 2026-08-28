import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/services/md5_utilities.dart';

void main() {
  group('getHash', () {
    test('returns the lowercase MD5 hex of the input text', () {
      expect(getHash('hello'), '5d41402abc4b2a76b9719d911017c592');
    });
  });
}
