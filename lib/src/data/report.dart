// Sample request:
// "id": 1,
// "description": "Joku (ehkä Jaska) kiusaa mua taas!",
// "report_case_id": 1,
// "reporter_id": 1,
// "assignee_id": null,
// "bully_id": null,
// "bullied_id": null,
// "is_anonymous": 1,
// "type": 1,
// "opened_at": "2022-10-09T13:41:31.000000Z",
// "closed_at": null,
// "created_at": "2022-10-09T12:35:58.000000Z",
// "updated_at": "2022-10-09T20:20:58.000000Z"

enum ReportStatus {
  pending('pending'),
  opened('opened'),
  closed('closed');

  const ReportStatus(this.str);
  final String str;
}

class Report {
  final int id;
  final String description;
  final int? reportCaseId;
  final int? reporterId;
  final int? assigneeId;
  final int? bullyId;
  final int? bulliedId;
  final bool isAnonymous;
  final DateTime? openedAt;
  final DateTime? closedAt;

  const Report({
    required this.id,
    required this.description,
    required this.isAnonymous,
    this.openedAt,
    this.closedAt,
    this.reportCaseId,
    this.reporterId,
    this.assigneeId,
    this.bullyId,
    this.bulliedId,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      description: json['description'],
      isAnonymous: json['is_anonymous'] == 1,
      openedAt: DateTime.tryParse(json['opened_at'] ?? ''),
      closedAt: DateTime.tryParse(json['closed_at'] ?? ''),
      reportCaseId: json['report_case_id'],
      reporterId: json['reporter_id'],
      assigneeId: json['assignee_id'],
      bullyId: json['bully_id'],
      bulliedId: json['bullied_id'],
    );
  }

  ReportStatus get status {
    if (closedAt != null) {
      return ReportStatus.closed;
    } else if (openedAt != null) {
      return ReportStatus.opened;
    } else {
      return ReportStatus.pending;
    }
  }
}
