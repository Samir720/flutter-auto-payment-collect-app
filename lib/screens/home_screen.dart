import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:payment_collect_02/models/payment.dart';
import 'package:payment_collect_02/services/payment_service.dart';
import 'package:payment_collect_02/widgets/payment_history.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _amountController = TextEditingController();
  final _paymentService = PaymentService();
  bool _showQrCode = false;
  String? _errorText;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _generateQrCode() {
    final amount = _amountController.text;
    if (amount.isEmpty) {
      setState(() => _errorText = 'Please enter an amount');
      return;
    }

    final amountNum = double.tryParse(amount);
    if (amountNum == null || amountNum <= 0) {
      setState(() => _errorText = 'Please enter a valid amount');
      return;
    }

    setState(() {
      _errorText = null;
      _showQrCode = true;
    });
  }

  void _handlePaymentSuccess() async {
    final amount = double.parse(_amountController.text);
    final payment = Payment(
      amount: amount,
      timestamp: DateTime.now(),
    );

    await _paymentService.savePayment(payment);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded successfully!')),
      );
      setState(() {
        _amountController.clear();
        _showQrCode = false;
      });
    }
  }

  void _handleCancel() {
    setState(() {
      _amountController.clear();
      _showQrCode = false;
      _errorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Payment Collector'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentHistory(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Enter Amount (₹)',
                errorText: _errorText,
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateQrCode,
              child: const Text('Generate QR Code'),
            ),
            if (_showQrCode) ...[
              const SizedBox(height: 24),
              Center(
                child: QrImageView(
                  data:
                      'upi://pay?pa=mansurishahid8109@oksbi&pn=Shahid%20Mansuri&am=${_amountController.text}&cu=INR',
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Shahid Mansuri',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handlePaymentSuccess,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Payment Success'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleCancel,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
