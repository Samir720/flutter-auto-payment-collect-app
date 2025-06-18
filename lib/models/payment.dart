class Payment {
  final double amount;
  final DateTime timestamp;

  Payment({
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      amount: json['amount'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
