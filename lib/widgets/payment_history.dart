import 'package:flutter/material.dart';
import 'package:payment_collect_02/models/payment.dart';
import 'package:payment_collect_02/services/payment_service.dart';
import 'package:payment_collect_02/services/file_service.dart';
import 'package:intl/intl.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({super.key});

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  final _paymentService = PaymentService();
  final _fileService = FileService();
  List<Payment> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final payments = await _paymentService.getPayments();
    setState(() {
      _payments = payments;
      _isLoading = false;
    });
  }

  Future<void> _exportToCsv() async {
    try {
      final hasPermission = await _fileService.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
        }
        return;
      }

      final csvData = await _paymentService.exportToCsv();
      final file = await _fileService.saveCsv(csvData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV saved to: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting CSV: $e')),
        );
      }
    }
  }

  Map<String, List<Payment>> _groupPaymentsByDate() {
    final grouped = <String, List<Payment>>{};
    for (final payment in _payments) {
      final date = DateFormat('yyyy-MM-dd').format(payment.timestamp);
      grouped.putIfAbsent(date, () => []).add(payment);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final groupedPayments = _groupPaymentsByDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportToCsv,
            tooltip: 'Export to CSV',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groupedPayments.length,
        itemBuilder: (context, index) {
          final date = groupedPayments.keys.elementAt(index);
          final payments = groupedPayments[date]!;
          final total = payments.fold<double>(
            0,
            (sum, payment) => sum + payment.amount,
          );

          return ExpansionTile(
            title: Text(
              DateFormat('MMMM d, yyyy').format(DateTime.parse(date)),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Total: ₹${total.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green),
            ),
            children: payments.map((payment) {
              return ListTile(
                title: Text('₹${payment.amount.toStringAsFixed(2)}'),
                subtitle: Text(
                  DateFormat('hh:mm a').format(payment.timestamp),
                ),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
