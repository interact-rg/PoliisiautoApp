import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api.dart';
import '../routing.dart';

class TamagotchiDebugScreen extends StatefulWidget {
  const TamagotchiDebugScreen({super.key});

  @override
  State<TamagotchiDebugScreen> createState() => _TamagotchiDebugScreenState();
}

class _TamagotchiDebugScreenState extends State<TamagotchiDebugScreen> {
  String _log = 'Debug Log:\n';
  String? _accessToken;
  int? _reportId;

  void _logger(String message) {
    setState(() {
      _log = '${DateTime.now().toIso8601String()}: $message\n$_log';
    });
    print(message);
  }

  Future<void> _registerDevice() async {
    _logger('Registering device...');
    try {
      // Unique name to avoid conflicts if possible, or just reuse
      String deviceName = 'Tamagotchi-${DateTime.now().millisecondsSinceEpoch}';
      final token = await api.registerDevice({
        'first_name': 'Tamagotchi',
        'last_name': 'Device',
        'email': '$deviceName@example.com',
        'password': 'securepassword',
        'password_confirmation': 'securepassword',
        'device_name': deviceName
      });

      if (token != null) {
        setState(() {
          _accessToken = token;
        });
        // We need to set this token to the API to use authenticated requests
        // But normally the app uses the logged in user's token.
        // For this debug screen, we might need a way to use THIS token?
        // Actually, the app's `api` instance uses `_storage`.
        // We probably shouldn't overwrite the logged-in user's token.
        // But for "Tamagotchi" simulation, we represent the device.
        // Let's just create a temporary API instance or manually handle headers?
        // The `api.registerDevice` returns a token.
        // The mobile app itself is for the TEACHER/ADULT.
        // The Tamagotchi is a separate entity.
        // So this debug screen is simulating the EXTERNAL device.
        // We should probably NOT use the global `api` for the authenticated calls if we want to simulate the device.
        // But `api.sendNewMessage` uses `buildAuthenticatedRequest` which uses `getTokenAsync()`.

        // Use case: This screen simulates what the HARDWARE does.
        // So we should probably TEMPORARILY set the token in the storage?
        // Or better, let's just assume we want to test the API endpoints.

        _logger('Success! Token: ${token.substring(0, 10)}...');
      } else {
        _logger('Failed to register.');
      }
    } catch (e) {
      _logger('Error: $e');
    }
  }

  Future<void> _createReport() async {
    if (_accessToken == null) {
      _logger('No access token. Register first.');
      return;
    }

    // We need to support using a specific token for this request.
    // Since `api` is global and hardcoded to use storage, let's manually do it or
    // we can swap the token temporarily?
    // Swapping token is risky for the main app state.
    // Let's just create a helper method here to send request with specific token?
    // Or we can just modify `api.dart` to accept token override?
    // For now, let's try to "Hack" it:
    // This is a debug screen.

    // Actually, `sendNewReport` expects a `Report` object.
    // And it uses `buildAuthenticatedRequest`.

    // For simplicity of this task, I will just assume we can send requests.
    // But wait, the USER asked to "Integrate Tamagotchi API".
    // The MOBILE APP receives notifications. The MOBILE APP doesn't usually SEND these messages (the Tamagotchi does).
    // So this debug screen is purely for ME to verify the backend accepts them.
    // So I WILL use the token I just got.

    // To do this cleanly, I'll use a local helper to make the HTTP calls using the `_accessToken`.

    _logger('Creating report...');
    final url = Uri.parse('${api.baseAddress}/reports');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'description': 'Bullying incident reported by Debug Screen',
          'is_anonymous': 0
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _logger('Response: ${response.body}');
        final body = jsonDecode(response.body);

        int? reportId;
        if (body is Map) {
          if (body.containsKey('data') &&
              body['data'] is Map &&
              body['data'].containsKey('id')) {
            reportId = body['data']['id'];
          } else if (body.containsKey('id')) {
            reportId = body['id'];
          }
        }

        if (reportId != null) {
          setState(() {
            _reportId = reportId;
          });
          _logger('Report Created! ID: $reportId');
        } else {
          _logger('Could not parse Report ID from response.');
        }
      } else {
        _logger('Failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logger('Error: $e');
    }
  }

  Future<void> _sendTextMessage() async {
    if (_accessToken == null || _reportId == null) {
      _logger('Missing token or report ID.');
      return;
    }

    _logger('Sending text message...');
    final url = Uri.parse('${api.baseAddress}/reports/$_reportId/messages');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'content': 'Hello from Flutter Debug',
          'is_anonymous': 0,
          'type': 'text',
          'lat': 60.1699,
          'lon': 24.9384
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _logger('Text Message Sent!');
      } else {
        _logger('Failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logger('Error: $e');
    }
  }

  Future<void> _sendAudioMessage() async {
    if (_accessToken == null || _reportId == null) {
      _logger('Missing token or report ID.');
      return;
    }

    _logger('Sending audio message...');
    // Create a dummy file
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/test_audio.wav');
    await file
        .writeAsString('dummy audio content'); // Not real audio but file exists

    var request = http.MultipartRequest(
        'POST', Uri.parse('${api.baseAddress}/reports/$_reportId/messages'));
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    });

    request.fields.addAll({
      'type': 'audio',
      'is_anonymous': '0',
      'lat': '60.1699',
      'lon': '24.9384',
    });

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _logger('Audio Message Sent!');
      } else {
        _logger('Failed: ${response.statusCode}');
      }
    } catch (e) {
      _logger('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamagotchi Debug'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => RouteStateScope.of(context).go('/settings'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _registerDevice,
              child: const Text('1. Register Device'),
            ),
            ElevatedButton(
              onPressed: _createReport,
              child: const Text('2. Create Report'),
            ),
            ElevatedButton(
              onPressed: _sendTextMessage,
              child: const Text('3. Send Text Message'),
            ),
            ElevatedButton(
              onPressed: _sendAudioMessage,
              child: const Text('4. Send Audio Message'),
            ),
            const SizedBox(height: 20),
            const Text('Log:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_log),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
