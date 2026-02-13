# CHANGELOG

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and [Keep a Changelog](http://keepachangelog.com/).



## [Unreleased] - YYYY-MM-DD

### Added

### Changed

### Fixed

### Security

### Removed


## [0.3.0] - 2026-02-13

### Added
- On "genericsuite_flutter":
  - Introduce `AppCallablesSuper` locator to centralize app navigation and callbacks [GS-261].
  - Introduce `routing_services` to have routeItem() available beyond the AppDrawer widget [GS-261].
  - Introduce `CreateGsApp` to standardize the app bootstrap [GS-261].
  - `getAppInfo`, `getMainScreenElements`, `mainScreenWidget`, and `runRedirectMainScreen` methods to the AppCallablesSuper class to avoid repeating the getMainScreen() and redirectMainScreen() with the same parameters all over the app [GS-261].

### Removed
- On "genericsuite_flutter":
  - The `appCallables` parameter of CrudEditor, logOut, showScaffoldMessage, showScaffoldMessages, getMainScreen, redirectMainScreen, HomePage, LoginPage, AppDrawer, and AppFrame [GS-261].
  - The `homePageBodyBuilder` and `alternateWidgetBuilder` parameters of logOut, HomePage, and LoginPage [GS-261].


## [0.2.0] - 2026-02-12

### Changed
- Path "genericsuite" renamed to "genericsuite_flutter" [GS-261].


## [0.1.1] - 2026-02-12

### Added
- On "genericsuite":
  - Introduce Ip address service to be used in the users onboarding [GS-252] [GS-261].

### Changed
- On "genericsuite":
  - Remove storage old code comments [GS-261].


## [0.1.0] - 2026-02-11

### Added
- On "genericsuite":
  - Introduce locator service to register the storage instance as a singleton [GS-261].
  - Introduce DeviceIdService for getting device id [GS-261].
  - Instructions and examples on the README.md [GS-261].
- On "flutter_project_template":
  - Introduce the `make clean_ios` command [GS-261].
  - `main.dart` file with a "Hello World" message [GS-261].
  - `genericsuite` package in the "pubspec.yaml" file [GS-261].
- Instructions to use the "flutter_project_template" and references to "genericsuite" on the main README.md [GS-261].

### Fixed:
- On "flutter_project_template":
  - Issues when copying the template to a new project on `ios/Runner.xcodeproj/project.pbxproj` [GS-261].
  - `MainActivity.kt` moved to `android/app/src/main/kotlin/com/example/gsexampleapp` [GS-261].
  - `docs_viewer.iml` renamed to `gsexampleapp.iml` [GS-261].
  - `docs_viewer_android.iml` renamed to `gsexampleapp_android.iml` [GS-261].

### Removed
- On "genericsuite":
  - Storage parameters were removed from the constructor of all services [GS-261].


## [0.0.1] - 2026-02-05

### Added
- GenericSuite mobile for flutter package and ExampleApp template [GS-261].
