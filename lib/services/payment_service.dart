import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:payment_collect_02/models/payment.dart';

class PaymentService {
  static const String _storageKey = 'payments';

  Future<void> savePayment(Payment payment) async {
    final prefs = await SharedPreferences.getInstance();
    final payments = await getPayments();
    payments.add(payment);

    final jsonList = payments.map((p) => p.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<List<Payment>> getPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Payment.fromJson(json)).toList();
  }

  Future<String> exportToCsv() async {
    final payments = await getPayments();
    final csvData = StringBuffer();

    // Add header
    csvData.writeln('Date,Amount,Time');

    // Add data rows
    for (final payment in payments) {
      final date = payment.timestamp.toLocal().toString().split(' ')[0];
      final time =
          payment.timestamp.toLocal().toString().split(' ')[1].substring(0, 8);
      csvData.writeln('$date,${payment.amount},$time');
    }

    return csvData.toString();
  }
}
