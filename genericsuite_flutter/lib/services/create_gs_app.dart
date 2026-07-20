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
import 'package:genericsuite/services/theme_config_defaults.dart';
import 'package:genericsuite/services/utilities.dart';
import 'package:genericsuite/views/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const createGsAppDebug = false;

const loginInitialParams = {
  "onboardingMessage": "",
  "errorMessage": "",
  "errorCode": "",
  "statusCode": 0,
};

/*
 * Build the MaterialApp ThemeData from the GenericSuite theme tokens
 * (defaultThemeParams merged with the app's getThemeParams()) [GS-261].
 */
ThemeData buildGsMaterialTheme(Map<String, dynamic> tp) {
  final Color accent = tp['accentColor'] ?? accentColor;
  final double radius = ((tp['borderRadius'] ?? borderRadius) as num)
      .toDouble();
  final Color text = tp['textColor'] ?? textColor;
  final Color separator = tp['separatorColor'] ?? separatorColor;
  final BorderRadius corners = BorderRadius.circular(radius);

  TextTheme baseTextTheme;
  if (tp['textTheme'] != null) {
    baseTextTheme = tp['textTheme'];
  } else if ((tp['fontFamily'] ?? gsFontFamily) == 'Inter') {
    baseTextTheme = GoogleFonts.interTextTheme();
  } else {
    baseTextTheme = Typography.blackCupertino.apply(
      fontFamily: tp['fontFamily'],
    );
  }
  baseTextTheme = baseTextTheme.apply(bodyColor: text, displayColor: text);

  return ThemeData(
    useMaterial3: true,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
        ).copyWith(
          surface: tp['scaffoldBackgroundColor'] ?? scaffoldBackgroundColor,
          error: tp['errorBackgroundColor'] ?? errorBackgroundColor,
        ),
    scaffoldBackgroundColor:
        tp['scaffoldBackgroundColor'] ?? scaffoldBackgroundColor,
    textTheme: baseTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: tp['appBarBackgroundColor'] ?? appBarBackgroundColor,
      foregroundColor: tp['appBarForegroundColor'] ?? appBarForegroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: corners,
        borderSide: BorderSide(color: separator),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: corners,
        borderSide: BorderSide(color: separator),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: corners,
        borderSide: BorderSide(color: accent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(88, 44),
        shape: RoundedRectangleBorder(borderRadius: corners),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: corners,
        side: BorderSide(color: separator),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
    ),
    dividerTheme: DividerThemeData(color: separator, thickness: 0.5),
    listTileTheme: ListTileThemeData(
      iconColor: tp['secondaryTextColor'] ?? secondaryTextColor,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: tp['drawerBackgroundColor'] ?? drawerBackgroundColor,
    ),
  );
}

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
    final Map<String, dynamic> tp = {
      ...defaultThemeParams,
      ...appCallables.getThemeParams(),
    };
    return ShadApp.custom(
      themeMode: ThemeMode.light,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadGreenColorScheme.light(),
        radius: BorderRadius.circular(
          ((tp['borderRadius'] ?? borderRadius) as num).toDouble(),
        ),
      ),
      appBuilder: (context) {
        return MaterialApp(
          title: '${appInfo['name']}: ${appInfo['description']}',
          theme: buildGsMaterialTheme(tp),
          home: FutureBuilder(
            future: initEnvironmentAndGetJwt,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return LoginPage(params: loginInitialParams);
              }
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              if (createGsAppDebug) {
                logDebug('${appInfo['name']} | configItems: $configItems');
              }

              configItems['deviceId'] = deviceId;
              configItems['ipLocal'] = ipLocal;
              configItems['ipPublic'] = ipPublic;
              configItems['platformInfo'] = platformInfo;

              storage.write(
                key: "configItems",
                value: json.encode(configItems),
              );

              if (snapshot.data != "") {
                if (createGsAppDebug) {
                  logDebug('${appInfo['name']} | storage: $storage');
                  logDebug(
                    '${appInfo['name']} | snapshot.data: ${snapshot.data}',
                  );
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
      },
    );
  }
}
