# GenericSuite for mobile applications package


<img 
    align="right"
    width="100"
    height="100"
    src="https://genericsuite.carlosjramirez.com/images/gs_logo_circle.svg"
    title="GenericSuite logo by Carlos J. Ramirez"
/>

Welcome to GenericSuite, a comprehensive software solution designed to help you enhance your productivity and streamline your workflows. This repository contains the mobile part of GenericSuite, equipped with a suite of tools to kickstart your Android and iOS Mobile App development process.

### Directory structure

```
genericsuite-mobile/
├── flutter_project_template/  # Flutter project template
└── genericsuite/              # Flutter/Dart version of GenericSuite package
```

## Flutter project template

The [Flutter project template](./flutter_project_template/README.md) is a flutter project ready to publish your app in the Google Play Store.

To use it follow these steps:

1. Clone the repository.
    ```bash
    git clone https://github.com/tomkat-cr/genericsuite-mobile.git
    ```

2. Make a copy of all your code, specially the `ios` directory. **PLEASE DON'T SKIP THIS STEP**, otherwise if you get the error mentioned in the Troubleshooting section, you won't be able to run the app in an iOS device simulator.

3. Copy the `flutter_project_template` directory to your desired location, e.g. `~/Documents/FlutterProjects/MyApp`.

4. Open the `MyApp` directory in your preferred IDE, e.g. Visual Studio Code, Cursor, Antigravity, Android Studio, etc.

5. Search and replace globally the following strings (case sensitive, complete words):
    - `com.genericsuite.gsexampleapp` with your app package domain and app name (use short name for the app name, e.g. `com.mydomain.myapp`)
    - `com.genericsuite` with your app package domain (e.g. `com.mydomain`)
    - `gsexampleapp` with your app name in all lowercase (e.g. `myapp`)
    - `GS ExampleApp` with your app short name (capitalized, short because it's the name in the SmartPhone launch screen, e.g. `My App Short Name`)
    - `GenericSuite Mobile Example App` with your app long name (capitalized, e.g. `My App Long Name`)
    - `genericsuite-mobile-example-app` with your app name (capitalized, e.g. `my-app`)

6. Rename the following files:
    - `gsexampleapp.iml` to `myapp.iml`
    - `android/gsexampleapp_android.iml` to `android/myapp_android.iml`
    - `android/app/src/main/kotlin/com/genericsuite/gsexampleapp` to `android/app/src/main/kotlin/com/mydomain/myapp`
    
7. Install the dependencies:
    ```bash
    flutter pub get
    ```

8. Replace the following directory/files with your own versions:
    - `assets/images/app_logo_circle.png`

9. Generate app icons (to let the app to have custom icon with its logo)
    ```bash
    make generate_icons
    ```

10. If you don't have a keystore, generate one using the `make generate_keystore` command.
    ```bash
    make generate_keystore
    ```

    Notes:
    - It will ask you for the keystore password, key password and key alias. Write them down in a safe place, you will need them for the next step and for signing your app.

11. Create a file named `android/key.properties` that contains a reference to your keystore.
    ```properties
    storePassword=<password-from-previous-step>
    keyPassword=<password-from-previous-step>
    keyAlias=upload
    storeFile=<keystore-file-location>
    ```

    Notes:
    - Don't include the angle brackets (`< >`). They indicate that the text serves as a placeholder for your values.
    - The `storeFile` might be located at `/Users/<user name>/upload-keystore.jks` on macOS or `C:\\Users\\<user name>\\upload-keystore.jks` on Windows.
    - The Windows path to `keystore.jks` must be specified with double backslashes: `\\`.
    - Check the [Build and release an Android app](https://docs.flutter.dev/deployment/android) for more information.

    Warning:
    - Keep the `key.properties` file private; don't check it into public source control.

12. Build the bundle (it's a Google Play Store requirement)
    ```bash
    make build_bundle
    ```

### Troubleshooting

If you get the following error running `main.dart` in a iOS device simulator, even after installing CocoaPods:

```
Warning: CocoaPods not installed. Skipping pod install.
  CocoaPods is a package manager for iOS or macOS platform code.
  Without CocoaPods, plugins will not work on iOS or macOS.
  For more info, see https://flutter.dev/to/platform-plugins

For installation instructions, see https://guides.cocoapods.org/using/getting-started.html#installation

CocoaPods not installed or not in valid state.
```

1. Delete the `ios` directory.

2. Restore the `ios` directory from your original code.

3. Run:
   ```bash
   make clean_ios
   ```

## Flutter/Dart version

Check the [Flutter/Dart version of GenericSuite package](./genericsuite/README.md) for more information.

## Documentation

* [https://genericsuite.carlosjramirez.com](https://genericsuite.carlosjramirez.com)

## License

[GenericSuite](https://genericsuite.carlosjramirez.com) is open-sourced software licensed under the ISC license.

## Credits

This project is developed and maintained by [Carlos J. Ramirez](https://carlosjramirez.com). For more information or to contribute to the GenericSuite project, visit [GenericSuite on GitHub](https://github.com/tomkat-cr/genericsuite-mobile).

Happy Coding!
