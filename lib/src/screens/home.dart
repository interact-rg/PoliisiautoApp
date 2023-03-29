/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import '../auth.dart';
import '../common.dart';
import '../widgets/drawer.dart';
import 'send_emergency_report.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.frontpage)),
        drawer: const PoliisiautoDrawer(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: const HomeContent(),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openEmergencyReportScreen(context),
          tooltip: AppLocalizations.of(context)!.emergencyReport,
          backgroundColor: Colors.red,
          child: const Icon(Icons.support_outlined),
        ),
      );

  void _openEmergencyReportScreen(BuildContext context) async {
    final bool? sure = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.emergencyNotification),
              content: Text(AppLocalizations.of(context)!.emergencyInfo),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(AppLocalizations.of(context)!.sure),
                ),
              ],
            ));

    // if the user canceled, do nothing
    if (sure == null || !sure || !mounted) return;

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const SendEmergencyReportScreen()));
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Image.asset(
                'assets/logo-2x.png',
                width: 100,
              ),
            ),
            Text(
              AppLocalizations.of(context)!
                  .pageHomeTitle
                  .replaceAll('{userName}', getAuth(context).user!.name),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              AppLocalizations.of(context)!.homePagePlaceholder,
              textAlign: TextAlign.center,
            ),
            const Divider(),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout_outlined),
              onPressed: () {
                PoliisiautoAuthScope.of(context).signOut();
              },
              label: Text(AppLocalizations.of(context)!.logout),
            ),
          ].map((w) => Padding(padding: const EdgeInsets.all(8), child: w)),
        ],
      );
}
