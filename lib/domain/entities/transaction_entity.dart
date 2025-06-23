enum TransactionType { sent, received }
enum TransactionStatus { completed, inProgress, failed }

class TransactionEntity {
  final String id;
  final String firstName;
  final String lastName;
  final double amount;
  final String currency;
  final String time;
  final String method;
  final TransactionStatus status;
  final TransactionType type;
  final DateTime date;
  final String initials;

  TransactionEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.amount,
    required this.currency,
    required this.time,
    required this.method,
    required this.status,
    required this.type,
    required this.date,
    required this.initials,
  });

  TransactionEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    double? amount,
    String? currency,
    String? time,
    String? method,
    TransactionStatus? status,
    TransactionType? type,
    DateTime? date,
    String? initials,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      time: time ?? this.time,
      method: method ?? this.method,
      status: status ?? this.status,
      type: type ?? this.type,
      date: date ?? this.date,
      initials: initials ?? this.initials,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TransactionEntity(id: $id, recipientName: $firstName $lastName, amount: $amount, currency: $currency, time: $time, method: $method, status: $status, type: $type, date: $date, initials: $initials)';
  }
}