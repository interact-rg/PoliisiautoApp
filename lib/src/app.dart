/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:poliisiauto/src/locale_provider.dart';

import 'auth.dart';
import 'common.dart';
import 'routing.dart';
import 'widgets/navigator.dart';

const primaryColor = Color.fromARGB(255, 112, 162, 237);

class PoliisiautoApp extends StatefulWidget {
  const PoliisiautoApp({super.key});

  @override
  State<PoliisiautoApp> createState() => _PoliisiautoAppState();
}

class _PoliisiautoAppState extends State<PoliisiautoApp> {
  final _auth = PoliisiautoAuth();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  @override
  void initState() {
    _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/splash',
        '/signin',
        '/forgot_password',
        '/home',
        '/reports',
        '/reports/new',
        '/new_report',
        '/reports/assigned-to-me',
        '/reports/created-by-me',
        '/reports/all',
        '/reports/:reportId',
        '/help',
        '/information',
        '/settings',
      ],
      guard: _guard,
      initialRoute: '/splash',
    );

    _routeState = RouteState(_routeParser);

    _routerDelegate = SimpleRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => PoliisiautoNavigator(
        navigatorKey: _navigatorKey,
      ),
    );

    // Listen for when the user logs out and display the signin screen.
    _auth.addListener(_handleAuthStateChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RouteStateScope(
      notifier: _routeState,
      child: PoliisiautoAuthScope(
        notifier: _auth,
        child: MaterialApp.router(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('fi', ''), // Finnish
          ],
          locale: LocaleProvider.of(context)?.locale,
          routerDelegate: _routerDelegate,
          routeInformationParser: _routeParser,
          // Revert back to pre-Flutter-2.5 transition behavior:
          // https://github.com/flutter/flutter/issues/82053
          theme: ThemeData(
            scaffoldBackgroundColor: const Color.fromARGB(255, 225, 248, 255),
            appBarTheme: const AppBarTheme(
              backgroundColor: primaryColor,
              centerTitle: true,
              iconTheme: IconThemeData(color: Color.fromARGB(255, 47, 128, 237)
),
            ),
            primaryColor: primaryColor,
            elevatedButtonTheme: const ElevatedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(primaryColor),
              ),
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          builder: (BuildContext context, Widget? child) {
            return LocaleProvider(
              child: child!,
            );
          },
        ),
      ),
    );
  }

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = _auth.signedIn;
    final splashRoute = ParsedRoute('/splash', '/splash', {}, {});
    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});
    final forgotPasswordRoute =
        ParsedRoute('/forgot_password', '/forgot_password', {}, {});
    final homeRoute = ParsedRoute('/home', '/home', {}, {});

    // Flow paths:
    // | signedIn | from == signInRoute | canRestoreSession || return value
    // |----------|---------------------|-------------------||--------------
    // |    0     |          0*         |         x         || signInRoute
    // |    0     |          1          |         0         || from
    // |    0     |          1          |         1         || homeRoute
    // |    1     |          0          |         x         || homeRoute
    // |    1     |          1          |         x         || from
    // * splash screen is an exception

    if (!signedIn) {
      // If the user IS NOT signed in...
      // ...and not on sign-in page or splash screen -> redirect there
      if (from != signInRoute &&
          from != splashRoute &&
          from != forgotPasswordRoute) {
        return signInRoute;
      }

      // ...and already in signInRoute, try restoring previous session
      if (from == signInRoute && await _auth.tryRestoreSession()) {
        return homeRoute;
      }
    } else {
      // If the user IS signed in...
      // ...going to signInRoute -> redirect home
      if (from == signInRoute) {
        return homeRoute;
      }
    }

    return from;
  }

  void _handleAuthStateChanged() {
    if (!_auth.signedIn) {
      _routeState.go('/signin');
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthStateChanged);
    _routeState.dispose();
    _routerDelegate.dispose();
    super.dispose();
  }
}
