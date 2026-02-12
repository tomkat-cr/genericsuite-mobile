import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register a lazy singleton (created only when first used)
  locator.registerLazySingleton(() => FlutterSecureStorage());
}

/*
// Access it anywhere in your app where storage ir really needed

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genericsuite/services/locator_service.dart';

final storage = locator<FlutterSecureStorage>();
*/
