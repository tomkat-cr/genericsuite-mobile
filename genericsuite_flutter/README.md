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

- Check the [GenericSuite Mobile Development Guide](https://genericsuite.carlosjramirez.com/Mobile-Development/) for more information about how to create mobiles apps using GenericSuite.

## Additional information

<!--
TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
-->

### Package Documentation and Starter Template

- [GenericSuite Mobile Development Guide](https://genericsuite.carlosjramirez.com/Mobile-Development/)

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
