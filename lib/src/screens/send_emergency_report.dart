/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import '../common.dart';

class SendEmergencyReportScreen extends StatefulWidget {
  const SendEmergencyReportScreen({
    super.key,
  });

  @override
  State<SendEmergencyReportScreen> createState() =>
      _SendEmergencyReportScreenState();
}

class _SendEmergencyReportScreenState extends State<SendEmergencyReportScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(
                AppLocalizations.of(context)!.sendingEmergencyNotification)),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: Text(
                      AppLocalizations.of(context)!.emergencyIsSendAdult,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium),
                ),

                // 'Help card'
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    color: Colors.lightBlue[50],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.support_outlined,
                            color: Theme.of(context).primaryColor,
                            size: 40,
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            AppLocalizations.of(context)!
                                .disengageFromSituation,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            AppLocalizations.of(context)!.findAdult,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Buttons for sending more material
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        icon: const Icon(Icons.keyboard_voice_outlined),
                        onPressed: () => _onSendAudio(context),
                        label: Text(
                            AppLocalizations.of(context)!.sendVoiceMessage)),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        icon: const Icon(Icons.videocam),
                        onPressed: () => _onSendVideo(context),
                        label:
                            Text(AppLocalizations.of(context)!.sendVideoImage)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.stopSending),
                ),
              ],
            ),
          ),
        ),
      );

  void _onSendAudio(BuildContext context) async {}

  void _onSendVideo(BuildContext context) async {}
}
