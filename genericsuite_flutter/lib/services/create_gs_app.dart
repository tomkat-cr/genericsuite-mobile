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

Map<String, dynamic> getNewThemeParams(Map<String, dynamic> tp) {
  Map<String, dynamic> newTp = Map<String, dynamic>.from(tp);

  newTp['accentColor'] = tp['accentColor'] ?? accentColor;
  newTp['borderRadius'] = ((tp['borderRadius'] ?? borderRadius) as num)
      .toDouble();
  newTp['textColor'] = tp['textColor'] ?? textColor;
  newTp['separatorColor'] = tp['separatorColor'] ?? separatorColor;
  newTp['separatorWidth'] = tp['separatorWidth'] ?? separatorWidth;

  newTp['scaffoldBackgroundColor'] =
      tp['scaffoldBackgroundColor'] ?? scaffoldBackgroundColor;
  newTp['errorBackgroundColor'] =
      tp['errorBackgroundColor'] ?? errorBackgroundColor;
  newTp['appBarBackgroundColor'] =
      tp['appBarBackgroundColor'] ?? appBarBackgroundColor;
  newTp['appBarForegroundColor'] =
      tp['appBarForegroundColor'] ?? appBarForegroundColor;
  newTp['secondaryTextColor'] = tp['secondaryTextColor'] ?? secondaryTextColor;
  newTp['drawerBackgroundColor'] =
      tp['drawerBackgroundColor'] ?? drawerBackgroundColor;

  newTp['focusedBorderWidth'] = ((tp['focusedBorderWidth'] ?? 2) as num).toDouble();

  newTp['contentPaddingHorizontal'] = ((tp['contentPaddingHorizontal'] ?? 12) as num).toDouble();
  newTp['contentPaddingVertical'] = ((tp['contentPaddingVertical'] ?? 12) as num).toDouble();

  newTp['shadColorSchemeName'] =
      tp['shadColorSchemeName'] ?? shadColorSchemeName;
  newTp['neutralSurfaceColor'] =
      tp['neutralSurfaceColor'] ?? neutralSurfaceColor;
  newTp['errorForegroundColor'] =
      tp['errorForegroundColor'] ?? errorForegroundColor;

  final BorderRadius corners = BorderRadius.circular(newTp['borderRadius']);
  newTp['corners'] = corners;

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
  baseTextTheme = baseTextTheme.apply(
    bodyColor: newTp['textColor'],
    displayColor: newTp['textColor'],
  );
  newTp['baseTextTheme'] = baseTextTheme;

  return newTp;
}

/*
 * Build the MaterialApp ThemeData from the GenericSuite theme tokens
 * (defaultThemeParams merged with the app's getThemeParams()) [GS-261].
 */
ThemeData buildGsMaterialTheme(Map<String, dynamic> tp) {
  Map<String, dynamic> newTp = getNewThemeParams(tp);
  return ThemeData(
    useMaterial3: true,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: newTp['accentColor'],
          brightness: Brightness.light,
        ).copyWith(
          surface: newTp['scaffoldBackgroundColor'],
          error: newTp['errorBackgroundColor'],
        ),
    scaffoldBackgroundColor: newTp['scaffoldBackgroundColor'],
    textTheme: newTp['baseTextTheme'],
    appBarTheme: AppBarTheme(
      backgroundColor: newTp['appBarBackgroundColor'],
      foregroundColor: newTp['appBarForegroundColor'],
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: newTp['corners'],
        borderSide: BorderSide(
          color: newTp['separatorColor'],
          width: newTp['separatorWidth'],
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: newTp['corners'],
        borderSide: BorderSide(
          color: newTp['separatorColor'],
          width: newTp['separatorWidth'],
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: newTp['corners'],
        borderSide: BorderSide(
          color: newTp['accentColor'],
          width: newTp['focusedBorderWidth'],
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: newTp['contentPaddingHorizontal'],
        vertical: newTp['contentPaddingVertical'],
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: newTp['accentColor'],
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(88, 44),
        shape: RoundedRectangleBorder(borderRadius: newTp['corners']),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: newTp['corners'],
        side: BorderSide(
          color: newTp['separatorColor'],
          width: newTp['separatorWidth'],
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
    ),
    dividerTheme: DividerThemeData(
      color: newTp['separatorColor'],
      thickness: newTp['separatorWidth'],
    ),
    listTileTheme: ListTileThemeData(iconColor: newTp['secondaryTextColor']),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: newTp['accentColor'],
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: newTp['drawerBackgroundColor'],
    ),
  );
}

/*
 * Build the ShadApp ShadThemeData from the GenericSuite theme tokens
 * (defaultThemeParams merged with the app's getThemeParams()) [GS-261].
 *
 * Base scheme: ShadColorScheme.fromName(shadColorSchemeName).
 * Brand: accentColor overrides primary + ring. Other GS surface/text/error
 * tokens override matching Shad slots; selection stays from the named base.
 */
ShadThemeData buildGsShadTheme(Map<String, dynamic> tp) {
  final Map<String, dynamic> newTp = getNewThemeParams(tp);
  final String schemeName =
      (newTp['shadColorSchemeName'] ?? shadColorSchemeName).toString();

  ShadColorScheme baseScheme;
  try {
    baseScheme = ShadColorScheme.fromName(
      schemeName,
      brightness: Brightness.light,
    );
  } catch (_) {
    if (createGsAppDebug) {
      logDebug(
        'buildGsShadTheme | invalid shadColorSchemeName "$schemeName", '
        'falling back to "$shadColorSchemeName"',
      );
    }
    baseScheme = ShadColorScheme.fromName(
      shadColorSchemeName,
      brightness: Brightness.light,
    );
  }

  final ShadColorScheme colorScheme = baseScheme.copyWith(
    background: newTp['scaffoldBackgroundColor'],
    foreground: newTp['textColor'],
    card: newTp['scaffoldBackgroundColor'],
    cardForeground: newTp['textColor'],
    popover: newTp['scaffoldBackgroundColor'],
    popoverForeground: newTp['textColor'],
    primary: newTp['accentColor'],
    primaryForeground: Colors.white,
    secondary: newTp['neutralSurfaceColor'],
    secondaryForeground: newTp['textColor'],
    muted: newTp['neutralSurfaceColor'],
    mutedForeground: newTp['secondaryTextColor'],
    accent: newTp['neutralSurfaceColor'],
    accentForeground: newTp['textColor'],
    destructive: newTp['errorBackgroundColor'],
    destructiveForeground: newTp['errorForegroundColor'],
    border: newTp['separatorColor'],
    input: newTp['separatorColor'],
    ring: newTp['accentColor'],
  );

  return ShadThemeData(
    brightness: Brightness.light,
    colorScheme: colorScheme,
    radius: newTp['corners'],
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
      theme: buildGsShadTheme(tp),
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
