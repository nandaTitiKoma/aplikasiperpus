class Loan {
  final int? id;
  final int facilityId;
  final String userId;
  final DateTime loanDate;
  final String startTime;
  final String endTime;
  final String? purpose;
  final String
  status; // 'pending' | 'approved' | 'rejected' | 'returned' | 'completed'

  Loan({
    this.id,
    required this.facilityId,
    required this.userId,
    required this.loanDate,
    required this.startTime,
    required this.endTime,
    this.purpose,
    this.status = 'pending',
  });

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
    id: json['id'] as int?,
    facilityId: json['facility_id'] as int,
    userId: json['user_id'] as String,
    loanDate: DateTime.parse(json['loan_date'] as String),
    startTime: json['start_time'] as String,
    endTime: json['end_time'] as String,
    purpose: json['purpose'] as String?,
    status: json['status'] as String,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'facility_id': facilityId,
    'user_id': userId,
    'loan_date': loanDate.toIso8601String().split('T').first,
    'start_time': startTime,
    'end_time': endTime,
    if (purpose != null) 'purpose': purpose,
    'status': status,
  };
}
