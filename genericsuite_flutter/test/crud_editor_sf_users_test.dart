import 'package:flutter_test/flutter_test.dart';
import 'package:genericsuite/services/crud_editor_commons.dart';
import 'package:genericsuite/services/crud_editor_sf_users.dart';

void main() {
  group('generateAccessToken', () {
    test('returns hex of the requested byte length', () {
      final token = generateAccessToken(8);
      expect(token.length, 16);
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(token), isTrue);
    });

    test('default length is 64 bytes (128 hex chars)', () {
      expect(generateAccessToken().length, 128);
    });

    test('successive tokens differ', () {
      expect(generateAccessToken(), isNot(generateAccessToken()));
    });
  });

  group('usersApiKeyDbPreRead', () {
    final editorConfig = <String, dynamic>{};
    final params = <String, dynamic>{};

    test('on create sets fieldValues.resultset.access_token with prefix',
        () async {
      final result = await usersApiKeyDbPreRead(
        {'name': 'new key'},
        editorConfig,
        actionCreate,
        params,
        null,
      );

      expect(result['error'], '');
      expect(result['fieldValues']['name'], 'new key');
      final accessToken =
          result['fieldValues']['resultset']['access_token'] as String;
      expect(accessToken.startsWith(apiKeysPrefix), isTrue);
      expect(
        accessToken.substring(apiKeysPrefix.length).length,
        128,
      );
    });

    test('on update leaves fieldValues as the input data', () async {
      final data = {'access_token': 'existing'};
      final result = await usersApiKeyDbPreRead(
        data,
        editorConfig,
        actionUpdate,
        params,
        null,
      );

      expect(result['error'], '');
      expect(result['fieldValues'], data);
      expect(result['fieldValues'].containsKey('resultset'), isFalse);
    });
  });
}
