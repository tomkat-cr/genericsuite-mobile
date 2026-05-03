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

Welcome to GenericSuite, a comprehensive software solution designed to help you enhance your productivity and streamline your workflows. This repository contains the mobile part of GenericSuite, equipped with a customizable CRUD editor, login interface and a suite of tools to kickstart your Flutter/Dart Mobile App development process.

## Features

- **Customizable CRUD editor:** core CRUD (*Create, Read, Update, Delete*) code that can be parametrized and extended by JSON configuration files. There's no need to rewrite code for each table editor.
- **Customizable menu:** menu and endpoints can be parametrized and extended by JSON configuration files in the backend side. The API will supply the menu estructure and security check based on the user's security group, and GenericSuite will draw the menu and available options.
- **Customizable Login Screen:** Easily adapt the login screen to match your brand identity with the App logo.
- **Development and Production Scripts:** Quick commands to start development or build your application for QA, staging or production environments on AWS.
- **Customizable Widgets:** A set of widgets that can be parametrized and extended by JSON configuration files.
- **Flutter/Dart:** The GenericSuite is built with Flutter/Dart, making it compatible with both Android and iOS.

The perfect companion for this mobile solution is the [backend version of The GenericSuite](https://github.com/tomkat-cr/genericsuite-be).

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

### assets/config

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

### lib/main.dart

The `main.dart` file is the entry point of the app. It is where the app is initialized and the `ExampleApp` widget is created.

```dart
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:genericsuite/services/config_service.dart';
import 'package:genericsuite/services/http_service.dart';
import 'package:genericsuite/services/redirect_service.dart';
import 'package:genericsuite/services/utilities.dart';
import 'package:genericsuite/views/login.dart';

import "domain/app_menu_callables.dart";

// "homepage_body.dart" has the HomepageBody widget, which is the main view of the app
import "widgets/homepage_body.dart";

// "exampleapp_any_other_crud_editor_view.dart" has the ExampleappAnyOtherCrudEditorView widget,
// which is also an alternative view for the HomepageBody widget
import "views/exampleapp_any_other_crud_editor_view.dart";

const storage = FlutterSecureStorage();

const loginInitialParams = {
  "onboardingMessage": "Welcome to ExampleApp",
  "errorMessage": "",
  "errorCode": "",
  "statusCode": 0,
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Map<String, dynamic> configItems = await ConfigService.getConfigItems();
  runApp(ExampleApp(configItems));
}

class ExampleApp extends StatelessWidget {
  final Map<String, dynamic> configItems;

  const ExampleApp(this.configItems, {Key? key}) : super(key: key);

  Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if (jwt == null) return "";
    return jwt;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExampleApp',
      theme: ThemeData(
        primarySwatch: AppCallables().getThemeParams()['primarySwatch'],
        scaffoldBackgroundColor:
            AppCallables().getThemeParams()['scaffoldBackgroundColor'],
        appBarTheme: AppBarTheme(
          backgroundColor:
              AppCallables().getThemeParams()['appBarBackgroundColor'],
          foregroundColor:
              AppCallables().getThemeParams()['appBarForegroundColor'],
        ),
      ),
      home: FutureBuilder(
        future: jwtOrEmpty,
        builder: (context, snapshot) {
          storage.write(key: "configItems", value: json.encode(configItems));

          if (!snapshot.hasData) return const CircularProgressIndicator();

          if (snapshot.data != "") {
            var str = snapshot.data.toString();
            var jwt = str.split(".");

            if (jwt.length != 3) {
              return LoginPage(
                  storage,
                  (s, d) => HomePageBody(s, d, AppCallables()),
                  (s) => ExampleappAnyOtherCrudEditorView(s),
                  AppCallables(),
                  params: loginInitialParams);
            } else {
              var payload = getJwtPayload(str);
              if (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
                  .isAfter(DateTime.now())) {
                return getMainScreen(
                    storage,
                    (s, d) => HomePageBody(s, d, AppCallables()),
                    (s) => ExampleappAnyOtherCrudEditorView(s),
                    AppCallables());
              } else {
                return LoginPage(
                    storage,
                    (s, d) => HomePageBody(s, d, AppCallables()),
                    (s) => ExampleappAnyOtherCrudEditorView(s),
                    AppCallables(),
                    params: loginInitialParams);
              }
            }
          } else {
            return LoginPage(
                storage,
                (s, d) => HomePageBody(s, d, AppCallables()),
                (s) => ExampleappAnyOtherCrudEditorView(s),
                AppCallables(),
                params: loginInitialParams);
          }
        },
      ),
    );
  }
}
```

### lib/config/theme_config.dart

This file defines the theme of the app (colors, styles, etc.).

```dart
import 'package:flutter/material.dart';

const primarySwatch = Colors.green;
const scaffoldBackgroundColor = Colors.white;

const appBarBackgroundColor = Colors.green;
const appBarForegroundColor = Colors.white;

const drawerBackgroundColor = appBarBackgroundColor;
const drawerForegroundColor = appBarForegroundColor;

const errorBackgroundColor = Colors.red;
const errorForegroundColor = Colors.white;

const infoBackgroundColor = Colors.blue;
const infoForegroundColor = Colors.white;

const warningBackgroundColor = Colors.yellow;
const warningForegroundColor = Colors.black;

const successBackgroundColor = Colors.green;
const successForegroundColor = Colors.white;

const closeButtonPlacement = "bottom"; // "bottom" or "right"
```

### lib/domain/app_menu_callables.dart

This file defines the app menu callables (functions that are called when an item in the app menu is selected, widgets specified in the JSON configuration files, etc.).

```dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:genericsuite/services/app_callables_super.dart';
import 'package:genericsuite/services/logout_service.dart';
import 'package:genericsuite/services/utilities.dart';
import 'package:genericsuite/views/homepage.dart';

import '../config/theme_config.dart';
import '../domain/exampleapp_crud_editor_sf_users.dart';
import '../domain/exampleapp_utilities.dart';
import '../views/exampleapp_any_other_crud_editor_view.dart';
import '../views/user_profile.dart';
import '../widgets/exampleapp_any_other_widget.dart';
import '../widgets/homepage_body.dart';

class AppCallables extends AppCallablesSuper {
  /*
   * Get the theme parameters
   */
  @override
  Map<String, dynamic> getThemeParams() {
    return {
      'primarySwatch': primarySwatch,
      'scaffoldBackgroundColor': scaffoldBackgroundColor,
      'appBarBackgroundColor': appBarBackgroundColor,
      'appBarForegroundColor': appBarForegroundColor,
      'drawerBackgroundColor': drawerBackgroundColor,
      'drawerForegroundColor': drawerForegroundColor,
      'errorBackgroundColor': errorBackgroundColor,
      'errorForegroundColor': errorForegroundColor,
      'infoBackgroundColor': infoBackgroundColor,
      'infoForegroundColor': infoForegroundColor,
      'warningBackgroundColor': warningBackgroundColor,
      'warningForegroundColor': warningForegroundColor,
      'successBackgroundColor': successBackgroundColor,
      'successForegroundColor': successForegroundColor,
      'closeButtonPlacement': closeButtonPlacement,
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
        "widget": (storage) => HomePage(storage,
            (s, d) => HomePageBody(s, d, this), (s) => ExampleappAnyOtherCrudEditorView(s), this),
        "icon": Icons.dashboard,
        "args": {}
      },
      "ExampleappAnyOtherCrudEditorView_EditorData": {
        "widget": (storage) => ExampleappAnyOtherCrudEditorView(storage),
        "icon": Icons.restaurant_menu,
        "args": {}
      },
      "UserProfileEditor": {
        "widget": (storage) => UserProfile(storage),
        "icon": Icons.person,
        "args": {}
      },
      "BillingEditor": {"widget": null, "icon": Icons.payment, "args": {}},
      "|about|": {
        "widget": (storage) => About(storage),
        "icon": Icons.info,
        "args": {}
      },
      "logout": {
        "function": (context, storage) => logOut(context, storage,
            (s, d) => HomePageBody(s, d, this), (s) => ExampleappAnyOtherCrudEditorView(s), this),
        "icon": Icons.logout,
        "args": {}
      },
    };
  }

  @override
  Map<String, dynamic> getUserCallbacks(
      FlutterSecureStorage storage, BuildContext context) {
    return {
      'specificFunctions': {
        'UsersDbPostWrite': (dynamic data,
                Map<String, dynamic> editorConfig,
                String action,
                Map<String, dynamic> params,
                FlutterSecureStorage storage,
                BuildContext? context) async =>
            usersDbPostWrite(
                data, editorConfig, action, params, storage, context),
        'UsersOnboardingDbPostWrite': (dynamic data,
                Map<String, dynamic> editorConfig,
                String action,
                Map<String, dynamic> params,
                FlutterSecureStorage storage,
                BuildContext? context) async =>
            usersOnboardingDbPostWrite(
                data, editorConfig, action, params, storage, context),
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
          userMinimumDailyQty(
            config: config,
            value: value,
            onChanged: onChanged,
            action: action,
            storage: storage,
            context: context,
            props: props,
          ),
      },
      "childComponents": {}
    };
  }
}
```

### lib/domain/exampleapp_crud_editor_sf_users.dart

This file contains the "specific functions" that are called when a user is created or updated in the database.

* *Specific Functions* are callables that extend the Generic CRUD Editor (`CrudEditor` widget) capabilities.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:genericsuite/services/crud_editor_commons.dart';
import 'package:genericsuite/services/http_service.dart';
import 'package:genericsuite/services/utilities.dart';
import 'package:genericsuite/views/login.dart';

import "../domain/app_menu_callables.dart";
import "../views/exampleapp_any_other_crud_editor_view.dart";
import "../widgets/homepage_body.dart";

const debug = false;

Future<Map<String, dynamic>> usersDbPostWrite(
  dynamic data,
  Map<String, dynamic> editorConfig,
  String action,
  Map<String, dynamic> params,
  FlutterSecureStorage storage,
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
  FlutterSecureStorage storage,
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
    (context.mounted == false ? null : context)!,
    MaterialPageRoute(
        builder: (context) => LoginPage(
            storage,
            (s, d) => HomePageBody(s, d, AppCallables()),
            (s) => ExampleappAnyOtherCrudEditorView(s),
            AppCallables(),
            params: result)),
  );

  return result;
}
```

### lib/views/about.dart

This file is a StatelessWidget that shows a simple about page with a title and a description.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:genericsuite/widgets/app_frame.dart';

import '../domain/app_menu_callables.dart';

class About extends StatefulWidget {
  final FlutterSecureStorage storage;

  const About(this.storage, {Key? key}) : super(key: key);

  @override
  AboutState createState() => AboutState();
}

class AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return AppFrame(
      storage: widget.storage,
      appCallables: AppCallables(),
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

import '../domain/app_menu_callables.dart';

class ExampleappAnyOtherCrudEditorView extends StatefulWidget {
  final FlutterSecureStorage storage;

  const ExampleappAnyOtherCrudEditorView(this.storage, {Key? key}) : super(key: key);

  @override
  ExampleappAnyOtherCrudEditorViewState createState() => ExampleappAnyOtherCrudEditorViewState();
}

class ExampleappAnyOtherCrudEditorViewState extends State<ExampleappAnyOtherCrudEditorView> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> callbacks = {
      'specificFunctions': {
        'ExampleappAnyOtherValidations': (dynamic data,
                Map<String, dynamic> editorConfig,
                String action,
                Map<String, dynamic> params,
                FlutterSecureStorage storage,
                BuildContext? context) async =>
            exampleappAnyOtherValidations(
                data, editorConfig, action, params, storage, context),
      },
      "childComponents": {
        "ExampleappAnyOtherChildComponent": (
          FlutterSecureStorage storage,
          Map<String, dynamic> props,
          String action,
          Map<String, dynamic> params,
        ) async =>
            ExampleappAnyOtherChildComponent(storage, props, action, params),
      }
    };
    Map<String, dynamic> props = {};
    return CrudEditor(
      storage: widget.storage,
      jsonFileName: 'exampleapp_any_other_table.json',
      appCallables: AppCallables(),
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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:genericsuite/services/crud_editor.dart';
import 'package:genericsuite/services/http_service.dart';
import 'package:genericsuite/services/redirect_service.dart';
import 'package:genericsuite/services/utilities.dart';

import '../domain/app_menu_callables.dart';
import '../views/exampleapp_any_other_crud_editor_view.dart';
import '../widgets/homepage_body.dart';

class UserProfile extends StatefulWidget {
  final FlutterSecureStorage storage;

  const UserProfile(this.storage, {Key? key}) : super(key: key);

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  String itemId = '';

  @override
  void initState() {
    super.initState();
    loadConfig(widget.storage).then((configStr) {
      Map<String, dynamic> config =
          Map<String, dynamic>.from(json.decode(configStr));
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
    Map<String, dynamic> callbacks =
        AppCallables().getUserCallbacks(widget.storage, context);
    Map<String, dynamic> props = {
      'isEditMode': true,
      'itemId': itemId,
    };
    return CrudEditor(
      storage: widget.storage,
      jsonFileName: 'users_profile.json',
      appCallables: AppCallables(),
      callbacks: callbacks,
      props: props,
      backButtonAction: (storage) {
        return getMainScreen(
            storage,
            (s, d) => HomePageBody(s, d, AppCallables()),
            (s) => ExampleappAnyOtherCrudEditorView(s),
            AppCallables());
      },
    );
  }
}
```

### lib/widgets/homepage_body.dart

This file contains the HomePageBody widget that is used to display the home page of the app.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:genericsuite/services/app_callables_super.dart';
import 'package:genericsuite/services/message_service.dart';
import 'package:genericsuite/services/select_options_service.dart';
import 'package:genericsuite/services/utilities.dart';

const debug = false;

class HomePageBody extends StatefulWidget {
  final FlutterSecureStorage storage;
  final Map<String, dynamic> userData;
  final AppCallablesSuper appCallables;

  const HomePageBody(this.storage, this.userData, this.appCallables, {Key? key})
      : super(key: key);

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
    scheduleMessagesBindings(
        context,
        {
          'errorMessage': errorMessage,
          'errorCode': errorCode,
          'infoMessage': infoMessage,
        },
        widget.appCallables);
  }

  String setErrorMessage(dynamic error) {
    errorMessage = error.toString();
    return "";
  }

  Widget bodyBuilder(Map<String, dynamic> data) {
    constants = data['constants'];
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
      /// negative month means it's still upcoming
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
import 'package:genericsuite/services/utilities.dart';

import '../domain/exampleapp_utilities.dart';

const bool debug = true;

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
  final FlutterSecureStorage storage;
  final Map<String, dynamic>? props;

  const UserTotalQtyAndCondition({
    Key? key,
    required this.config,
    required this.value,
    required this.onChanged,
    required this.action,
    required this.storage,
    this.props = const {},
  }) : super(key: key);

  @override
  UserTotalQtyAndConditionState createState() =>
      UserTotalQtyAndConditionState();
}

class UserTotalQtyAndConditionState
    extends State<UserTotalQtyAndCondition> {
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
      final userDataValue = await widget.storage.read(key: 'user_data');
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
  final FlutterSecureStorage storage;
  final Map<String, dynamic>? props;

  const UserMinimumDailyQty({
    Key? key,
    required this.config,
    required this.value,
    required this.onChanged,
    required this.action,
    required this.storage,
    this.props = const {},
  }) : super(key: key);

  @override
  UserMinimumDailyQtyState createState() =>
      UserMinimumDailyQtyState();
}

class UserMinimumDailyQtyState extends State<UserMinimumDailyQty> {
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

      final userDataValue = await widget.storage.read(key: 'user_data');
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
  required FlutterSecureStorage storage,
  required BuildContext context,
  Map<String, dynamic>? props,
}) {
  return UserMinimumDailyQty(
    config: config,
    value: value,
    onChanged: onChanged,
    action: action,
    storage: storage,
    props: props,
  );
}

Widget userTotalQtyAndCondition({
  required Map<String, dynamic> config,
  required String value,
  required Function onChanged,
  required String action,
  required FlutterSecureStorage storage,
  required BuildContext context,
  Map<String, dynamic>? props,
}) {
  return UserTotalQtyAndCondition(
    config: config,
    value: value,
    onChanged: onChanged,
    action: action,
    storage: storage,
    props: props,
  );
}

```

<!--
TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```
-->

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

### Documentation

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
