# CLAUDE.md

This file provides guidance to AI Coding Assistants (Claude Code, Gemini CLI, Cursor, Antigravity, etc.) when working with code in this repository.

## Repository Structure

One package live here:

- **`genericsuite_flutter/`** — Reusable Flutter library (v0.4.1) distributed as a Git dependency. This is the main package to develop.

## Commands

All Flutter commands run from inside the relevant package directory (`genericsuite_flutter/`).

```bash
# Dependencies
flutter pub get           # install
flutter pub upgrade       # update

# Testing
flutter test              # run all tests
flutter test test/some_test.dart  # single test file

# Analysis / Lint
flutter analyze

# Run
flutter run
```

From the root `Makefile`:
```bash
make sast-test      # Snyk security scanning
```

## Architecture

### Core Pattern: JSON-Driven CRUD

The library eliminates boilerplate by parameterizing UI and behavior through JSON config files. A consumer app adds two JSON files per entity (frontend + backend definition), then mounts `CrudEditor` — no further Dart code needed for standard CRUD.

Config files live in `assets/`:
- `assets/config/stage.json` — selects environment (`dev`, `qa`, `staging`, `prod`)
- `assets/config/config-{stage}.json` — API base URL and other env values
- `assets/config_dbdef/backend/*.json` — REST endpoint + schema definitions
- `assets/config_dbdef/frontend/*.json` — field types, labels, form layout

### Extension Point: `AppCallablesSuper`

Consumer apps subclass `AppCallablesSuper` and override methods to inject app-specific behavior without modifying the library:

```dart
getThemeParams()        // colors, fonts
getStorage()            // FlutterSecureStorage instance (e.g. with biometrics)
getMenuCallables()      // navigation structure → AppDrawer
getAppInfo()            // app name, version
getMainScreenElements() // primary and alternate screen widgets
getUserCallbacks()      // per-entity CRUD lifecycle hooks
```

The singleton is registered with GetIt (`storageLocator`) and accessed throughout the library. Apps bootstrap via `CreateGsApp`.

### Dependency Injection

GetIt is used for two singletons:
- `storageLocator<FlutterSecureStorage>` — secure key/value storage
- `storageLocator<AppCallablesSuper>` — app behavior strategy

Setup happens in `locator_service.dart`; consumer apps call setup before `runApp`.

### Authentication Flow

1. `ConfigService` loads `stage.json` → `config-{stage}.json` to determine API URL.
2. `LoginPage` calls the auth endpoint; JWT is stored in `FlutterSecureStorage`.
3. `HttpUtilities.httpsCall()` reads the JWT and injects `Authorization: Bearer <token>` on every request.
4. On startup, the stored token is validated; invalid/missing token redirects to `LoginPage`.

### Key Files

| File | Role |
|------|------|
| `lib/genericsuite.dart` | Barrel export — all public API |
| `lib/services/app_callables_super.dart` | Base class for app customization |
| `lib/services/crud_editor.dart` | Generic CRUD widget (~500 LOC) |
| `lib/services/http_service.dart` | JWT-aware HTTP client |
| `lib/services/config_service.dart` | Environment config loader |
| `lib/services/form_field_service.dart` | JSON → form field widgets |
| `lib/services/utilities.dart` | JWT decode, logging, ObjectId helpers |
| `lib/services/locator_service.dart` | GetIt DI setup |
| `lib/views/login.dart` | Login screen |
| `lib/widgets/app_frame.dart` | Standard scaffold (AppBar + Drawer) |
| `lib/widgets/app_drawer.dart` | JSON-driven navigation drawer |

### Menu System

`AppDrawer` renders navigation from the JSON structure returned by `getMenuCallables()`. Each item specifies a `type` (`nav_link` or `nav_dropdown`), an optional `sec_group` for role-based filtering, and either a route `path` or an `on_click` callback reference.

### CRUD Lifecycle Hooks

`CrudEditor` accepts `specificFunctions` and `components`/`childComponents` maps. These receive the current record and a callbacks object, enabling validation, derived fields, custom widgets, and post-save side effects without modifying the library.

## Development Notes

- The library targets Dart SDK `>=3.10.7`; the template targets `>=3.7.0`.
- `flutter_secure_storage ^10.0.0` is the storage layer — platform-specific setup (Android `minSdkVersion 23`, iOS Keychain sharing) may be required in consumer apps.
- `analysis_options.yaml` inherits `package:flutter_lints/flutter.yaml` with no additional rules; `flutter analyze` must pass before merging.
- Consumer apps reference the library via a GitHub Git dependency, not pub.dev.

## Important Notes

- The files `AGENTS.md`, `GEMINI.md`, etc. (if present) have only a referece to `@CLAUDE.md` — edit only `CLAUDE.md`.
- Skills live in `.ai/skills/` (source of truth); symlinked under `.agents/skills/`, `.claude/skills/`, `.codex/skills/`, `.gemini/skills/`, and `.devin/skills/`.
