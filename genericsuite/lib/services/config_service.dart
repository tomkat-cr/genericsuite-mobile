import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'utilities.dart';

const csDebug = false;

class ConfigService {
  static Future<Map<String, dynamic>> getConfigItems() {
    // Here you would fetch the base URL from a config file
    return _readConfigFile();
  }

  static Future<Map<String, dynamic>> _readConfigFile() async {
    // https://stackoverflow.com/questions/44816042/flutter-read-text-file-from-assets
    final String configContentStage = await rootBundle.loadString(
      'assets/config/stage.json',
    );
    final Map<String, dynamic> stage = json.decode(configContentStage);
    if (csDebug) {
      logDebug('_readConfigFile | get stage result: ${stage.toString()}');
    }
    final String configContent = await rootBundle.loadString(
      'assets/config/config-${stage['STAGE']}.json',
    );
    final Map<String, dynamic> result = json.decode(configContent);
    if (csDebug) {
      logDebug('_readConfigFile | get config result: ${result.toString()}');
    }
    return result;
  }
}
