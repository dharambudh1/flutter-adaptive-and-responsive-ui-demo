import "dart:ui";

import "package:flutter/material.dart";
import "package:flutter_web_navigation/singleton/navigation_singleton.dart";
import "package:keyboard_dismisser/keyboard_dismisser.dart";
import "package:responsive_framework/responsive_framework.dart";
import "package:url_strategy/url_strategy.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: MaterialApp.router(
        builder: (BuildContext context, Widget? child) {
          return ResponsiveWrapper.builder(
            BouncingScrollWrapper.builder(
              context,
              child ?? const SizedBox(),
            ),
            maxWidth: MediaQuery.of(context).size.width,
            defaultScale: true,
            breakpoints: const <ResponsiveBreakpoint>[
              ResponsiveBreakpoint.resize(450, name: MOBILE),
              ResponsiveBreakpoint.resize(800, name: TABLET),
              ResponsiveBreakpoint.resize(1000, name: TABLET),
              ResponsiveBreakpoint.resize(1200, name: DESKTOP),
              ResponsiveBreakpoint.resize(2460, name: "4K"),
            ],
            background: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          );
        },
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.dark,
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: NavigationSingleton().router,
        scrollBehavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: <PointerDeviceKind>{
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
            PointerDeviceKind.invertedStylus,
            PointerDeviceKind.unknown,
          },
        ),
      ),
    );
  }
}
