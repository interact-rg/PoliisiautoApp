/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../auth.dart';
import '../api.dart';
import '../data.dart';
import '../screens/new_message.dart';
import '../widgets/empty_list.dart';

class ReportDetailsScreen extends StatefulWidget {
  final int reportId;

  const ReportDetailsScreen({
    super.key,
    required this.reportId,
  });

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  late Future<Report> _futureReport;
  late Future<List<Message>> _futureMessages;

  @override
  void initState() {
    super.initState();
    _futureReport = api.fetchReport(widget.reportId);
    _refreshMessages();
  }

  void _refreshMessages() {
    setState(() {
      _futureMessages = api.fetchMessages(widget.reportId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ilmoituksen tiedot'), actions: [
        // TODO: Hide if the report is not created by the current user!
        IconButton(
          onPressed: () async {
            bool sure = await _confirmDelete(
                    context, 'Haluatko varmasti poistaa ilmoituksen?') ??
                false;
            if (sure) {
              if (await _deleteReport() && mounted) {
                Navigator.pop(context, 'report_deleted');
              }
            }
          },
          icon: const Icon(Icons.delete_outline),
        ),
      ]),
      body: FutureBuilder<Report>(
          future: _futureReport,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: [
                  const SizedBox(height: 6),
                  _buildField('Ilmoituksen kuvaus',
                      content: snapshot.data!.description),
                  const Divider(color: Color.fromARGB(255, 193, 193, 193)),
                  _buildField('Ilmoittaja',
                      content: snapshot.data!.reporterName ?? '(nimetön)'),
                  const Divider(color: Color.fromARGB(255, 193, 193, 193)),
                  _buildField('Kiusaaja',
                      content: snapshot.data!.bullyName ?? '(ei ilmoitettu)'),
                  const Divider(color: Color.fromARGB(255, 193, 193, 193)),
                  _buildField('Kiusattu',
                      content: snapshot.data!.bulliedName ?? '(ei ilmoitettu)'),
                  const Divider(color: Color.fromARGB(255, 193, 193, 193)),
                  _buildField('Viestit',
                      child: _buildMessagesWidget(_futureMessages)),
                  //const Divider(color: Color.fromARGB(255, 193, 193, 193)),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openNewMessageScreen(
                            context, snapshot.data!.isAnonymous),
                        icon: const Icon(Icons.message_outlined),
                        label: const Text('Lähetä viesti'),
                      ),
                    ),
                  )
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  Future<bool?> _confirmDelete(context, String message) => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Oletko varma?'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Peru'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Kyllä',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

  Future<bool> _deleteReport() async {
    return await api.deleteReport(widget.reportId);
  }

  Future<bool> _deleteMessage(int messageId) async {
    return await api.deleteMessage(messageId);
  }

  void _openNewMessageScreen(BuildContext context, bool isAnonymous) async {
    return Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => NewMessageScreen(
          reportId: widget.reportId,
          isTeacher: isTeacher(context),
          reportIsAnonymous: isAnonymous),
    ))
        .then((result) {
      if (result != null) _refreshMessages();
    });
  }

  /////////////////////////////////////////////////////////////////////////////
  /// Builders
  /////////////////////////////////////////////////////////////////////////////

  Widget _buildField(String label, {String? content, Widget? child}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        child ?? Text(content ?? '')
      ]));

  Widget _buildMessagesWidget(Future<List<Message>> futureMessageList) =>
      FutureBuilder<List<Message>>(
          future: futureMessageList,
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!.isEmpty
                  ? const SizedBox(
                      width: double.infinity,
                      child: EmptyListWidget('Ei viestejä', showIcon: false))
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Column(
                        children: [
                          ...snapshot.data!
                              .map((msg) => _buildMessageBubbleWidget(msg))
                        ],
                      ),
                    );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const Center(child: CircularProgressIndicator());
          }));

  Widget _buildMessageBubbleWidget(Message message) {
    return MessageBubble(
      message: message,
      currentUserId: getAuth(context).user!.id,
      onDelete: () async {
        if (await _deleteMessage(message.id!) && mounted) {
          _refreshMessages();
        }
      },
      confirmDelete: (msg) => _confirmDelete(context, msg),
    );
  }
}

class MessageBubble extends StatefulWidget {
  final Message message;
  final int currentUserId;
  final VoidCallback onDelete;
  final Future<bool?> Function(String) confirmDelete;

  const MessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.onDelete,
    required this.confirmDelete,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  bool _isAudio = false;

  @override
  void initState() {
    super.initState();
    _isAudio =
        widget.message.type == 'audio' && widget.message.filePath != null;
    if (_isAudio) {
      _audioPlayer = AudioPlayer();
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _playerState = state;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    if (_isAudio) {
      _audioPlayer.dispose();
    }
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (widget.message.filePath == null) return;
    try {
      await _audioPlayer.play(UrlSource(widget.message.filePath!));
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
    bool byCurrentUser = widget.message.authorId == widget.currentUserId;

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onLongPress: () async {
          if (!byCurrentUser) return;

          bool sure = await widget
                  .confirmDelete('Haluatko varmasti poistaa viestin?') ??
              false;
          if (sure) {
            widget.onDelete();
          }
        },
        child: Card(
          color: byCurrentUser ? Colors.green.shade100 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: byCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  byCurrentUser
                      ? 'Sinä'
                      : (widget.message.authorName ?? 'Nimetön'),
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (_isAudio) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _playerState == PlayerState.playing
                              ? Icons.stop_circle_outlined
                              : Icons.play_circle_filled,
                          size: 32,
                          color: _playerState == PlayerState.playing
                              ? Colors.red
                              : Colors.blue,
                        ),
                        onPressed: _playerState == PlayerState.playing
                            ? _stopAudio
                            : _playAudio,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _playerState == PlayerState.playing
                            ? 'Toistetaan...'
                            : 'Kuuntele viesti',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ] else
                  Text(
                    widget.message.content,
                    textAlign: TextAlign.left,
                  ),
                if (widget.message.lat != null &&
                    widget.message.lon != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.message.lat}, ${widget.message.lon}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
