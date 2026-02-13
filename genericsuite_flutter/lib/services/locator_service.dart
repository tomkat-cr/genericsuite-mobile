import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'app_callables_super.dart';

final GetIt locator = GetIt.instance;

void setupStorageLocator() {
  // Register a lazy singleton (created only when first used)
  locator.registerLazySingleton(() => FlutterSecureStorage());
}

/*
// Access it anywhere in your app where storage is needed to .read() or .write()

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genericsuite/services/locator_service.dart';

final storage = locator<FlutterSecureStorage>();
*/

final GetIt appCallablesLocator = GetIt.instance;

void setupAppCallablesLocator(AppCallablesSuper appCallables) {
  // Register a lazy singleton (created only when first used)
  appCallablesLocator.registerLazySingleton(() => appCallables);
}

/*
// Access the appCallables anywhere in your app where appCallables are needed

import 'package:genericsuite/services/app_callables_super.dart';

final appCallables = appCallablesLocator<AppCallablesSuper>();
*/
