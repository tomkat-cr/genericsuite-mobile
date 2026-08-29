import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../services/current_user_service.dart';
import '../services/message_service.dart';
import '../services/utilities.dart';
import '../widgets/app_frame.dart';

const debug = false;

typedef HomePageBodyBuilder = Widget Function(Map<String, dynamic> userData);

typedef AlternateWidgetBuilder = Widget Function();

class HomePage extends StatefulWidget {
  final HomePageBodyBuilder homePageBodyBuilder;

  const HomePage({super.key, required this.homePageBodyBuilder});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String errorMessage = '';
  String errorCode = '';
  String infoMessage = '';
  Map<String, dynamic> userData = {};
  late Future<Map<String, dynamic>> _homeDataFuture;

  @override
  void initState() {
    super.initState();

    // TODO: inserted from a @claude review suggestion. Is it good to do it here?
    _homeDataFuture = loadHomeData(true);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      showScaffoldMessages(context);
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
      showScaffoldMessages(context);
    });
  }

  void showScaffoldMessages(BuildContext context) {
    if (debug) {
      logDebug(
        'HomePage | showScaffoldMessages | errorMessage: $errorMessage | infoMessage: $infoMessage',
      );
    }
    if (errorMessage.isNotEmpty) {
      showScaffoldMessage(errorMessage, context, typeError);
      errorMessage = "";
    }
    if (infoMessage.isNotEmpty) {
      showScaffoldMessage(infoMessage, context, typeInfo);
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
    return getCurrentUserData()
        .then((data) {
          if (data['errorMessage'].isNotEmpty) {
            errorMessage = data['errorMessage'];
            return Future.value(userData);
          }
          userData = data['userData'];
          return Future.value(userData);
        })
        .catchError((error) {
          errorMessage = error.toString();
          return Future.value(userData);
        });
  }

  Widget buildHomePage(BuildContext context) {
    return AppFrame(
      body: Center(
        child: FutureBuilder(
          future: _homeDataFuture,
          builder: (context, snapshot) =>
              snapshot.hasData && errorMessage.isEmpty
              ? widget.homePageBodyBuilder(userData)
              : snapshot.hasError || errorMessage.isNotEmpty
              ? snapshot.hasError
                    ? Text(setErrorMessage(snapshot.error.toString()))
                    : Text(setErrorMessage("Error loading data"))
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildHomePage(context);
  }
}
