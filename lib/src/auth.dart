/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import 'package:flutter/widgets.dart';
import 'api.dart';
import 'data.dart';

////////////////////////////////////////////////////////////////////////////////
/// Helpers
////////////////////////////////////////////////////////////////////////////////

PoliisiautoAuth getAuth(BuildContext context) {
  return PoliisiautoAuthScope.of(context);
}

bool isTeacher(BuildContext context) {
  PoliisiautoAuth auth = getAuth(context);
  return auth.signedIn && auth.user?.role == UserRole.teacher;
}

bool isStudent(BuildContext context) {
  PoliisiautoAuth auth = getAuth(context);
  return auth.signedIn && auth.user?.role == UserRole.student;
}

/// A mock authentication service
class PoliisiautoAuth extends ChangeNotifier {
  bool _signedIn = false;
  User? user;

  bool get signedIn => _signedIn;

  Future<void> signOut() async {
    try {
      await api.sendLogout();
    } catch (e) {
      print('DEBUG: Logout API call failed: $e');
    }

    // Always clear local session
    await api.deleteToken();
    _signedIn = false;
    user = null;

    notifyListeners();
  }

  Future<bool> signIn(Credentials credentials) async {
    // START: BYPASS AUTHENTICATION
    // Original implementation
    //await Future<void>.delayed(const Duration(milliseconds: 200));

    // String? token =await api.sendLogin(credentials);
    String? token = "apitoken";

    print('TOKEN: $token');

    // if (token != null) {
    api.setToken(token);
    api.getTokenAsync().then((t) {
      print('TOKEN SAVED: $t');
    });
    return _tryInitializeSession();
    // }

    // return false;
    // END: BYPASS AUTHENTICATION
  }

  Future<bool> signInWithToken(String token) async {
    api.setToken(token);
    return _tryInitializeSession();
  }

  Future<bool> tryRestoreSession() async {
    // Before trying anything, check if we have an existing token stored
    if (!(await api.hasTokenStored())) return false;

    return _tryInitializeSession();
  }

  Future<bool> _tryInitializeSession() async {
    try {
      user = await api.fetchAuthenticatedUser();

      _signedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is PoliisiautoAuth && other._signedIn == _signedIn;

  @override
  int get hashCode => _signedIn.hashCode;
}

class PoliisiautoAuthScope extends InheritedNotifier<PoliisiautoAuth> {
  const PoliisiautoAuthScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static PoliisiautoAuth of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<PoliisiautoAuthScope>()!
      .notifier!;
}
