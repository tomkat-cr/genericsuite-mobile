# CHANGELOG

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and [Keep a Changelog](http://keepachangelog.com/).



## [Unreleased] - YYYY-MM-DD

### Added

### Changed

### Fixed

### Security

### Removed


## [0.5.1] - 2026-08-31

### Added
- Makefile with "upgrade", "install", "pre-publish", and "publish" commands to automate the https://pub.dev publishing process [GS-261].

### Changed
- Main CHANGELOG.md file replaced by a link to the genericsuite_flutter CHANGELOG.md file, and all the release notes for the GenericSuite mobile Flutter/Dart package moved to genericsuite_flutter CHANGELOG.md [GS-261].
- Main README.md file cleaned up and add a link to the genericsuite_flutter README.md file [GS-261].
- genericsuite_flutter README.md file updated with more information about the package and usage examples, and TODOs removed [GS-261].
- Code formatted with dart format [GS-261].
- pubspec.yaml file updated to reflect the new version [GS-261].


## [0.5.0] - 2026-08-30

### Added
- `childComponents` (1-N relationships) support in the Flutter CRUD Editor: child components declared in the frontend JSON config render as tappable sections in the edit form, open full-screen with the parent row as `parentData`, and support `child_listing` editors with `array` and `table` subtypes (including the `<array_name>`/`<array_name>_old` write payloads), matching the genericsuite-fe CRUD Editor behavior [GS-261].
- Apple-clean theme tokens in `theme_config_defaults.dart` (`accentColor`, `borderRadius` 12px, `fontFamily`/`textTheme` typography tokens with Inter via google_fonts, near-black `textColor`, iOS system semantic colors) plus a `defaultThemeParams` merge contract so apps override only the keys they need [GS-261].
- `shadcn_ui` (flutter-shadcn-ui port) now owns the widget-tree root via `ShadApp.custom`; `CreateGsApp` builds the MaterialApp theme from the GenericSuite tokens; Save/Cancel form buttons use ShadButton [GS-261].
- `buildGsShadTheme()` builds `ShadThemeData` from GenericSuite theme tokens; new `shadColorSchemeName` theme param selects the shadcn base scheme (`green` default; any `ShadColorScheme.fromName` value), with `accentColor` overriding `primary`/`ring` and GS surface/text/error tokens applied via `copyWith` [GS-261].
- "lint" and "test" commands to Makefile.
- Test coverage for the project [GS-327].

### Changed
- Default accent color changed from blue to green; app bar and drawer default to white surfaces with near-black text; genericsuite_flutter version bumped to 0.5.0 [GS-261].
- README.md detailed configuration instructions moved to the GS Basecamp documentation [GS-261].

### Fixed
- http_service.dart [GS-327]:
  1. getJwtPayload uses ascii.decode(...) instead of utf8.decode(...) to decode the JWT payload. Any claim with non-ASCII characters throws FormatException, breaking login-gate checks, loadConfig(), and current_user_service.dart.
  2. No .timeout(...) on any http.get/post/put/delete/patch call (unlike ip_address_service.dart, which correctly uses one), so a hung connection stalls the caller indefinitely.
  3. The 200/201 success path (json.decode(response.body) also has no try/catch, unlike the error branch. Debug flags (debugJwtToken, debugConfigValues) would print full JWTs/API keys if ever flipped on (currently const false, compiled out); query-string builder encodes values but not keys.
  4. Add type annotations to bToA(str).
- create_gs_app.dart: payload["exp"] * 1000 has no null-check; a token whose payload lacks exp (or a malformed token where getJwtPayload returns {}) throws synchronously in build(), crashing app startup instead of falling back to LoginPage. Verified by direct read [GS-327].
- crud_editor.dart [GS-327]:
  1. _saveItem: when isCreation && editorConfig['createReenter'] is true after a successful save, the method returns without calling setState(); _isLoading was flipped to true via setState but is reset with a bare assignment, so the loading spinner can stick indefinitely.
  2. No mounted checks after await before setState/_setStateAndShowMessages calls (e.g. in _buildListItem's onTap, initState's _loadConfig().then); navigating away mid-request can throw "setState() called after dispose()".
  3. json.decode(localApiResp['resultset']) in _loadSelectedItem has no try/catch unlike the equivalent in _loadItems, and int.parse(...['rows_affected']) is unguarded.
  4. _getSelectFieldsOptions — sequential await in a loop instead of Future.wait, serializing network calls unnecessarily.
- crud_editor_commons.dart [GS-327]:
  1. (buildChildRowToSave): indexes editorConfig['parentData'][keyPair['parentElementName']] with no null check.
  2. parentData can be empty/missing (e.g. _setEndpointFilter silently no-ops), so saving/deleting on a child_listing editor can throw NoSuchMethodError.
- form_field_service.dart [GS-327]:
  1. select and select_component cases set DropdownButtonFormField.initialValue without checking the value exists among items, unlike the select_table case which correctly guards with containsKey(...) ? value : null.
  2. Stale/edited data crashes the form on open. Number/integer fields call double.parse/int.parse directly in onChanged on every keystroke; clearing the field or typing ./- throws uncaught FormatException while typing.
  3. TextEditingController(text: ...) is instantiated inline in build() for most field types and never disposed (e.g. L126, 219, 310, 346, 380, 419, 545, 594, 659); every rebuild leaks the old controller and resets cursor/focus for all fields on screen.
- app_drawer.dart [GS-327]:
  1. Icon(item['callable']['icon']) throws if item['element'] isn't a key in callables; no fallback/guard.
  2. _loadConfig().then(...) has no error handling; exceptions become unhandled async errors instead of showing the drawer's error UI.
- error_reporter_widget.dart: ScaffoldMessenger.of(context).showSnackBar(...) is called synchronously inside build(). Verified by direct read — this is a known Flutter anti-pattern (mutating overlay state during build) and should be deferred via addPostFrameCallback, as homepage.dart does elsewhere.
- login.dart [GS-327]:
  1. _usernameController/_passwordController are created but the widget has no dispose() override, leaking both TextEditingControllers.
  2. apiResponse['resultset']['token'] is accessed with no null-check on resultset. "password" field lacks autocorrect: false / enableSuggestions: false.
- current_user_service.dart: if (data['error'] == 'Not Found') can never be true since http_service.dart always sets error to a bool; this branch is dead code [GS-327].
- logout_service.dart: storage.delete(...) calls for jwt/api_key/user_data aren't awaited before navigating away; app kill right after logout can leave stale credentials in secure storage [GS-327].
- routing_services.dart: Added item['callable']['type'] = 'async' (default) | 'sync' to allow sync/async function calls and handle code change made to logout_service.dart [GS-327].
- locator_service.dart: registerLazySingleton has no isRegistered guard; re-invoking setup (hot restart, remount, tests) throws on duplicate registration [GS-327].
- timestamp_utilities.dart: 12-hour formatting doesn't special-case midnight; hour 0 renders as "0:MM AM" instead of "12:MM AM" [GS-327].
- homepage.dart: loadHomeData(true) called directly as the FutureBuilder's future: inside build() re-triggers the API call on every rebuild before data is loaded [GS-327].
- deviceid_service.dart: implicit ordering dependency on setupStorageLocator() having run first [GS-327].
- back_button.dart: Navigator.of(context, rootNavigator: true).pop(context) passing context as the pop result looks unintentional [GS-327].
- CRUD Editor save froze the spinner and aborted the write (`_zOrderIndex != null` in `overlay.dart`): `_runApiCall` replaced the form with `CircularProgressIndicator`, disposing dropdown/popup OverlayPortals while they were still hiding. The form/list now stays mounted under a loading overlay, and AppBar "Save" goes through `DataFormBody.submit()` so child rows persist the values on screen [GS-261].
- `suggestion_dropdown`: typed text is now stored in the in-memory row (`selectedItem`) on change and Save, matching genericsuite-fe. Picking a suggestion still copies related API fields and also writes the form field name [GS-261].
- `suggestion_dropdown`: suggestion rows are read the same way CRUD listings decode `resultset` (already-decoded list, JSON string, or nested `{resultset: [...]}`), so the overlay can show options when the API returns rows [GS-261].
- `suggestion_dropdown`: picking a suggestion no longer copies related-table keys (`_id`, `name`, …) onto the saved row. Only the form field and `autocomplete_fields` are written, matching genericsuite-fe [GS-261].
- Password field shows SHA-256 hash instead of plain text. The initial password must be blank [GS-261].

### Removed
- `flutter_project_template` directory. Use [genericsuite-mobile-exampleapp](https://github.com/tomkat-cr/genericsuite-mobile-exampleapp) instead [GS-261].


## [0.4.2] - 2026-04-20

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
- GenericSuite mobile for Flutter package and ExampleApp template [GS-261].
