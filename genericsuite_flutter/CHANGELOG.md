# CHANGELOG

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and [Keep a Changelog](http://keepachangelog.com/).



## [Unreleased] - YYYY-MM-DD

### Added

### Changed

### Fixed

### Security

### Removed


## [0.4.1] - 2026-02-15

### Added
- Implement `getStorage` method in `AppCallablesSuper` to provide a customizable `FlutterSecureStorage` instance [GS-261].


## [0.4.0] - 2026-02-14

### Added
- Add `devtools_options.yaml` to the project [GS-261].
- Add `newUserJsonFileName` parameter in `login.dart` "params" map so the "onboarding_users.json" configuration can be customized [GS-261].

### Changed
- Rename `locator` to `storageLocator` for `FlutterSecureStorage` access [GS-261].
- Update widget key syntax on autocomplete_service.dart and form_field_service.dart [GS-261].


## [0.3.1] - 2026-02-13

### Fixed
- Fix `CreateGsApp` widget to properly initialize the app and display the main screen [GS-261].


## [0.3.0] - 2026-02-13

### Added
- Introduce `AppCallablesSuper` locator to centralize app navigation and callbacks [GS-261].
- Introduce `routing_services` to have routeItem() available beyond the AppDrawer widget [GS-261].
- Introduce `CreateGsApp` to standardize the app bootstrap [GS-261].
- `getAppInfo`, `getMainScreenElements`, `mainScreenWidget`, and `runRedirectMainScreen` methods to the AppCallablesSuper class to avoid repeating the getMainScreen() and redirectMainScreen() with the same parameters all over the app [GS-261].

### Removed
- The `appCallables` parameter of CrudEditor, logOut, showScaffoldMessage, showScaffoldMessages, getMainScreen, redirectMainScreen, HomePage, LoginPage, AppDrawer, and AppFrame [GS-261].
- The `homePageBodyBuilder` and `alternateWidgetBuilder` parameters of logOut, HomePage, and LoginPage [GS-261].


## [0.2.0] - 2026-02-12

### Changed
- Path "genericsuite" renamed to "genericsuite_flutter" [GS-261].


## [0.1.1] - 2026-02-12

### Added
- Introduce Ip address service to be used in the users onboarding [GS-252] [GS-261].

### Changed
- Remove storage old code comments [GS-261].


## [0.1.0] - 2026-02-11

### Added
- Introduce locator service to register the storage instance as a singleton [GS-261].
- Introduce DeviceIdService for getting device id [GS-261].

### Removed
- Storage parameters were removed from the constructor of all services [GS-261].


## [0.0.1] - 2026-02-05

### Added
- Initial development of GenericSuite mobile for Flutter package [GS-261].
