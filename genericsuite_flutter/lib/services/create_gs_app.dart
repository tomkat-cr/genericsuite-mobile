import 'dart:convert' show json; //, base64, ascii, utf8;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genericsuite/services/app_callables_super.dart';
import 'package:genericsuite/services/config_service.dart';
import 'package:genericsuite/services/deviceid_service.dart';
import 'package:genericsuite/services/http_service.dart';
import 'package:genericsuite/services/ip_address_service.dart';
import 'package:genericsuite/services/platform_service.dart';
import 'package:genericsuite/services/locator_service.dart';
import 'package:genericsuite/services/utilities.dart';
import 'package:genericsuite/views/login.dart';

const createGsAppDebug = false;

const loginInitialParams = {
  "onboardingMessage": "",
  "errorMessage": "",
  "errorCode": "",
  "statusCode": 0,
};

class CreateGsApp extends StatefulWidget {
  final AppCallablesSuper appCallables;

  const CreateGsApp({super.key, required this.appCallables});

  @override
  State<CreateGsApp> createState() => CreateGsAppState();
}

class CreateGsAppState extends State<CreateGsApp> {
  late FlutterSecureStorage storage;
  Map<String, dynamic> configItems = {};
  late AppCallablesSuper appCallables;
  late String? deviceId;
  late String? ipLocal;
  late String? ipPublic;
  late Map<String, String> platformInfo;

  Future<String> get initEnvironmentAndGetJwt async {
    configItems = await ConfigService.getConfigItems();
    deviceId = await DeviceIdService.getDeviceId();
    ipLocal = await getLocalIpAddress();
    ipPublic = await getPublicIpAddress();
    platformInfo = getPlatformInfo();

    var jwt = await storage.read(key: "jwt");
    if (jwt == null) return "";
    return jwt;
  }

  @override
  void initState() {
    super.initState();

    setupStorageLocator(widget.appCallables.getStorage());
    storage = storageLocator<FlutterSecureStorage>();

    setupAppCallablesLocator(widget.appCallables);
    appCallables = appCallablesLocator.get<AppCallablesSuper>();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> appInfo = appCallables.getAppInfo();
    return MaterialApp(
      title: '${appInfo['name']}: ${appInfo['description']}',
      theme: ThemeData(
        primarySwatch: appCallables.getThemeParams()['primarySwatch'],
        scaffoldBackgroundColor: appCallables
            .getThemeParams()['scaffoldBackgroundColor'],
        appBarTheme: AppBarTheme(
          backgroundColor: appCallables
              .getThemeParams()['appBarBackgroundColor'],
          foregroundColor: appCallables
              .getThemeParams()['appBarForegroundColor'],
        ),
      ),
      home: FutureBuilder(
        future: initEnvironmentAndGetJwt,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return LoginPage(params: loginInitialParams);
          }
          if (!snapshot.hasData) return const CircularProgressIndicator();

          if (createGsAppDebug) {
            logDebug('${appInfo['name']} | configItems: $configItems');
          }

          configItems['deviceId'] = deviceId;
          configItems['ipLocal'] = ipLocal;
          configItems['ipPublic'] = ipPublic;
          configItems['platformInfo'] = platformInfo;

          storage.write(key: "configItems", value: json.encode(configItems));

          if (snapshot.data != "") {
            if (createGsAppDebug) {
              logDebug('${appInfo['name']} | storage: $storage');
              logDebug('${appInfo['name']} | snapshot.data: ${snapshot.data}');
              logDebug("${appInfo['name']} | Device ID: $deviceId");
            }

            var jwtStr = snapshot.data.toString();
            var jwt = jwtStr.split(".");

            if (jwt.length != 3) {
              return LoginPage(params: loginInitialParams);
            } else {
              var payload = getJwtPayload(jwtStr);
              if (DateTime.fromMillisecondsSinceEpoch(
                payload["exp"] * 1000,
              ).isAfter(DateTime.now())) {
                return appCallables.mainScreenWidget();
              } else {
                return LoginPage(params: loginInitialParams);
              }
            }
          } else {
            return LoginPage(params: loginInitialParams);
          }
        },
      ),
    );
  }
}
