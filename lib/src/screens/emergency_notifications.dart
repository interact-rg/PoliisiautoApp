/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/emergency_alert.dart';
import '../api.dart';
import '../routing.dart';
import 'report_details.dart';

class EmergencyNotificationsScreen extends StatefulWidget {
  const EmergencyNotificationsScreen({super.key});

  @override
  State<EmergencyNotificationsScreen> createState() =>
      _EmergencyNotificationsScreenState();
}

class _EmergencyNotificationsScreenState
    extends State<EmergencyNotificationsScreen> {
  List<EmergencyAlert> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlerts(forceRefresh: true);
  }

  Future<void> _fetchAlerts({bool forceRefresh = false}) async {
    if (forceRefresh) {
      setState(() => _isLoading = true);
    }
    try {
      final reports = await api.fetchReports(forceRefresh: forceRefresh);
      List<EmergencyAlert> loadedAlerts = [];

      for (var report in reports) {
        // For each report, check for audio messages
        // This is not efficient for many reports, but works for prototype
        String? audioUrl;
        bool isCritical = false;

        String? location = 'Unknown Location';

        try {
          if (report.id != null) {
            final messages =
                await api.fetchMessages(report.id!, forceRefresh: forceRefresh);

            // Try to find location from any message (prioritize newer)
            for (var msg in messages.reversed) {
              if (msg.lat != null && msg.lon != null) {
                location = '${msg.lat}, ${msg.lon}';
              }

              if (msg.type == 'audio' && msg.filePath != null) {
                audioUrl = msg.filePath;
                isCritical = true; // Assume audio reports are critical
              }
            }

            // If we found both, valid.
          }
        } catch (e) {
          // If 403 or other error, we just continue without messages/location
          print('Error fetching messages for report ${report.id}: $e');
        }

        loadedAlerts.add(EmergencyAlert(
          id: report.id ?? 0,
          studentName: report.reporterName ?? 'Unknown',
          timestamp: report.createdAt ?? DateTime.now(),
          location: location ?? 'Unknown Location',
          message: report.description,
          audioUrl: audioUrl,
          isCritical:
              isCritical || (report.description.toLowerCase().contains('sos')),
        ));
      }

      loadedAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (mounted) {
        setState(() {
          _alerts = loadedAlerts;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching alerts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hätäilmoitukset'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            RouteStateScope.of(context).go('/home');
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _fetchAlerts(forceRefresh: true),
              child: ListView.builder(
                itemCount: _alerts.length,
                itemBuilder: (context, index) {
                  final alert = _alerts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportDetailsScreen(
                            reportId: alert.id,
                          ),
                        ),
                      );
                    },
                    child: EmergencyAlertCard(alert: alert),
                  );
                },
              ),
            ),
    );
  }
}

class EmergencyAlertCard extends StatefulWidget {
  final EmergencyAlert alert;

  const EmergencyAlertCard({super.key, required this.alert});

  @override
  State<EmergencyAlertCard> createState() => _EmergencyAlertCardState();
}

class _EmergencyAlertCardState extends State<EmergencyAlertCard> {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (widget.alert.audioUrl == null) return;

    try {
      String url = widget.alert.audioUrl!;
      if (url.startsWith('http://')) {
        url = url.replaceFirst('http://', 'https://');
      }
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      print("Error playing audio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Virhe äänitiedoston toistossa')));
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: widget.alert.isCritical
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.alert.studentName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.alert.isCritical)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'HÄTÄ',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatTime(widget.alert.timestamp),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  widget.alert.location,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.alert.message,
              style: const TextStyle(fontSize: 16),
            ),
            if (widget.alert.audioUrl != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _playerState == PlayerState.playing
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_filled,
                      size: 32,
                      color: Colors.blue,
                    ),
                    onPressed: _playerState == PlayerState.playing
                        ? _stopAudio
                        : _playAudio,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _playerState == PlayerState.playing
                        ? 'Toistetaan...'
                        : 'Kuuntele tallenne',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    // Simple formatter, in real app use intl package
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min sitten';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} t sitten';
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year}';
    }
  }
}
