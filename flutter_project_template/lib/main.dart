import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:genericsuite/services/create_gs_app.dart';
import 'package:genericsuite/services/theme_config_defaults.dart';

void main() {
  runApp(const GsExampleApp());
}

class GsExampleApp extends StatelessWidget {
  const GsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> tp = {
      ...defaultThemeParams,
    };
    return MaterialApp(
      title: 'GenericSuite Mobile ExampleApp',
      theme: buildGsMaterialTheme(tp),
      // theme: ThemeData(
      //   useMaterial3: true,
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color(0xFF0052CC), // GenericSuite Blue-ish
      //     brightness: Brightness.light,
      //   ),
      //   textTheme: GoogleFonts.interTextTheme(),
      // ),
      // darkTheme: ThemeData(
      //   useMaterial3: true,
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color(0xFF0052CC),
      //     brightness: Brightness.dark,
      //   ),
      //   textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      // ),
      // themeMode: ThemeMode.system,
      home: const AppHome(),
    );
  }
}

class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Text('GenericSuite Mobile ExampleApp'),
            ElevatedButton(
              child: const Text('Go to AppHome'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppHome()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
