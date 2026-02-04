/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'src/app.dart';
import 'src/services/fcm_service.dart';

void main() async {
  /// load the environment file...
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize FCM
  final fcmService = FCMService();
  await fcmService.initialize();

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(
      FCMService.firebaseMessagingBackgroundHandler);

  /// ...and run the app
  runApp(PoliisiautoApp(fcmService: fcmService));
}
