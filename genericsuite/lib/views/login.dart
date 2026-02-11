import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/app_callables_super.dart';
import '../services/crud_editor.dart';
import '../services/http_service.dart';
import '../services/locator_service.dart';
import '../services/message_service.dart';
import '../services/redirect_service.dart';
import '../services/utilities.dart';
import 'homepage.dart';

const loginDebug = false;

const showErrorCodes = false;
const invalidCredsErrorMessage =
    "No account was found matching that username and password";

class LoginPage extends StatefulWidget {
  // final FlutterSecureStorage storage;
  final HomePageBodyBuilder homePageBodyBuilder;
  final AlternateWidgetBuilder alternateWidgetBuilder;
  final AppCallablesSuper appCallables;
  final Map<String, dynamic>? params;

  const LoginPage(
    // this.storage,
    this.homePageBodyBuilder,
    this.alternateWidgetBuilder,
    this.appCallables, {
    super.key,
    this.params,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FlutterSecureStorage storage = locator<FlutterSecureStorage>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String onboardingMessage = '';
  String errorMessage = '';
  String errorCode = '';
  int apiStatusCode = 0;

  void _initMessages() {
    setState(() {
      onboardingMessage = '';
      errorMessage = '';
      errorCode = '';
      apiStatusCode = 0;
    });
  }

  void displayDialog(BuildContext context, String title, String text) =>
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  Map<String, dynamic> validateUserPass(String username, String password) {
    Map<String, dynamic> result = {"error": '', "message": ''};
    if (username.length < 4) {
      result['error'] = 'Invalid username';
      result['message'] = 'The username should be at least 4 characters long';
    } else if (password.length < 2) {
      result['error'] = 'Invalid password';
      result['message'] = 'The password should be at least 2 characters long';
    }
    return result;
  }

  Future<Map<String, dynamic>> attemptLogIn(
    String username,
    String password,
  ) async {
    String apiUrlUsersLogin = "users/login";
    Map<String, dynamic> headers = {
      'Authorization': "Basic ${bToA("$username:$password")}",
    };
    // HttpUtilities api = HttpUtilities(widget.storage);
    HttpUtilities api = HttpUtilities();
    return api.httpsCall("post", apiUrlUsersLogin, headers, {}, {});
  }

  Future<Map<String, dynamic>> attemptSignUp(
    String username,
    String password,
  ) async {
    String apiUrlUsersSignIn = "users";
    Map<String, dynamic> body = {"username": username, "password": password};
    // HttpUtilities api = HttpUtilities(widget.storage);
    HttpUtilities api = HttpUtilities();
    return api.httpsCall("post", apiUrlUsersSignIn, {}, body, {});
  }

  void _scheduleBindings() {
    scheduleMessagesBindings(context, {
      'errorMessage': errorMessage,
      'errorCode': showErrorCodes ? errorCode : '',
    }, widget.appCallables);
    errorMessage = "";
    errorCode = "";
  }

  void _processLogin(BuildContext context) async {
    if (!context.mounted) return;

    _initMessages();
    String username = _usernameController.text;
    String password = _passwordController.text;

    Map<String, dynamic> error = validateUserPass(username, password);
    if (error['error'].isNotEmpty) {
      errorMessage = error['error'];
      errorCode = 'LP-E-050';
      _scheduleBindings();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> apiResponse = await attemptLogIn(username, password);

    if (loginDebug) {
      logDebug('LoginScreen | attemptLogIn | apiResponse');
      logDebug(apiResponse.toString());
    }

    String jwt;
    if (apiResponse['error']) {
      setState(() {
        _isLoading = false;
      });
      errorMessage = apiResponse['status_code'] == 401
          ? invalidCredsErrorMessage
          : apiResponse['error_message'];
      errorCode = apiResponse['status_code'] == 401 ? 'LP-E-030' : 'LP-E-035';
      if (loginDebug) {
        logDebug('$errorMessage\n${apiResponse['error_message']}');
      }
      _scheduleBindings();
      return;
    }
    jwt = apiResponse['resultset']['token'];
    errorMessage = '';
    if (jwt.isNotEmpty) {
      // await widget.storage.write(key: 'jwt', value: jwt);
      await storage.write(key: 'jwt', value: jwt);

      apiResponse['resultset'].remove('token');
      if (apiResponse['resultset'].containsKey('_id')) {
        apiResponse['resultset']['id'] = apiResponse['resultset']['_id'];
        apiResponse['resultset'].remove('_id');
      }

      // await widget.storage.write(
      await storage.write(
        key: 'user_data',
        value: json.encode(apiResponse['resultset']),
      );

      if (context.mounted) {
        redirectMainScreen(
          // widget.storage,
          context,
          widget.homePageBodyBuilder,
          widget.alternateWidgetBuilder,
          widget.appCallables,
        );
      }
    } else {
      if (!context.mounted) return;
      errorMessage = invalidCredsErrorMessage;
      errorCode = 'LP-E-040';
      if (loginDebug) {
        logDebug('$errorMessage\nJWT Token not found');
      }
      _scheduleBindings();
    }
  }

  void _processSignUp(BuildContext context) async {
    _initMessages();
    Map<String, dynamic> callbacks = widget.appCallables.getUserCallbacks(
      // widget.storage,
      context,
    );
    Map<String, dynamic> props = {
      'isCreation': true,
      'showAppMenu': false,
      'ignoreUserData': true,
    };
    if (loginDebug) {
      logDebug('LoginScreen | build | props: $props');
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrudEditor(
          // storage: widget.storage,
          jsonFileName: 'onboarding_users.json',
          appCallables: widget.appCallables,
          callbacks: callbacks,
          props: props,
          // backButtonAction: (storage) {
          backButtonAction: () {
            if (loginDebug) {
              logDebug('LoginScreen | backButtonAction');
            }
            return _showLoginPage(context);
          },
        ),
      ),
    );
  }

  List<Widget> _loginDataForm() {
    return [
      // Logo Image
      Image.asset('assets/images/app_logo_circle.png', height: 250, width: 250),
      TextFormField(
        controller: _usernameController,
        decoration: const InputDecoration(labelText: 'Username'),
      ),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Password'),
      ),
      const SizedBox(height: 24.0),
      Center(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  child: const Text("Log In"),
                  onPressed: () {
                    _processLogin(context);
                  },
                ),
                const Text("    "),
                ElevatedButton(
                  child: const Text("Sign Up"),
                  onPressed: () {
                    _processSignUp(context);
                  },
                ),
              ],
            ),
            const Text(''),
            Text(onboardingMessage),
            const Text(''),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : const Text(''),
          ],
        ),
      ),
    ];
  }

  Widget _showLoginPage(BuildContext context) {
    const title = "";
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        leading: const SizedBox.shrink(),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 10.0, left: 20.00, right: 20.00),
        children: _loginDataForm(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.params != null) {
      if (widget.params!.containsKey('onboardingMessage')) {
        onboardingMessage = widget.params!['onboardingMessage'];
      }
      if (widget.params!.containsKey('errorMessage')) {
        errorMessage = widget.params!['errorMessage'];
      }
      if (widget.params!.containsKey('errorCode')) {
        errorCode = widget.params!['errorCode'];
      }
      if (widget.params!.containsKey('apiStatusCode')) {
        apiStatusCode = widget.params!['apiStatusCode'];
      }
      if (errorMessage.isNotEmpty) {
        _scheduleBindings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showLoginPage(context);
  }
}
