<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->
# GenericSuite for Mobile (Flutter/Dart version)

<img 
    align="right"
    width="100"
    height="100"
    src="https://genericsuite.carlosjramirez.com/images/gs_logo_circle.svg"
    title="GenericSuite logo by Carlos J. Ramirez"
/>

Welcome to [GenericSuite](https://genericsuite.carlosjramirez.com), a comprehensive software solution designed to help you enhance your productivity and streamline your workflows.

[GenericSuite Mobile](https://github.com/tomkat-cr/genericsuite-mobile) brings the GenericSuite JSON-driven CRUD pattern to Flutter apps: define your entities in JSON config files, mount the `CrudEditor` widget — no per-entity Dart code needed for standard CRUD, and take advantage of the customizable login interface, menu builder, and a suite of tools to kickstart your Flutter/Dart Mobile App development process.

## Features

- **Customizable CRUD editor:** core CRUD (*Create, Read, Update, Delete*) code that can be parametrized and extended by JSON configuration files. There's no need to rewrite code for each table editor.
- **Customizable menu:** menu and endpoints can be parametrized and extended by JSON configuration files in the backend side. The API will supply the menu estructure and security check based on the user's security group, and GenericSuite will draw the menu and available options.
- **Customizable Login Screen:** Easily adapt the login screen to match your brand identity with the App logo.
- **Development and Production Scripts:** Quick commands to start development or build your application for QA, staging or production environments on popular cloud providers.
- **Customizable Widgets:** A set of widgets that can be parametrized and extended by JSON configuration files.
- **Flutter/Dart:** The GenericSuite is built with Flutter/Dart, making it compatible with both Android and iOS.

The perfect companion for this mobile solution is the [backend version of The GenericSuite](https://genericsuite.carlosjramirez.com/Backend-Development/GenericSuite-Core/).

<!--
There's a version of this library with AI features: [The GenericSuite AI](https://github.com/tomkat-cr/genericsuite-mobile/genericsuite-ai).
-->

## Getting started

<!--
TODO: List prerequisites and provide or point to information on how to
start using the package.
-->

### Pre-requisites

- [Flutter SDK](https://docs.flutter.dev/install)
- [Android Studio](https://developer.android.com/studio) (to manage Android SDK, emulators, etc.)
- [Xcode](https://developer.apple.com/xcode/) (to manage iOS SDK, emulators, etc.)
- [GenericSuite mobile package](https://github.com/tomkat-cr/genericsuite-mobile)
- [GenericSuite backend package](https://github.com/tomkat-cr/genericsuite-be)
- [Git](https://www.atlassian.com/git/tutorials/install-git)
- [Make](https://formulae.brew.sh/formula/make) (Mac) | Linux has Make installed by default | [Make](https://stackoverflow.com/questions/32127524/how-to-install-and-use-make-in-windows) (Windows)

### Installation

- Create a new Flutter project:

```bash
flutter create exampleapp
```

- Open the `pubspec.yaml` file and add the GenericSuite to the `dependencies:` section:

```yaml
  genericsuite:
    git:
      url: https://github.com/tomkat-cr/genericsuite-mobile
      ref: main  # or develop
      path: genericsuite_flutter
```

- Install the dependencies.

```bash
flutter pub get
```

### Configuration

- Check the [App Creation and Configuration Guide](https://genericsuite.carlosjramirez.com/Configuration-Guide/) for more information about how to create the JSON configuration files.

- Check the [Backend Guide](https://genericsuite.carlosjramirez.com/Backend-Development/GenericSuite-Core) for more information about how to create the API.

## Usage

### App directory structure

The following directory structure is a reference for the structure of your app. You can find more information about the directory structure in the [App Creation and Configuration Guide](https://genericsuite.carlosjramirez.com/Configuration-Guide/).

```
.
├── android
├── assets
|   ├── config
|   │   ├── config-dev.json
|   │   ├── config-env.example.json
|   │   ├── config-prod.json
|   │   ├── config-qa.json
|   │   ├── stage-dev.json
|   │   ├── stage-prod.json
|   │   ├── stage-qa.json
|   │   └── stage.json
|   ├── config_dbdef
|   │   ├── backend
|   │   │   ├── app_main_menu.json
|   │   │   ├── endpoints.json
|   │   │   ├── general_config.json
|   │   │   ├── onboarding_admin.json
|   │   │   ├── onboarding_users.json
|   │   │   ├── users_api_keys.json
|   │   │   ├── users_config.json
|   │   │   ├── users_profile.json
|   │   │   ├── users.json
|   │   │   └── exampleapp_any_other_table.json
|   │   ├── CHANGELOG.md
|   │   ├── frontend
|   │   │   ├── app_constants.json
|   │   │   ├── general_config.json
|   │   │   ├── general_constants.json
|   │   │   ├── onboarding_admin.json
|   │   │   ├── onboarding_users.json
|   │   │   ├── users_api_keys.json
|   │   │   ├── users_config.json
|   │   │   ├── users_profile.json
|   │   │   ├── users.json
|   │   │   └── exampleapp_any_other_table.json
|   │   └── README.md
|   └── images
|       ├── app_logo_circle.png
|       ├── app_logo_emblem.png
|       └── app_logo_horizontal.png
├── build
├── ios
├── lib
|   ├── config
|   │   └── theme_config.dart
|   ├── domain
|   │   ├── app_menu_callables.dart
|   │   ├── exampleapp_crud_editor_sf_users.dart
|   │   └── exampleapp_utilities.dart
|   ├── main.dart
|   ├── views
|   │   ├── about.dart
|   │   ├── exampleapp_any_other_crud_editor_view.dart
|   │   └── user_profile.dart
|   └── widgets
|       ├── homepage_body.dart
|       └── exampleapp_any_other_widget.dart
├── test
├── web
└── windows
```

### App bootstrap

#### lib/main.dart

The `main.dart` file is the entry point of the app. In our examples we create the `ExampleApp` widget, which is a subclass of `StatelessWidget` that builds the app's widget tree.

The `AppCallables` class injects your app's behavior and theme configuration into the GenericSuite framework, and `CreateGsApp` builds the widget-tree root with `ShadApp` ([shadcn_ui](https://pub.dev/packages/shadcn_ui), the Flutter port of ShadCN) and derives the `MaterialApp` theme from the GenericSuite theme tokens (see [Theming](#theming)).

```dart
import 'package:flutter/material.dart';
import 'package:genericsuite/services/create_gs_app.dart';

import "domain/app_menu_callables.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CreateGsApp(appCallables: AppCallables());
  }
}
```

#### lib/domain/app_menu_callables.dart

This file defines the app menu callables (functions that are called when an item in the app menu is selected, widgets specified in the JSON configuration files, etc.), the app info, the main screen elements, and the user management related callbacks.

```dart
import 'package:flutter/material.dart';
import 'package:genericsuite/services/app_callables_super.dart';
import 'package:genericsuite/services/logout_service.dart';
import 'package:genericsuite/services/utilities.dart';
import 'package:genericsuite/views/homepage.dart';

import '../config/theme_config.dart';
import '../domain/exampleapp_crud_editor_sf_users.dart';
import '../views/about.dart';
import '../views/user_profile.dart';

import '../domain/exampleapp_utilities.dart';

// "exampleapp_any_other_crud_editor_view.dart" has the ExampleappAnyOtherCrudEditorView widget,
// which is also an alternative view for the HomepageBody widget
import '../views/exampleapp_any_other_crud_editor_view.dart';

// "homepage_body.dart" has the HomepageBody widget, which is the main view of the app
import '../widgets/homepage_body.dart';

import '../widgets/exampleapp_any_other_widget.dart';

const debug = false;

class AppCallables extends AppCallablesSuper {
  /*
   * Get the theme parameters
   */
  @override
  Map<String, dynamic> getThemeParams() {
    return {
      'accentColor': accentColor,
      'accentForegroundColor': accentForegroundColor,
      'borderRadius': borderRadius,
      'fieldVerticalSpacing': fieldVerticalSpacing,
      'fontFamily': gsFontFamily,
      'textTheme': null, // TextTheme? — app-provided full text theme
      'textColor': textColor,
      'secondaryTextColor': secondaryTextColor,
      'separatorColor': separatorColor,
      'neutralSurfaceColor': neutralSurfaceColor,
      'primarySwatch': primarySwatch,
      'scaffoldBackgroundColor': scaffoldBackgroundColor,
      'appBarBackgroundColor': appBarBackgroundColor,
      'appBarForegroundColor': appBarForegroundColor,
      'drawerBackgroundColor': drawerBackgroundColor,
      'drawerForegroundColor': drawerForegroundColor,
      'drawerBarBackgroundColor': drawerBarBackgroundColor,
      'drawerBarForegroundColor': drawerBarForegroundColor,
      'errorBackgroundColor': errorBackgroundColor,
      'errorForegroundColor': errorForegroundColor,
      'infoBackgroundColor': infoBackgroundColor,
      'infoForegroundColor': infoForegroundColor,
      'warningBackgroundColor': warningBackgroundColor,
      'warningForegroundColor': warningForegroundColor,
      'successBackgroundColor': successBackgroundColor,
      'successForegroundColor': successForegroundColor,
      'closeButtonPlacement': closeButtonPlacement,
      'shadColorSchemeName': shadColorSchemeName,
      'drawerHeaderLogoPath': drawerHeaderLogoPath,
      'drawerHeaderLogoHeight': drawerHeaderLogoHeight,
      'drawerHeaderLogoWidth': drawerHeaderLogoWidth,
      'drawerHeaderText': drawerHeaderText,
      'drawerHeaderTextFontSize': drawerHeaderTextFontSize,
      'drawerHeaderTextFontWeight': drawerHeaderTextFontWeight,
      'appBarLogoPath': appBarLogoPath,
      'appBarLogoHeight': appBarLogoHeight,
      'appBarLogoWidth': appBarLogoWidth,
      'appBarTitleText': appBarTitleText,
      'appBarTitleTextFontSize': appBarTitleTextFontSize,
      'appBarTitleTextFontWeight': appBarTitleTextFontWeight,
    };
  }

  /*
   * Get the menu callables and other options
   */
  @override
  Map<String, dynamic> getMenuCallables() {
    if (debug) {
      logDebug('AppCallables | getMenuCallables');
    }
    return {
      "HomePage": {
        "widget": () =>
            HomePage(homePageBodyBuilder: (userData) => HomePageBody(userData)),
        "icon": Icons.dashboard,
        "args": {}
      },
      "ExampleappAnyOtherCrudEditorView_EditorData": {
        "widget": () => ExampleappAnyOtherCrudEditorView(),
        "icon": Icons.restaurant_menu,
        "args": {}
      },
      "UserProfileEditor": {
        "widget": () => UserProfile(),
        "icon": Icons.person,
        "args": {}
      },
      "BillingEditor": {"widget": null, "icon": Icons.payment, "args": {}},
      "|about|": {"widget": () => About(), "icon": Icons.info, "args": {}},
      "logout": {
        "function": (context) => logOut(context),
        "icon": Icons.logout,
        "args": {}
      },
    };
  }

  /*
   * Get the app info
   */
  @override
  Map<String, dynamic> getAppInfo() {
    return {
      "version": "1.0.0",
      "name": appName,
      "description": "Nutrition in your pocket",
      "appEmail": "support@fynapp.com",
      "appPhone": "+57 316 320-1208",
      "appWebsite": "https://fynapp.com",
      "author": "Carlos J. Ramirez / Mediabros",
      "authorEmail": "contact@mediabros.com",
      "authorPhone": "+57 316 320-1208",
      "authorWebsite": "https://mediabros.com",
    };
  }

  /*
   * Get the main screen elements
   */
  @override
  Map<String, dynamic> getMainScreenElements() {
    return {
      "mainScreen": (userData) => HomePageBody(userData),
      "alternateScreen": () => Dishes(),
      "redirect": false, // or true to redirect to alternate screen
      "icon": Icons.dashboard,
      "args": {},
    };
  }

  /*
   * Get the user management related callbacks
   */
  @override
  Map<String, dynamic> getUserCallbacks(BuildContext context) {
    return {
      'specificFunctions': {
        'UsersDbPostWrite': (dynamic data,
                Map<String, dynamic> editorConfig,
                String action,
                Map<String, dynamic> params,
                BuildContext? context) async =>
            usersDbPostWrite(data, editorConfig, action, params, context),
        'UsersOnboardingDbPreWrite': (dynamic data,
                Map<String, dynamic> editorConfig,
                String action,
                Map<String, dynamic> params,
                BuildContext? context) async =>
            usersOnboardingDbPreWrite(
                data, editorConfig, action, params, context),
        'UsersOnboardingDbPostWrite': (dynamic data,
                Map<String, dynamic> editorConfig,
                String action,
                Map<String, dynamic> params,
                BuildContext? context) async =>
            usersOnboardingDbPostWrite(
                data, editorConfig, action, params, context),
      },
      "components": {
        'UserTotalQtyAndCondition': ({
          dynamic data,
          required Map<String, dynamic> config,
          required String value,
          required Function onChanged,
          required String action,
          Map<String, dynamic>? props,
        }) =>
          userTotalQtyAndCondition(
            config: config,
            value: value,
            onChanged: onChanged,
            action: action,
            storage: storage,
            context: context,
            props: props,
          ),
        'UserMinimumDailyQty': ({
          dynamic data,
          required Map<String, dynamic> config,
          required String value,
          required Function onChanged,
          required String action,
          Map<String, dynamic>? props,
        }) =>
            userMinimumDailyCalories(
              config: config,
              value: value,
              onChanged: onChanged,
              action: action,
              context: context,
              props: props,
            ),
      },
      "childComponents": {}
    };
  }
}
```

## Theming

The design language is Apple-clean: white/neutral surfaces, near-black text, one accent color (default `Colors.green`), 12 px corner radius, and iOS system semantic colors.

Override `getThemeParams()` in your `AppCallables` to customize — return only the keys you want to change; they are merged over the library defaults (`defaultThemeParams` in `theme_config_defaults.dart`):

| Token | Default | Purpose |
| --- | --- | --- |
| `accentColor` | `Colors.green` | The single accent color |
| `borderRadius` | `12.0` | Corner radius (px) for inputs, buttons, cards |
| `fontFamily` | `'Inter'` | Typography; `'Inter'` loads via google_fonts (SF-Pro-like) |
| `textTheme` | `null` | Optional full `TextTheme` override |
| `textColor` | `#111111` | Near-black primary text |
| `secondaryTextColor` | `#6E6E73` | iOS secondary label |
| `separatorColor` | `#D1D1D6` | iOS separator (borders, dividers) |
| `neutralSurfaceColor` | `#F2F2F7` | iOS systemGray6 neutral surface |
| `scaffoldBackgroundColor` | `Colors.white` | Screen background |
| `appBarBackgroundColor` / `appBarForegroundColor` | white / near-black | App bar surfaces |
| `errorBackgroundColor` | `#FF3B30` (systemRed) | Error messages |
| `infoBackgroundColor` | `#007AFF` (systemBlue) | Info messages |
| `warningBackgroundColor` | `#FF9500` (systemOrange) | Warnings |
| `successBackgroundColor` | `#34C759` (systemGreen) | Success messages |

Example:

```dart
class AppCallables extends AppCallablesSuper {
  @override
  Map<String, dynamic> getThemeParams() {
    return {
      'accentColor': Colors.indigo,
      'fontFamily': 'Inter',
    };
  }
}
```

#### lib/config/theme_config.dart

This file defines the theme of the app (colors, styles, etc.).

```dart
import 'package:flutter/material.dart';

const String appName = "ExampleApp";

const MaterialColor accentColor = Colors.green;
const Color accentForegroundColor = Colors.white;

const double borderRadius = 12.0;

// Defines the border line's weight of Material inputDecorationTheme
// border and enabledBorder, and dividerTheme thickness
const double separatorWidth = 0.50;

// Vertical gap between stacked form fields so outlined focus rings do not
// overlap the previous field's border / floating label.
const double fieldVerticalSpacing = 12.0;

// Named shadcn_ui base scheme for buildGsShadTheme(). Valid values match
// ShadColorScheme.fromName: blue, gray, green, neutral, orange, red, rose,
// slate, stone, violet, yellow, zinc. Apps override via getThemeParams().
const String shadColorSchemeName = 'green';

// Typography tokens. 'Inter' triggers GoogleFonts.interTextTheme() in
// CreateGsApp; any other family name is applied verbatim. An app can also
// provide a full TextTheme via the 'textTheme' theme param (null = derive
// from fontFamily).
const String gsFontFamily = 'Inter';

const Color textColor = Color(0xFF111111); // near-black
const Color secondaryTextColor = Color(0xFF6E6E73); // iOS secondary label

const Color separatorColor = Color(0xFFD1D1D6); // iOS separator
const Color neutralSurfaceColor = Color(0xFFF2F2F7); // iOS systemGray6

// Legacy token, superseded by accentColor. Kept because existing apps
// reference it in their getThemeParams() overrides.
const MaterialColor primarySwatch = accentColor;
const Color scaffoldBackgroundColor = Colors.white;

const Color appBarBackgroundColor = accentColor; // Colors.white;
const Color appBarForegroundColor = accentForegroundColor; // textColor;

const Color drawerBarBackgroundColor = appBarBackgroundColor;
const Color drawerBarForegroundColor = appBarForegroundColor;

const Color drawerBackgroundColor = scaffoldBackgroundColor; // Colors.white;
const Color drawerForegroundColor = textColor;

// iOS system semantic colors
const Color errorBackgroundColor = Color(0xFFFF3B30); // systemRed
const Color errorForegroundColor = Colors.white;

const Color infoBackgroundColor = Color(0xFF007AFF); // systemBlue
const Color infoForegroundColor = Colors.white;

const Color warningBackgroundColor = Color(0xFFFF9500); // systemOrange
const Color warningForegroundColor = Colors.white;

const Color successBackgroundColor = Color(0xFF34C759); // systemGreen
const Color successForegroundColor = Colors.white;

const String closeButtonPlacement = "bottom"; // "bottom" or "right"

const String appBarLogoPath = 
   'assets/images/app_logo_horizontal.png'; // If left empty, the appName
                                            // will be displayed in the app bar
const double appBarLogoHeight = 32.0;
const double appBarLogoWidth = 128.0;

const String appBarTitleText = appName;
const double appBarTitleTextFontSize = 20.0;
const FontWeight appBarTitleTextFontWeight = FontWeight.bold;

const String drawerHeaderLogoPath =
    'assets/images/app_logo_horizontal.png'; // 'assets/images/app_logo_circle.png';
const double drawerHeaderLogoHeight = 250.0;
const double drawerHeaderLogoWidth = 250.0;

const String drawerHeaderText = appName;
const double drawerHeaderTextFontSize = 20.0;
const FontWeight drawerHeaderTextFontWeight = FontWeight.bold;
```

### CRUD support code

#### lib/domain/exampleapp_crud_editor_sf_users.dart

This file contains the "specific functions" that are called when a user is created or updated in the database.

* *Specific Functions* are callables that extend the Generic CRUD Editor (`CrudEditor` widget) capabilities.

```dart
import 'package:flutter/material.dart';

import 'package:genericsuite/services/crud_editor_commons.dart';
import 'package:genericsuite/services/http_service.dart';
import 'package:genericsuite/services/utilities.dart';
import 'package:genericsuite/views/login.dart';

const debug = false;

Future<Map<String, dynamic>> usersDbPostWrite(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
  BuildContext? context,
) async {
  Map<String, dynamic> result = genericFuncArrayDefaultValue(data);
  if (context == null || context.mounted == false) return result;
  String parentId = data[editorConfig['primaryKeyName']];
  switch (action) {
    case actionCreate:
    case actionUpdate:
      final HttpUtilities api = HttpUtilities(storage);
      final Map<String, dynamic> itemToSave = {
        "user_id": parentId,
        "user_history": {
          "date": nowToTimestamp(),
          // Other data that can be change every time the user item is updated
          "goal_code": data['goal_code'],
          "minimun_daily_qty": data['minimun_daily_qty'],
        }
      };
      final apiResp =
          await api.httpsCall('post', 'users_user_history', {}, itemToSave, {});
      if (debug) {
        logDebug(
            "UsersDbPostWrite - itemToSave: $itemToSave | apiResp: $apiResp");
      }
      if (apiResp['error'] == false) {
        // To refresh parent component and show the new minimun_daily_qty value
        result['otherData']['refresh'] = true;
        if (debug) {
          logDebug("UsersDbPostWrite | result: $result");
        }
      } else {
        result['error'] = true;
        result['error_message'] = apiResp['error_message'];
        result['status_code'] = apiResp['status_code'];
        result['resultset'] = apiResp['resultset'];
      }
      break;
    default:
      break;
  }
  return result;
}

Future<Map<String, dynamic>> usersOnboardingDbPostWrite(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
  BuildContext? context,
) async {
  Map<String, dynamic> result = genericFuncArrayDefaultValue(data);
  if (context == null || context.mounted == false) return result;
  String userId = data[editorConfig['primaryKeyName']];
  switch (action) {
    case actionCreate:
    case actionUpdate:
      final HttpUtilities api = HttpUtilities(storage);
      final Map<String, dynamic> body = {
        "user_id": userId,
      };
      final apiResp =
          await api.httpsCall('post', 'onboarding_admin', {}, body, {});
      if (debug) {
        logDebug(
            "UsersOnboardingDbPostWrite - body: $body | apiResp: $apiResp");
      }
      if (apiResp['error'] == false) {
        result['onboardingMessage'] =
            "User registration completed successfully. Please check your Email for a confirmation email.";
      } else {
        result['errorMessage'] = apiResp['error_message'];
        result['errorCode'] = 'UOBPW-E010';
        result['apiStatusCode'] = apiResp['status_code'];
      }
      break;
    default:
      break;
  }

  Navigator.push(
    (context?.mounted == false ? null : context)!,
    MaterialPageRoute(builder: (context) => LoginPage(params: result)),
  );

  return result;
}
```

### lib/views/about.dart

This file is a StatelessWidget that shows a simple about page with a title and a description.

```dart
import 'package:flutter/material.dart';
import 'package:genericsuite/widgets/app_frame.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  AboutState createState() => AboutState();
}

class AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return AppFrame(
      body: ListView(
        padding: const EdgeInsets.only(
          top: 10.0,
          left: 20.00,
          right: 20.00,
        ),
        children: const <Widget>[
          Text(
              'ExampleApp is a mobile app that uses GenericSuite to create a CRUD app.'),
          Text(""),
          Text(
              'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'),
        ],
      ),
    );
  }
}
```

### lib/views/exampleapp_any_other_crud_editor_view.dart

This file contains a CRUD editor (implemented by the GenericSuite `CrudEditor` widget) that is used to display a table of data from a database table.

The table used is the [exampleapp_any_other](#assetsconfig_dbdeffrontendexampleapp_any_other_tablejson) table.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:genericsuite/services/crud_editor.dart';
import 'package:genericsuite/services/locator_service.dart';

import '../domain/app_menu_callables.dart';

class ExampleappAnyOtherCrudEditorView extends StatefulWidget {
  const ExampleappAnyOtherCrudEditorView({super.key});

  @override
  ExampleappAnyOtherCrudEditorViewState createState() => ExampleappAnyOtherCrudEditorViewState();
}

class ExampleappAnyOtherCrudEditorViewState extends State<ExampleappAnyOtherCrudEditorView> {
  @override
  Widget build(BuildContext context) {
    final storage = storageLocator<FlutterSecureStorage>();
    Map<String, dynamic> callbacks = {
      'specificFunctions': {
        'ExampleappAnyOtherValidations': (dynamic data,
                Map<String, dynamic> editorConfig,
                String action,
                Map<String, dynamic> params,
                BuildContext? context) async =>
            exampleappAnyOtherValidations(
                data, editorConfig, action, params, storage, context),
      },
      "childComponents": {
        "ExampleappAnyOtherChildComponent": ({
          required Map<String, dynamic> parentData,
          Map<String, dynamic>? props,
        }) =>
            CrudEditor(
              jsonFileName: 'exampleapp_any_other_child_table.json',
              callbacks: AppCallables().getUserCallbacks(context),
              props: {...?props, 'parentData': parentData},
            ),
      }
    };
    Map<String, dynamic> props = {};
    return CrudEditor(
      jsonFileName: 'exampleapp_any_other_table.json',
      callbacks: callbacks,
      props: props,
    );
  }
}
```

### lib/views/user_profile.dart

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:genericsuite/services/app_callables_super.dart';
import 'package:genericsuite/services/crud_editor.dart';
import 'package:genericsuite/services/http_service.dart';
import 'package:genericsuite/services/locator_service.dart';
import 'package:genericsuite/services/utilities.dart';

const debug = false;

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  String itemId = '';
  AppCallablesSuper appCallables = appCallablesLocator<AppCallablesSuper>();

  @override
  void initState() {
    super.initState();
    loadConfig().then((configStr) {
      Map<String, dynamic> config =
          Map<String, dynamic>.from(json.decode(configStr));
      if (debug) {
        logDebug('UserProfile | initState | itemId: $itemId');
      }
      setState(() {
        itemId = config["userId"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (itemId.isEmpty) {
      return Container();
    }
    Map<String, dynamic> callbacks = appCallables.getUserCallbacks(context);
    Map<String, dynamic> props = {
      'isEditMode': true,
      'itemId': itemId,
    };
    if (debug) {
      logDebug('UserProfile | build | props: $props');
    }
    return CrudEditor(
      jsonFileName: 'users_profile.json',
      callbacks: callbacks,
      props: props,
      backButtonAction: () {
        if (debug) {
          logDebug('UserProfile | backButtonAction');
        }
        return appCallables.mainScreenWidget();
      },
    );
  }
}
```

### lib/widgets/homepage_body.dart

This file contains the HomePageBody widget that is used to display the home page of the app.

```dart
import 'package:flutter/material.dart';
import 'package:genericsuite/services/message_service.dart';
import 'package:genericsuite/services/select_options_service.dart';
import 'package:genericsuite/services/utilities.dart';

const debug = false;

class HomePageBody extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomePageBody(this.userData, {super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  String errorMessage = '';
  String errorCode = '';
  String infoMessage = '';
  Map<String, dynamic> constants = {};

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> loadHomeConfig() async {
    return getAllConstants().then((constantsMap) {
      return constantsMap;
    }).catchError((error) {
      throw error;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomePageBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    scheduleMessagesBindings(context, {
      'errorMessage': errorMessage,
      'errorCode': errorCode,
      'infoMessage': infoMessage,
    });
  }

  String setErrorMessage(dynamic error) {
    errorMessage = error.toString();
    return "";
  }

  Widget bodyBuilder(Map<String, dynamic> data) {
    constants = data['constants'];
    if (debug) {
      logDebug("HomePageBody - constants: ${constants.toString()}");
    }
    return ListView(
      padding: const EdgeInsets.only(
        top: 10.0,
        left: 20.00,
        right: 20.00,
      ),
      children: <Widget>[
        Text("Hi ${widget.userData['firstname']}\n"),
        Text("Birthdate: ${widget.userData['birthday']}"),
        const Divider(),
        debug ? Text(widget.userData.toString()) : Container()
      ],
    );
  }

  Widget buildHomePage(BuildContext context) {
    return Center(
      child: FutureBuilder(
          future: loadHomeConfig(),
          builder: (context, snapshot) => snapshot.hasData &&
                  errorMessage.isEmpty
              ? bodyBuilder({"constants": snapshot.data})
              : snapshot.hasError || errorMessage.isNotEmpty
                  ? snapshot.hasError
                      ? Text(setErrorMessage(snapshot.error.toString()))
                      : Text(setErrorMessage("Error loading Home config data"))
                  : const Center(child: CircularProgressIndicator())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildHomePage(context);
  }
}
```

### lib/domain/exampleapp_utilities.dart

This file contains example utility functions that are used by the ExampleApp.

```dart
import 'package:genericsuite/services/convertion_utilities.dart';
import 'package:genericsuite/services/timestamp_utilities.dart';
import 'package:genericsuite/services/utilities.dart';

const String anyConstant = "Condition:";

class DailyConditionResult {
  final bool deficitCondition;
  final String conditionMessage;

  DailyConditionResult({
    required this.deficitCondition,
    required this.conditionMessage,
  });
}

DailyConditionResult getDailyCondition(
    double? minimunDaily, double? totalToday) {

  final bool deficitCondition =
      (minimunDaily ?? 0) > (totalToday ?? 0);
  final String conditionDescription = (deficitCondition ? 'Deficit' : 'Surplus');
  final String conditionMessage =
      (totalToday == null ? '' : '$anyConstant $conditionDescription');

  final result = DailyConditionResult(
    deficitCondition: deficitCondition,
    conditionMessage: conditionMessage,
  );
  return result;
}

int getAge(DateTime today, DateTime dob) {
    final year = today.year - dob.year;
    final mth = today.month - dob.month;
    final days = today.day - dob.day;
    if(mth < 0){
      // negative month means it's still upcoming
      return year-1;
    }
    else {
      return year;
    }
  }

class MinimumDailyQuantityResult {
  final double value;

  MinimumDailyQuantityResult({
    required this.value,
  });
}

MinimumDailyQuantityResult getMinimumDailyQuantity(
  String dateOfBirth,
  String gender,
  String goalCode,
) {
  final age = getAge(DateTime.now(), DateTime.parse(dateOfBirth));
  final result = MinimumDailyQuantityResult(
    // This is a hypothetical calculation based on age, gender, and goal code
    value: (goalCode == 'goal_code_1' ? 100 : 200) * (gender == 'male' ? 1 : 0.5) * age,
  );
  return result;
}

```

### lib/widgets/exampleapp_any_other_widget.dart

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genericsuite/services/locator_service.dart';
import 'package:genericsuite/services/utilities.dart';

import '../domain/exampleapp_utilities.dart';

const bool debug = false;

class DailyCondition extends StatelessWidget {
  final double minimumDailyQty;
  final double totalQty;
  final String className;
  final String showAsField;

  const DailyCondition({
    Key? key,
    required this.minimumDailyQty,
    required this.totalQty,
    this.className = '',
    this.showAsField = '0',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dailyCondition =
        getDailyCondition(minimumDailyQty, totalQty);
    final output = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dailyCondition.conditionMessage,
          style: TextStyle(
            color: dailyCondition.deficitCondition ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(totalQty.toStringAsFixed(2)),
      ],
    );

    if (showAsField == '1') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Condition',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            output,
          ],
        ),
      );
    }
    return output;
  }
}

class MinimumDailyQty extends StatelessWidget {
  final Map<String, dynamic> data;
  final String className;
  final String name;
  final String id;
  final String type;
  final bool required;
  final bool readOnly;
  final bool disabled;
  final String showAsField;
  final Function(String, String)? onChanged;

  const MinimumDailyQty({
    Key? key,
    required this.data,
    this.className = '',
    this.name = '',
    this.id = '',
    this.type = 'text',
    this.required = false,
    this.readOnly = true,
    this.disabled = false,
    this.showAsField = '1',
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weight = (data['weight'] as num?)?.toDouble() ?? 0.0;
    final height = (data['height'] as num?)?.toDouble() ?? 0.0;
    final dateOfBirth = data['dateOfBirth']?.toString() ?? '';
    final gender = data['gender']?.toString() ?? '';
    final exerciseDays = (data['exerciseDays'] as num?)?.toInt() ?? 0;
    final goalCode = data['goal_code']?.toString();

    final minimumDailyQty = getMinimumDailyQuantity(
      dateOfBirth,
      gender,
      goalCode,
    );

    final newValue = minimumDailyQty.value.toStringAsFixed(2);

    if (showAsField == '1') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          initialValue: newValue,
          decoration: InputDecoration(
            labelText: name.isNotEmpty ? name : 'Minimum Daily Qty',
            border: const OutlineInputBorder(),
          ),
          readOnly: true,
          enabled: false,
        ),
      );
    }
    return Text(newValue);
  }
}

class UserTotalQtyAndCondition extends StatefulWidget {
  final Map<String, dynamic> config;
  final String value;
  final Function onChanged;
  final String action;
  final Map<String, dynamic>? props;

  const UserTotalQtyAndCondition({
    Key? key,
    required this.config,
    required this.value,
    required this.onChanged,
    required this.action,
    this.props = const {},
  }) : super(key: key);

  @override
  UserTotalQtyAndConditionState createState() =>
      UserTotalQtyAndConditionState();
}

class UserTotalQtyAndConditionState
    extends State<UserTotalQtyAndCondition> {
  final FlutterSecureStorage storage = storageLocator<FlutterSecureStorage>();
  Map<String, dynamic>? userData;
  String? errorMessage;
  bool ignoreUserData = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      ignoreUserData = false;
      if (widget.props!.containsKey('ignoreUserData')) {
        ignoreUserData = widget.props!['ignoreUserData'];
      }
      final userDataValue = await storage.read(key: 'user_data');
      if (userDataValue == null) {
        setState(() {
          errorMessage = "User data not found [2]";
        });
        return;
      }

      final currentUserData =
          Map<String, dynamic>.from(json.decode(userDataValue));
      final preparedData = prepareUserDataForMDC(currentUserData);

      setState(() {
        userData = preparedData;
        if (debug) {
          logDebug(
              'UserTotalQtyAndCondition | _loadUserData | userData: $userData');
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error loading user data: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Text(errorMessage!, style: const TextStyle(color: Colors.red));
    }

    if (userData == null) {
      return const SizedBox.shrink();
    }

    final totalQty = double.tryParse(widget.value) ?? 0.0;
    final minimumDailyQty = getMinimumDailyQuantity(
      userData!['dateOfBirth'].toString(),
      userData!['gender'].toString(),
      userData!['goal_code']?.toString(),
    );

    return DailyCondition(
      minimumDailyQty: minimumDailyQty.value,
      totalQty: totalQty,
      showAsField: '0',
    );
  }
}

class UserMinimumDailyQty extends StatefulWidget {
  final Map<String, dynamic> config;
  final String value;
  final Function onChanged;
  final String action;
  final Map<String, dynamic>? props;

  const UserMinimumDailyQty({
    Key? key,
    required this.config,
    required this.value,
    required this.onChanged,
    required this.action,
    this.props = const {},
  }) : super(key: key);

  @override
  UserMinimumDailyQtyState createState() =>
      UserMinimumDailyQtyState();
}

class UserMinimumDailyQtyState extends State<UserMinimumDailyQty> {
  final FlutterSecureStorage storage = storageLocator<FlutterSecureStorage>();
  Map<String, dynamic>? userData;
  String? errorMessage;
  bool ignoreUserData = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      ignoreUserData = false;
      if (widget.props!.containsKey('ignoreUserData')) {
        ignoreUserData = widget.props!['ignoreUserData'];
      }

      final userDataValue = await storage.read(key: 'user_data');
      if (userDataValue == null) {
        if (!ignoreUserData) {
          setState(() {
            errorMessage = "User data not found [3]";
          });
        }
        return;
      }

      final currentUserData =
          Map<String, dynamic>.from(json.decode(userDataValue));
      final preparedData = prepareUserDataForMDC(currentUserData);

      setState(() {
        userData = preparedData;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error loading user data: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Text(errorMessage!, style: const TextStyle(color: Colors.red));
    }

    if (userData == null) {
      return const SizedBox.shrink();
    }

    return MinimumDailyQty(
      data: userData!,
      name: widget.config['label'] ?? '',
      showAsField: '1',
    );
  }
}

// Factory functions to be used in CrudEditor callbacks

Widget userMinimumDailyQty({
  required Map<String, dynamic> config,
  required String value,
  required Function onChanged,
  required String action,
  required BuildContext context,
  Map<String, dynamic>? props,
}) {
  return UserMinimumDailyQty(
    config: config,
    value: value,
    onChanged: onChanged,
    action: action,
    props: props,
  );
}

Widget userTotalQtyAndCondition({
  required Map<String, dynamic> config,
  required String value,
  required Function onChanged,
  required String action,
  required BuildContext context,
  Map<String, dynamic>? props,
}) {
  return UserTotalQtyAndCondition(
    config: config,
    value: value,
    onChanged: onChanged,
    action: action,
    props: props,
  );
}
```

### Child components (1-N relationships)

The Flutter CRUD Editor handles `childComponents` the same way the [genericsuite-fe (React) CRUD Editor](https://github.com/tomkat-cr/genericsuite-fe/blob/main/src/lib/services/generic.editor.rfc.service.jsx) does: the frontend JSON config of a parent entity lists child component names, and each one renders inside the parent's edit form.

Parent config (`assets/config_dbdef/frontend/users.json`):

```json
{
    "childComponents": [
        "UsersFoodTimes"
    ]
}
```

On mobile, each child appears as a tappable section at the bottom of the parent's **edit** form (never on creation).

Tapping a section opens the child editor full-screen with the parent row passed as `parentData`.

Register a builder for each name in the `callbacks['childComponents']` map:

```dart
Map<String, dynamic> callbacks = {
  "childComponents": {
    "UsersFoodTimes": ({
      required Map<String, dynamic> parentData,
      Map<String, dynamic>? props,
    }) =>
        CrudEditor(
          jsonFileName: 'users_food_times.json',
          callbacks: AppCallables().getUserCallbacks(context),
          props: {...?props, 'parentData': parentData},
        ),
  },
};
```

NOTE: it's important to spread the received `props` into the `CrudEditor` `props` (they carry `isChildComponent: true` and `showAppMenu: false`, which enable the back button on the pushed screen) and add `'parentData': parentData`.

The builder normally returns a `CrudEditor` whose JSON config has `"type": "child_listing"`, a `"subType"` of `"array"` (child rows stored in an array attribute of the parent row, requires `"array_name"`) or `"table"` (child rows in their own table), and `"endpointKeyNames"` mapping the API parameter name to the parent's id field.

So here the child JSON config declares the relationship:

```json
{
    "type": "child_listing",
    "subType": "array",
    "array_name": "food_times",
    "endpointKeyNames": [
        {"parameterName": "user_id", "parentElementName": "_id"}
    ]
}
```

- `subType: "array"` — child rows live inside an array attribute of the parent row (`array_name` required). Writes send `{parentKey, <array_name>: newValues, <array_name>_old: initialValues}`.
- `subType: "table"` — child rows live in their own table; the parent key is merged into each child row.

### JSON-driven CRUD

#### assets/config_dbdef/backend/app_main_menu.json

Here you can define the menu structure of the app. The menu is defined as a list of menu items, where each menu item can be a navigation link (nav_link, a top level menu item) or a dropdown menu (nav_dropdown, a menu item that contains a list of other menu items).

```json
[
    {
        "title": "Dashboard",
        "location": "top_menu",
        "type": "nav_link",
        "path": "/",
        "element": "HomePage",
        "hard_prefix": false,
        "reload": true
    },
    {
        "title": "Sub Menu",
        "location": "top_menu",
        "type": "nav_dropdown",
        "sec_group": "users",
        "sub_menu_options": [
            {
                "type": "editor",
                "sec_group": "users",
                "title": "Any Other Table",
                "element": "ExampleappAnyOtherCrudEditorView_EditorData"
            }
        ]
    },
    {
        "title": "User Menu",
        "location": "hamburger",
        "sub_menu_options": [
            {
                "title": "Profile",
                "path": "/profile",
                "element": "UserProfileEditor"
            },
            {
                "title": "About",
                "on_click": "|about|"
            },
            {
                "title": "Logout",
                "path": "/logout",
                "on_click": "logout"
            }
        ]
    }
]
```

#### assets/config_dbdef/backend/exampleapp_any_other_table.json

Here you can define the table physical name and other backend configuration for the table in the database.

```json
{
    "table_name": "any_other_table"
}
```

#### assets/config_dbdef/frontend/exampleapp_any_other_table.json

Here you can define the configuration to show the table data in a CRUD editor view.

```json
{
    "baseUrl": "any_other_table",
    "title": "Any Other Tables",
    "name": "Any Other Table",
    "component": "ExampleappAnyOtherCrudEditorView",
    "dbApiUrl": "any_other_table",
    "mandatoryFilters": {
        "user_id": "{CurrentUserId}"
    },
    "createReenter": true,
    "defaultOrder": "any_other_date|desc",
    "fieldElements": [
        {
            "name": "id",
            "required": true,
            "label": "ID",
            "type": "_id",
            "readonly": true,
            "hidden": true
        },
        {
            "name": "user_id",
            "required": true,
            "label": "User ID",
            "type": "text",
            "readonly": true,
            "hidden": true
        },
        {
            "name": "any_other_date",
            "required": true,
            "label": "Date",
            "type": "date",
            "readonly": false,
            "listing": true
        },
        {
            "name": "today_total_qty",
            "label": "Total Quantity",
            "type": "number",
            "readonly": true,
            "listing": true,
            "component": "UserTotalQtyAndCondition"
        },
        {
            "name": "minimun_daily_qty",
            "label": "Minimun Daily Quantity",
            "type": "component",
            "component": "UserMinimumDailyQty",
            "readonly": true,
            "listing": false
        },
        {
            "name": "observations",
            "required": false,
            "label": "Observations",
            "type": "textarea",
            "readonly": false,
            "listing": true
        }
    ],
    "childComponents": [
        "DailyMealIngredients"
    ]
}
```

### App configuration

#### assets/config

For each stage (dev, qa, staging, prod, demo, etc.), there must be `config-{stage}.json` and `stage-{stage}.json` files in the `assets/config` directory with the following structure:

#### assets/config/config-dev.json

```json
{
  "API_URL": "https://app.exampleapp.local:5001/v1",
  "ENV": "local",
}
```

#### assets/config/config-prod.json

```json
{
  "API_URL": "https://app.exampleapp.com/v1",
  "ENV": "prod",
}
```

#### assets/config/stage-dev.json

```json
{
  "STAGE": "dev"
}
```

#### assets/config/stage-prod.json

```json
{
  "STAGE": "prod"
}
```

#### assets/config/stage.json

This file defines the stage in use. It can be `dev`, `qa`, `staging`, `prod`, `demo`, etc.

```json
{
  "STAGE": "dev"
}
```

## GenericSuite package directory structure

```
genericsuite
├── analysis_options.yaml
├── CHANGELOG.md
├── genericsuite.iml
├── lib
│   ├── genericsuite.dart
│   ├── services
│   │   ├── app_callables_super.dart
│   │   ├── autocomplete_service.dart
│   │   ├── config_service.dart
│   │   ├── convertion_utilities.dart
│   │   ├── crud_editor_commons.dart
│   │   ├── crud_editor_selector.dart
│   │   ├── crud_editor_sf_filters.dart
│   │   ├── crud_editor_sf_timestamps.dart
│   │   ├── crud_editor_sf_users.dart
│   │   ├── crud_editor.dart
│   │   ├── current_user_service.dart
│   │   ├── form_field_service.dart
│   │   ├── general_messages.dart
│   │   ├── http_service.dart
│   │   ├── logout_service.dart
│   │   ├── message_service.dart
│   │   ├── redirect_service.dart
│   │   ├── select_options_service.dart
│   │   ├── theme_config_defaults.dart
│   │   ├── timestamp_utilities.dart
│   │   └── utilities.dart
│   ├── views
│   │   ├── homepage.dart
│   │   └── login.dart
│   └── widgets
│       ├── app_drawer.dart
│       ├── app_frame.dart
│       ├── back_button.dart
│       └── error_reporter_widget.dart
├── LICENSE
├── pubspec.lock
├── pubspec.yaml
├── README.md
└── test
    └── genericsuite_test.dart
```

## Additional information

<!--
TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
-->

### Package Documentation and Starter Template

- Library README:
  [genericsuite_flutter](https://github.com/tomkat-cr/genericsuite-mobile/tree/main/genericsuite_flutter)

- Starter template:
  [flutter_project_template](https://github.com/tomkat-cr/genericsuite-mobile-exampleapp)

### GenericSuite Documentation

* [https://genericsuite.carlosjramirez.com](https://genericsuite.carlosjramirez.com)
* Mirror: [https://genericsuite.readthedocs.io](https://genericsuite.readthedocs.io)

### How to contribute to the package

1. Fork the repository on GitHub.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them.
4. Push your changes to your fork.
5. Create a pull request to the main repository.

### How to file issues

1. Go to the [GenericSuite GitHub repository](https://github.com/tomkat-cr/genericsuite-mobile).
2. Click on the "Issues" tab.
3. Click on the "New Issue" button.
4. Fill out the issue template with the necessary information.
5. Submit the issue.

### What response you can expect from the package authors

1. We will respond to your issue as soon as possible.
2. If you have a bug report, we will try to fix it as soon as possible.
3. If you have a feature request, we will try to implement it as soon as possible.
4. If you have a question, we will try to answer it as soon as possible.

## License

[GenericSuite](https://genericsuite.carlosjramirez.com) is open-sourced software licensed under the MIT license.

## Credits

This project is developed and maintained by [Carlos J. Ramirez](https://carlosjramirez.com). For more information or to contribute to the GenericSuite project, visit [GenericSuite on GitHub](https://github.com/tomkat-cr/genericsuite-mobile).

Happy Coding!
