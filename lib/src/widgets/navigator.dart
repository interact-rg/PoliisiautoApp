/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import 'package:flutter/material.dart';
import '../routing.dart';
import 'fade_transition_page.dart';
import '../screens/splash.dart';
import '../screens/sign_in.dart';
import '../screens/home.dart';
import '../screens/reports.dart';
import '../screens/help.dart';
import '../screens/information.dart';
import '../screens/settings.dart';

/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
class PoliisiautoNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const PoliisiautoNavigator({
    required this.navigatorKey,
    super.key,
  });

  @override
  State<PoliisiautoNavigator> createState() => _PoliisiautoNavigatorState();
}

class _PoliisiautoNavigatorState extends State<PoliisiautoNavigator> {
  final _splashKey = const ValueKey('Splash');
  final _signInKey = const ValueKey('Sign in');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final currentRoute = routeState.route;
    final pathTemplate = currentRoute.pathTemplate;

    // TODO: Wrap this with try-catch. Then, if a SessionExpiredException is thrown, redirect to /home!

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        return route.didPop(result);
      },
      pages: [
        //////////////////////////////////////////////////////////////////////
        // Display the special screens
        //////////////////////////////////////////////////////////////////////
        if (pathTemplate == '/splash')
          // Display the splash screen
          FadeTransitionPage<void>(
            key: _splashKey,
            child: const SplashScreen(duration: 3),
          )
        else if (pathTemplate == '/signin')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _signInKey,
            child: const SignInScreen(),
          )
        else ...[
          //////////////////////////////////////////////////////////////////////
          // Display the app
          //////////////////////////////////////////////////////////////////////
          if (pathTemplate.startsWith('/home') || pathTemplate == '/')
            FadeTransitionPage<void>(
              key: const ValueKey('home'),
              child: HomeScreen(routeState: routeState),
            )
          else if (pathTemplate.startsWith('/reports'))
            const FadeTransitionPage<void>(
              key: ValueKey('reports'),
              child: ReportsScreen(),
            )
          else if (pathTemplate.startsWith('/help'))
            const FadeTransitionPage<void>(
              key: ValueKey('help'),
              child: HelpScreen(),
            )
          else if (pathTemplate.startsWith('/information'))
            const FadeTransitionPage<void>(
              key: ValueKey('information'),
              child: InformationScreen(),
            )
          else if (pathTemplate.startsWith('/settings'))
            const FadeTransitionPage<void>(
              key: ValueKey('settings'),
              child: SettingsScreen(),
            )

          // Avoid building a Navigator with an empty `pages` list when the
          // RouteState is set to an unexpected path, such as /signin.
          //
          // Since RouteStateScope is an InheritedNotifier, any change to the
          // route will result in a call to this build method, even though this
          // widget isn't built when those routes are active.
          else
            FadeTransitionPage<void>(
              key: const ValueKey('empty'),
              child: Container(),
            ),

          // Add an additional page to the stack if the user is viewing a report

          // ...
        ],
      ],
    );
  }
}
