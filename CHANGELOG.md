# CHANGELOG

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and [Keep a Changelog](http://keepachangelog.com/).



## [0.4.0] - 2026-07-15

### Added
- `childComponents` (1-N relationships) support in the Flutter CRUD Editor: child components declared in the frontend JSON config render as tappable sections in the edit form, open full-screen with the parent row as `parentData`, and support `child_listing` editors with `array` and `table` subtypes (including the `<array_name>`/`<array_name>_old` write payloads), matching the genericsuite-fe CRUD Editor behavior [GS-261].
- Apple-clean theme tokens in `theme_config_defaults.dart` (`accentColor`, `borderRadius` 12px, `fontFamily`/`textTheme` typography tokens with Inter via google_fonts, near-black `textColor`, iOS system semantic colors) plus a `defaultThemeParams` merge contract so apps override only the keys they need [GS-261].
- `shadcn_ui` (flutter-shadcn-ui port) now owns the widget-tree root via `ShadApp.custom`; `CreateGsApp` builds the MaterialApp theme from the GenericSuite tokens; Save/Cancel form buttons use ShadButton [GS-261].
- `buildGsShadTheme()` builds `ShadThemeData` from GenericSuite theme tokens; new `shadColorSchemeName` theme param selects the shadcn base scheme (`green` default; any `ShadColorScheme.fromName` value), with `accentColor` overriding `primary`/`ring` and GS surface/text/error tokens applied via `copyWith` [GS-261].

### Changed
- Default accent color changed from blue to green; app bar and drawer default to white surfaces with near-black text; genericsuite_flutter version bumped to 0.5.0 [GS-261].

### Removed
- `flutter_project_template` directory. Use [genericsuite-mobile-exampleapp](https://github.com/tomkat-cr/genericsuite-mobile-exampleapp) instead [GS-261].


## [0.3.2] - 2026-04-20

### Added
- AGENTS.md, GEMINI.md, and CLAUDE.md files to provide context and instructions to AI Coding Assistants [GS-303].
- Add SAST testing [GS-315].
- `select_table` field type in the Flutter CRUD editor: listing and read-only form show the related record description (backend `{field}_description` with client-side cached fallback); create/edit renders a dropdown populated from the related table [GS-259].

### Change
- Minor fixes on README.md files
- License changed to MIT [FA-244].
- Update .gitignore to include AI agent directories [GS-303].

### Fixes
- Improve error handling in create_gs_app.dart and ip_address_service.dart for better stability and fix Flutter web deployment to bootstrap [GS-252].


## [0.3.1] - 2026-02-13

### Fixed
- On "genericsuite_flutter":
  - Fix `CreateGsApp` widget to properly initialize the app and display the main screen [GS-261].


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
