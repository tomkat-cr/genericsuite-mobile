import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'app_callables_super.dart';

final GetIt storageLocator = GetIt.instance;

void setupStorageLocator([FlutterSecureStorage? storage]) {
  // Register a lazy singleton (created only when first used)
  if (storageLocator.isRegistered<FlutterSecureStorage>()) {
    return;
  }
  storageLocator.registerLazySingleton(() => storage ?? FlutterSecureStorage());
}

/*
// Access storage anywhere in your app where storage is needed to .read() or .write()

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genericsuite/services/locator_service.dart';

final storage = locator<FlutterSecureStorage>();
*/

final GetIt appCallablesLocator = GetIt.instance;

void setupAppCallablesLocator(AppCallablesSuper appCallables) {
  if (appCallablesLocator.isRegistered<AppCallablesSuper>()) {
    return;
  }
  appCallablesLocator.registerLazySingleton(() => appCallables);
}

/*
// Access the appCallables anywhere in your app where appCallables are needed

import 'package:genericsuite/services/app_callables_super.dart';

final appCallables = appCallablesLocator<AppCallablesSuper>();
*/
