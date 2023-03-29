/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import '../auth.dart';
import '../common.dart';
import '../locale_provider.dart';
import '../widgets/drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Locale? selectedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedLocale = Localizations.localeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      drawer: const PoliisiautoDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.mySettings,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(
                      'Kieli',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<Locale>(
                      value: selectedLocale,
                      onChanged: (Locale? newValue) async {
                        setState(() {
                          selectedLocale = newValue;
                        });
                        LocaleProvider.of(context)!.setLocale(selectedLocale!);
                      },
                      items: LocaleProvider.supportedLocales
                          .map<DropdownMenuItem<Locale>>((Locale locale) {
                        return DropdownMenuItem<Locale>(
                          value: locale,
                          child: Text(locale.languageCode),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout_outlined),
                      onPressed: () {
                        PoliisiautoAuthScope.of(context).signOut();
                      },
                      label: const Text('Kirjaudu ulos'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
