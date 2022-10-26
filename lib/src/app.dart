// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import 'auth.dart';
import 'routing.dart';
import 'screens/navigator.dart';

class Poliisiauto extends StatefulWidget {
  const Poliisiauto({super.key});

  @override
  State<Poliisiauto> createState() => _PoliisiautoState();
}

class _PoliisiautoState extends State<Poliisiauto> {
  final _auth = PoliisiautoAuth();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed path templates.
    _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/frontpage',
        '/forgot_password',
        '/signin',
        '/home',
        '/reports',
        '/reports/new', // TODO: Remove!
        '/reports/all', // TODO: Remove!
        '/reports/popular', // TODO: Remove!
        '/report/:reportId',
        '/profile',
        '/create_new_report',
        '/my_reports',
        '/messages',
        '/user_info',
        '/settings',
        '/sos_confirmation',
        '/send_sos',

        '/authors', // TODO: Remove!
        '/author/:authorId', // TODO: Remove!
        // '/authors',
        // '/signin',
        // '/authors',
        // '/settings',
        // '/books/new',
        // '/books/all',
        // '/books/popular',
        // '/book/:bookId',
        // '/author/:authorId',
      ],
      guard: _guard,
      initialRoute: '/frontpage',
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
  Widget build(BuildContext context) => RouteStateScope(
        notifier: _routeState,
        child: PoliisiautoAuthScope(
          notifier: _auth,
          child: MaterialApp.router(
            routerDelegate: _routerDelegate,
            routeInformationParser: _routeParser,
            // Revert back to pre-Flutter-2.5 transition behavior:
            // https://github.com/flutter/flutter/issues/82053
            theme: ThemeData(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
                },
              ),
            ),
          ),
        ),
      );

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = _auth.signedIn;
    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});
    final frontPageRoute = ParsedRoute('/frontpage', '/frontpage', {}, {});
    final forgotPasswordRoute = ParsedRoute('/forgot_password', '/forgot_password', {}, {});
    final sosConfirmationRoute = ParsedRoute('/sos_confirmation', '/sos_confirmation', {}, {});
    final sosConfirmedRoute = ParsedRoute('/send_sos', '/send_sos', {}, {});

    if (!signedIn && from != frontPageRoute && from != signInRoute && 
    from != forgotPasswordRoute && from != sosConfirmationRoute && from != sosConfirmedRoute) {
      return frontPageRoute;
      
    }
    // Go to /signin if the user is not signed in
    //else if (!signedIn && from != signInRoute) {
    //  return signInRoute;
    //}
    // Go to /home if the user is signed in and tries to go to /signin.
    else if (signedIn && from == signInRoute) {
      //return ParsedRoute('/books/popular', '/books/popular', {}, {});
      return ParsedRoute('/home', '/home', {}, {});
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
