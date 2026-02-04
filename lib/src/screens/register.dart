import 'package:flutter/material.dart';
import '../api.dart';
import '../routing.dart';
import '../auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _deviceNameController = TextEditingController(text: 'Mobile Device');

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekisteröidy')),
      body: Center(
        child: Container(
          constraints: BoxConstraints.loose(const Size(600, 800)),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'Etunimi'),
                    validator: (v) => v!.isEmpty ? 'Pakollinen' : null,
                  ),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Sukunimi'),
                    validator: (v) => v!.isEmpty ? 'Pakollinen' : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Sähköposti'),
                    validator: (v) => v!.isEmpty ? 'Pakollinen' : null,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Salasana'),
                    obscureText: true,
                    validator: (v) => v!.length < 8 ? 'Min 8 merkkiä' : null,
                  ),
                  TextFormField(
                    controller: _deviceNameController,
                    decoration:
                        const InputDecoration(labelText: 'Laitteen nimi'),
                    validator: (v) => v!.isEmpty ? 'Pakollinen' : null,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _register,
                          child: const Text('Rekisteröidy'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'password_confirmation': _passwordController.text,
      'device_name': _deviceNameController.text,
    };

    try {
      final token = await api.registerDevice(data);
      if (token != null) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Rekisteröinti onnistui! Kirjaudutaan sisään...')));

        // Auto-login
        final auth = getAuth(context);
        final success = await auth.signInWithToken(token);

        if (success) {
          // Navigate to home
          if (mounted) RouteStateScope.of(context).go('/home');
        } else {
          if (mounted)
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content:
                    Text('Kirjautuminen epäonnistui rekisteröinnin jälkeen.')));
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rekisteröinti epäonnistui.')));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Virhe: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
