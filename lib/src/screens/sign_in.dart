/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import '../auth.dart';
import '../common.dart';
import '../routing.dart';
import '../data.dart';
import 'forgot_password.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  /// Form fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = getAuth(context);
    final routeState = RouteStateScope.of(context);

    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              constraints: BoxConstraints.loose(const Size(600, 600)),
              padding: const EdgeInsets.all(20),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: 120, child: Image.asset('assets/logo-2x.png')),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.signin,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.giveEmail;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.email,
                        ),
                        controller: _emailController,
                        key: const ValueKey("e-mail"),
                      ),

                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.givePassword;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.password,
                        ),
                        obscureText: true,
                        controller: _passwordController,
                        key: const ValueKey("password"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: TextButton(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            bool success = await _tryLogin(authState);

                            if (success) {
                              await routeState.go('/home');
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .loginFailed),
                                        content: Text(
                                            AppLocalizations.of(context)!
                                                .checkEmailAndPassword),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .alright),
                                          ),
                                        ],
                                      ));
                            }
                          },
                          child: Text(AppLocalizations.of(context)!.signin),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: TextButton(
                          onPressed: () => _openForgotPasswordScreen(context),
                          child: Text(
                              AppLocalizations.of(context)!.forgotPassword),
                        ),
                      ),

                      /// Debug:
                      const Divider(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                _emailController.text = 'olli.o@esimerkki.fi';
                                _passwordController.text = 'salasana';
                              },
                              key: const ValueKey("debug teacher"),
                              child: const Text('Olli O. (opettaja)',
                                  style: TextStyle(color: Colors.orange)),
                            ),
                            TextButton(
                              onPressed: () {
                                _emailController.text = 'kaisa.k@esimerkki.fi';
                                _passwordController.text = 'salasana';
                              },
                              child: const Text('Kaisa K. (opettaja)',
                                  style: TextStyle(color: Colors.orange)),
                            ),
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Divider(),
                          TextButton(
                            onPressed: () {
                              _emailController.text = 'kerttu.k@esimerkki.fi';
                              _passwordController.text = 'salasana';
                            },
                            key: const ValueKey("debug student"),
                            child: const Text('Kerttu K. (oppilas)',
                                style: TextStyle(color: Colors.orange)),
                          ),
                          TextButton(
                            onPressed: () {
                              _emailController.text = 'ville.v@esimerkki.fi';
                              _passwordController.text = 'salasana';
                            },
                            child: const Text('Ville V. (oppilas)',
                                style: TextStyle(color: Colors.orange)),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              _emailController.text = 'elli.e@esimerkki.fi';
                              _passwordController.text = 'salasana';
                            },
                            child: const Text('Elli E. (oppilas)',
                                style: TextStyle(color: Colors.orange)),
                          ),
                        ],
                      ) // Debug ends
                    ],
                  )),
            ),
          ]),
    );
  }

  Future<bool> _tryLogin(PoliisiautoAuth authState) async {
    Credentials credentials = Credentials(_emailController.value.text,
        _passwordController.value.text, _getDeviceName());

    return await authState.signIn(credentials);
  }

  void _openForgotPasswordScreen(BuildContext context) async {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
  }

  String _getDeviceName() {
    // TODO: Get or ask actual name
    return 'Android';
  }
}
