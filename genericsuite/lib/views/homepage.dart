import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/app_callables_super.dart';
import '../services/current_user_service.dart';
import '../services/message_service.dart';
import '../services/utilities.dart';
import '../widgets/app_frame.dart';

const debug = false;

typedef HomePageBodyBuilder = Widget Function(
    FlutterSecureStorage storage, Map<String, dynamic> userData);

typedef AlternateWidgetBuilder = Widget Function(FlutterSecureStorage storage);

class HomePage extends StatefulWidget {
  final FlutterSecureStorage storage;
  final HomePageBodyBuilder homePageBodyBuilder;
  final AlternateWidgetBuilder alternateWidgetBuilder;
  final AppCallablesSuper appCallables;

  const HomePage(this.storage, this.homePageBodyBuilder,
      this.alternateWidgetBuilder, this.appCallables,
      {Key? key})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String errorMessage = '';
  String errorCode = '';
  String infoMessage = '';
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      showScaffoldMessages(context, widget.appCallables);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      showScaffoldMessages(context, widget.appCallables);
    });
  }

  void showScaffoldMessages(
      BuildContext context, AppCallablesSuper appCallables) {
    if (debug) {
      logDebug(
          'HomePage | showScaffoldMessages | errorMessage: $errorMessage | infoMessage: $infoMessage');
    }
    if (errorMessage.isNotEmpty) {
      showScaffoldMessage(errorMessage, context, typeError, appCallables);
      errorMessage = "";
    }
    if (infoMessage.isNotEmpty) {
      showScaffoldMessage(infoMessage, context, typeInfo, appCallables);
      infoMessage = "";
    }
  }

  String setErrorMessage(dynamic error) {
    errorMessage = error.toString();
    return "";
  }

  Future<Map<String, dynamic>> loadHomeData(bool stateUpdate) {
    if (userData.isNotEmpty) {
      // Cache user data to avoid repeated API calls to "/users/current_user_d"
      return Future.value(userData);
    }
    return getCurrentUserData(widget.storage).then((data) {
      if (data['errorMessage'].isNotEmpty) {
        errorMessage = data['errorMessage'];
        return Future.value(userData);
      }
      userData = data['userData'];
      return Future.value(userData);
    }).catchError((error) {
      errorMessage = error.toString();
      return Future.value(userData);
    });
  }

  Widget buildHomePage(BuildContext context) {
    // const title = "Dashboard";
    return AppFrame(
      storage: widget.storage,
      appCallables: widget.appCallables,
      body: Center(
        child: FutureBuilder(
            future: loadHomeData(true),
            builder: (context, snapshot) =>
                snapshot.hasData && errorMessage.isEmpty
                    ? widget.homePageBodyBuilder(widget.storage, userData)
                    : snapshot.hasError || errorMessage.isNotEmpty
                        ? snapshot.hasError
                            ? Text(setErrorMessage(snapshot.error.toString()))
                            : Text(setErrorMessage("Error loading data"))
                        : const Center(child: CircularProgressIndicator())),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildHomePage(context);
  }
}
