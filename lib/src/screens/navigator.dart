// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:poliisiauto/src/screens/create_new_report.dart';
import 'package:poliisiauto/src/screens/home.dart';
import 'package:poliisiauto/src/screens/messages.dart';
import 'package:poliisiauto/src/screens/my_reports.dart';

import '../auth.dart';
import '../data.dart';
import '../routing.dart';
import '../screens/front_page.dart';
import '../screens/forgot_password.dart';
import '../screens/sign_in.dart';
import '../widgets/fade_transition_page.dart';
import 'author_details.dart';
import 'book_details.dart';
import 'scaffold.dart';

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
  final _frontPageKey = const ValueKey('Front page');
  final _homePageKey = const ValueKey('Home page');
  final _forgotPasswordKey = const ValueKey('Forgot Password');
  final _signInKey = const ValueKey('Sign in');
  final _createNewReportKey = const ValueKey('New Report');
  final _myReportsKey = const ValueKey('My Reports');
  final _myMessagesKey = const ValueKey('My Messages');
  // final _scaffoldKey = const ValueKey('App scaffold');
  final _bookDetailsKey = const ValueKey('Book details screen');
  final _authorDetailsKey = const ValueKey('Author details screen');

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = PoliisiautoAuthScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    Book? selectedBook;
    if (pathTemplate == '/report/:reportId') {
      selectedBook = libraryInstance.allBooks.firstWhereOrNull(
          (b) => b.id.toString() == routeState.route.parameters['reportId']);
    }

    Author? selectedAuthor;
    if (pathTemplate == '/author/:authorId') {
      selectedAuthor = libraryInstance.allAuthors.firstWhereOrNull(
          (b) => b.id.toString() == routeState.route.parameters['authorId']);
    }

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        // When a page that is stacked on top of the scaffold is popped, display
        // the /books or /authors tab in BookstoreScaffold.
        if (route.settings is Page &&
            (route.settings as Page).key == _bookDetailsKey) {
          routeState.go('/reports/popular');
        }

        if (route.settings is Page &&
            (route.settings as Page).key == _authorDetailsKey) {
          routeState.go('/authors');
        }

        return route.didPop(result);
      },
      pages: [
        if (routeState.route.pathTemplate == '/frontpage')
          // Display front page.
          FadeTransitionPage<void>(
            key: _frontPageKey,
            child: FrontPageScreen(
              onFrontPage: (buttons) async {
              },
            ),
          )
        else if (routeState.route.pathTemplate == '/forgot_password')
          // Display forgot password screen.
          FadeTransitionPage<void>(
            key: _forgotPasswordKey,
            child: ForgotPasswordScreen(
              onForgotPassword: (buttons) async {
              },
            ),
          )
        else if (routeState.route.pathTemplate == '/signin')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _signInKey,
            child: SignInScreen(
              onSignIn: (credentials) async {
                var signedIn = await authState.signIn(
                    credentials.username, credentials.password);
                if (signedIn) {
                  await routeState.go('/home');
                }
              },
            ),
          )
        else if (routeState.route.pathTemplate == '/home')
          FadeTransitionPage<void>(
            key: _homePageKey,
            child: const HomeScreen()
          )
        else if (routeState.route.pathTemplate == '/create_new_report')
          FadeTransitionPage<void>(
            key: _createNewReportKey,
            child: const CreateNewReportScreen()
          )
        else if (routeState.route.pathTemplate == '/my_reports')
          FadeTransitionPage<void>(
            key: _myReportsKey,
            child: const MyReportsScreen()
          )
        else if (routeState.route.pathTemplate == '/messages')
          FadeTransitionPage<void>(
            key: _myMessagesKey,
            child: const MyMessagesScreen()
          )
      ],
    );
  }
}
