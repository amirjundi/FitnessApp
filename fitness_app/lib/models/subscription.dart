class Subscription {
  final int? id;
  final int playerId;
  final int planId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double? amountPaid;
  final String? paymentNotes;
  final DateTime createdAt;

  static const String statusActive = 'active';
  static const String statusExpired = 'expired';
  static const String statusCancelled = 'cancelled';

  Subscription({
    this.id,
    required this.playerId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    this.status = statusActive,
    this.amountPaid,
    this.paymentNotes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isActive {
    final now = DateTime.now();
    return status == statusActive && 
           now.isAfter(startDate) && 
           now.isBefore(endDate.add(const Duration(days: 1)));
  }

  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(endDate);
  }

  bool get isExpiringSoon {
    final now = DateTime.now();
    final daysUntilExpiry = endDate.difference(now).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= 7;
  }

  int get daysRemaining {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'player_id': playerId,
      'plan_id': planId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'amount_paid': amountPaid,
      'payment_notes': paymentNotes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] as int?,
      playerId: map['player_id'] as int,
      planId: map['plan_id'] as int,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      status: map['status'] as String? ?? statusActive,
      amountPaid: map['amount_paid'] != null 
          ? (map['amount_paid'] as num).toDouble() 
          : null,
      paymentNotes: map['payment_notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Subscription copyWith({
    int? id,
    int? playerId,
    int? planId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    double? amountPaid,
    String? paymentNotes,
    DateTime? createdAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      planId: planId ?? this.planId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      amountPaid: amountPaid ?? this.amountPaid,
      paymentNotes: paymentNotes ?? this.paymentNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
