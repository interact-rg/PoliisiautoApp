/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

class EmergencyAlert {
  final int id;
  final String studentName;
  final DateTime timestamp;
  final String location;
  final String message;
  final String? audioUrl;
  final bool isCritical;

  EmergencyAlert({
    required this.id,
    required this.studentName,
    required this.timestamp,
    required this.location,
    required this.message,
    this.audioUrl,
    this.isCritical = true,
  });
}
