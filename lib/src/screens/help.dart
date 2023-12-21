/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import 'package:poliisiauto/src/screens/home.dart';

import '../common.dart';
import '../widgets/drawer.dart';
import '../data.dart';
import '../api.dart';
import '../routing.dart';


class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.info)),
      drawer: const PoliisiautoDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                  child: HelpContent(),
                ),
              ),
            ),
          ),
        ),
      ));
}

class HelpContent extends StatefulWidget {
  const HelpContent({super.key});

  @override
  State<HelpContent> createState() => _HelpContentState();
}

class _HelpContentState extends State<HelpContent> {
  late Future<Organization> futureOrganization;
  late final routeState = RouteStateScope.of(context); // Declare routeState here
  @override
  void initState() {
    super.initState();
    futureOrganization = api.fetchAuthenticatedUserOrganization();
  }


  @override
  Widget build(BuildContext context) => Column(

    children: [
      ...[
        Text(
          AppLocalizations.of(context)!.helpPages,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Divider(),
        Text(
          AppLocalizations.of(context)!.helpInfoText,
          textAlign: TextAlign.center,
        ),
        const Divider(),
      ],
      FutureBuilder<Organization>(
        future: futureOrganization,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Text(
                  '${AppLocalizations.of(context)!.organization}: ${snapshot.data!.name}\n${snapshot.data!.completeAddress}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    routeState.go('/home');

                  },
                  child: Icon(Icons.arrow_back),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      )
    ],
  );
}