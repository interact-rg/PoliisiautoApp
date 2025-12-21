/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

// Sample request:
// "id": 3,
// "content": "This is a message to a report!",
// "author_id": 3,
// "report_id": 36,
// "is_anonymous": 0
// "created_at": "2022-11-30T19:54:12.000000Z",
// "updated_at": "2022-11-30T19:54:12.000000Z",

class Message {
  final int? id;
  final String content;
  final int? authorId;
  final int reportId;
  final bool isAnonymous;
  final DateTime? createdAt;
  final String? authorName;
  final String? type;
  final double? lat;
  final double? lon;
  final String? filePath;

  const Message({
    required this.content,
    required this.reportId,
    required this.isAnonymous,
    this.id,
    this.authorId,
    this.createdAt,
    this.authorName,
    this.type,
    this.lat,
    this.lon,
    this.filePath,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      authorId: json['author_id'],
      reportId: json['report_id'],
      isAnonymous: json['is_anonymous'] == 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      authorName: json['author_name'],
      type: json['type'],
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lon: json['lon'] != null ? double.tryParse(json['lon'].toString()) : null,
      filePath: json['file_path'],
    );
  }
  @override
  String toString() {
    return 'ReportMessage(id: $id, content: $content, isAnonymous: $isAnonymous, createdAt: $createdAt, reportId: $reportId, authorId: $authorId, authorName: $authorName, type: $type, lat: $lat, lon: $lon, filePath: $filePath)';
  }
}
