// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
// import 'package:url_launcher/link.dart';

import '../auth.dart';
import '../routing.dart';
import '../screens/sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
     appBar : AppBar (
        title: const Text('Etusivu'),
        centerTitle : true,
        backgroundColor: const Color.fromARGB(255, 112, 162, 237),
     ),
    drawer: const MyDrawer(),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: const Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                child: HomeContent(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class HomeContent extends StatelessWidget {
  const HomeContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ...[
        Image.asset(
            "graphics/logo-text-1x.png",
            height: 200,
            width: 200,
          ),
        Padding(
            padding: const EdgeInsets.only(top: 50, bottom: 10),
            child: ElevatedButton(
              onPressed: () {RouteStateScope.of(context).go('/sos_confirmation');},
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(80),
                backgroundColor: const Color.fromARGB(255, 158, 29, 20),
                textStyle: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ),
              ),
              child: const Text('SOS'),
            ),
          ),
          Text(
          'Tervetuloa Maija Malli!',
          style: Theme.of(context).textTheme.headlineSmall,
          ),
          Padding(
            padding: const EdgeInsets.all(0),
            child: OutlinedButton(
              onPressed: () async {RouteStateScope.of(context).go('/create_new_report');},
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                primary: Colors.white,
                backgroundColor: const Color.fromARGB(255, 112, 162, 237),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Tee uusi ilmoitus'),
            ),
          ),

        /*Link(
          uri: Uri.parse('/report/0'),
          builder: (context, followLink) => TextButton(
            onPressed: followLink,
            child: const Text('Go directly to /report/0 (Link)'),
          ),
        ),
        */
        /*TextButton(
          child: const Text('Go directly to /report/0 (RouteState)'),
          onPressed: () {
            RouteStateScope.of(context).go('/report/0');
          },
        ),
        */
      ].map((w) => Padding(padding: const EdgeInsets.all(8), child: w)),
      /*TextButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Alert!'),
            content: const Text('The alert description goes here.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
        child: const Text('Show Dialog'),
      )*/
    ],
  );
}
