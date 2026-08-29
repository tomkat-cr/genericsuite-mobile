import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:genericsuite/genericsuite.dart';
import 'package:get_it/get_it.dart';

/// In-memory replacement for the platform channel flutter_secure_storage
/// talks to, so tests can read/write without a real device/platform.
class FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  final Map<String, String> store = {};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    store[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    return store[key];
  }

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async {
    return store.containsKey(key);
  }

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    store.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async {
    return Map<String, String>.from(store);
  }

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    store.clear();
  }
}

/// Minimal AppCallablesSuper override providing just enough for the views
/// under test (LoginPage/AppDrawer/AppFrame) to build without throwing the
/// UnimplementedError of the base class.
class StubAppCallables extends AppCallablesSuper {
  @override
  Map<String, dynamic> getAppInfo() => {'name': 'Test App'};

  @override
  Map<String, dynamic> getMenuCallables() => {};

  // The default theme points at real image assets (app_logo_horizontal.png)
  // that only exist in consumer apps, not in this package's test bundle.
  // Zeroing the paths keeps widget tests from tripping asynchronous
  // "asset not found" image-loading errors that bleed into later tests.
  @override
  Map<String, dynamic> getThemeParams() {
    final params = super.getThemeParams();
    return {...params, 'appBarLogoPath': '', 'drawerHeaderLogoPath': ''};
  }
}

/// Resets the shared GetIt registry and re-registers a fake secure storage
/// (backed by [FakeSecureStoragePlatform]) plus [appCallables] so views that
/// pull dependencies from storageLocator/appCallablesLocator can build in a
/// widget test.
Future<FakeSecureStoragePlatform> setUpTestLocators({
  AppCallablesSuper? appCallables,
}) async {
  await GetIt.instance.reset();
  // rootBundle caches the Future returned by loadString() per key,
  // including rejected ones (missing-asset errors). Without clearing it,
  // widgets that load a missing asset (e.g. AppDrawer's menu config) reuse
  // a stale cached Future across tests, which has been observed to leave a
  // frame scheduled forever and hang a later test's pumpAndSettle().
  rootBundle.clear();
  final fakePlatform = FakeSecureStoragePlatform();
  FlutterSecureStoragePlatform.instance = fakePlatform;
  storageLocator.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  appCallablesLocator.registerLazySingleton<AppCallablesSuper>(
    () => appCallables ?? StubAppCallables(),
  );
  return fakePlatform;
}
