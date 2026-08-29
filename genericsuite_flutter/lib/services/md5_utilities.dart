// MD5 Utilities

import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'utilities.dart';

const getHashDebug = false;

String getHash(String text) {
  final hashedText = md5.convert(utf8.encode(text)).toString();
  if (getHashDebug) {
    logDebug("Hashing text: '$text' -> '$hashedText'");
  }
  return hashedText;
}
