// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:poliisiauto/src/screens/new_report.dart';
import '../routing/route_state.dart';
import '../auth.dart';
import '../common.dart';
import '../widgets/drawer.dart';
import 'send_emergency_report.dart';

class HomeScreen extends StatefulWidget {
  final RouteState? routeState;

  const HomeScreen({
    Key? key,
    required this.routeState,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RouteState? get _routeState => widget.routeState;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
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
    floatingActionButton: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0, top: 260),
            child: SizedBox(
              width: 200, // Set the desired width
              child: FloatingActionButton(
                onPressed: () => _openNewReportScreen(context),
                tooltip: AppLocalizations.of(context)!.makeReport,
                backgroundColor: const Color.fromARGB(255, 32, 112, 232),
                child: Text(AppLocalizations.of(context)!.makeReport.toUpperCase()),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40), // Adjust the radius as needed
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: FloatingActionButton(
              onPressed: () => _openEmergencyReportScreen(context),
              tooltip: AppLocalizations.of(context)!.emergencyReport,
              backgroundColor: Colors.red,
              child: const Icon(Icons.warning_amber_outlined, size: (30)),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: ElevatedButton(
              onPressed: () {
                PoliisiautoAuthScope.of(context).signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 32, 112, 232),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Icon(Icons.logout_outlined),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: ElevatedButton(
              onPressed: () {
                // Update the state of the app
                _routeState?.go('/help');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 32, 112, 232),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                ),
              ),
              child: const Icon(Icons.help_outline_outlined),
            ),
          ),
        ),
      ],
    ),
  );


  void _openNewReportScreen(BuildContext context) async {
    return Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => const NewReportScreen(),
    ))
        .then((result) {
    });
  }

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
    Key? key,
  }) : super(key: key);

  // This is the StatelessWidget's overridden actual HomeContent
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
        SizedBox(height: 80),
        NewestReportTextField(),
      ].map((w) => Padding(padding: const EdgeInsets.all(8), child: w)),
    ],
  );
}

class NewestReportTextField extends StatefulWidget {
  const NewestReportTextField({Key? key}) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<NewestReportTextField> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController footerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Set background color
        border: Border.all(color: Colors.grey, width: 1.0), // Set grey 1px border
        borderRadius: BorderRadius.circular(10.0), // Set border radius
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Title
          TextField(
            readOnly: true,
            decoration: InputDecoration(
                hintText: 'Report title placeholder',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)
            ),
            controller: titleController,
          ),

          SizedBox(height: 10),

          // Content with two lines of text
          TextField(
            readOnly: true,
            decoration: InputDecoration(
                hintText: 'Date: 12.12.2023, 14.30',
                focusedBorder: InputBorder.none,
                border: InputBorder.none,
                hintStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)
            ),
            controller: contentController,
            maxLines: 2,
            style: TextStyle(color: Colors.black), // Set text color
          ),

          SizedBox(height: 10),

          // Footer with a text
          TextField(
            autofocus: false,
            readOnly: true,
            decoration: InputDecoration(
                focusedBorder: InputBorder.none,
                hintStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                hintText: 'To: Mrs Jane Doe - Status',
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)
            ),
            controller: footerController,
            style: TextStyle(color: Colors.black), // Set text color
          ),
        ],
      ),
    );
  }
}