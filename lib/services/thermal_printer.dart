import 'package:flutter/material.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class ThermalService {

  /// =========================
  /// FORMAT LINE
  /// =========================
  String formatLine(String left, String right) {
    int totalWidth = 32;
    int space = totalWidth - (left.length + right.length);
    return left + (' ' * (space > 0 ? space : 1)) + right;
  }

  /// =========================
  /// GENERATE PREVIEW STRING
  /// =========================
  String generatePreview(Map<String, dynamic> transaction) {
    String receipt = '';

    receipt += '   Gilbert Store\n';
    receipt += '------------------------------\n';

    receipt +=
        'Date: ${DateFormat('MM/dd/yyyy').format(DateTime.parse(transaction['created_at']))}\n';
    receipt += 'Payment: ${_capitalize(transaction['payment_type'])}\n';

    receipt += '------------------------------\n';

    for (var item in transaction['products']) {
      String name = _capitalize(item['product_name'] ?? 'Item');
      String price = _safeDouble(item['price']).toStringAsFixed(2);
      String qty = _safeInt(item['quantity']).toString();

      receipt += '$name\n';
      receipt += formatLine('x$qty', 'PHP$price') + '\n';
    }

    receipt += '------------------------------\n';

    receipt += formatLine(
            'TOTAL',
            'PHP${_safeDouble(transaction['total_amount']).toStringAsFixed(2)}') +
        '\n';

    receipt += formatLine(
            'CASH',
            'PHP${_safeDouble(transaction['amount_received']).toStringAsFixed(2)}') +
        '\n';

    receipt += formatLine(
            'CHANGE',
            'PHP${_safeDouble(transaction['change_amount']).toStringAsFixed(2)}') +
        '\n';

    receipt += '\n   Thank you!\n';

    return receipt;
  }

  /// =========================
  /// SHOW PREVIEW DIALOG
  /// =========================
  void showPreview(BuildContext context, Map<String, dynamic> transaction) {
    final preview = generatePreview(transaction);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Receipt Preview'),
        content: SingleChildScrollView(
          child: Text(
            preview,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  /// =========================
  /// GENERATE ESC/POS BYTES
  /// =========================
  Future<List<int>> generateReceiptBytes(
      Map<String, dynamic> transaction) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    List<int> bytes = [];

    bytes += generator.text('Gilbert Convenience Store',
        styles: PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.text('Brgy. Balangasan',
        styles: PosStyles(align: PosAlign.center));

    bytes += generator.text('Pagadian City',
        styles: PosStyles(align: PosAlign.center));

    bytes += generator.hr();

    bytes += generator.text(
      'Date: ${DateFormat('MM/dd/yyyy').format(DateTime.parse(transaction['created_at']))}',
    );

    bytes += generator.text(
      'Payment: ${_capitalize(transaction['payment_type'])}',
    );

    bytes += generator.hr();

    for (var item in transaction['products']) {
      String name = _capitalize(item['product_name'] ?? 'Item');
      String price = _safeDouble(item['price']).toStringAsFixed(2);
      String qty = _safeInt(item['quantity']).toString();

      bytes += generator.text(name);
      bytes += generator.text(formatLine('x$qty', 'PHP$price'));
    }

    bytes += generator.hr();

    bytes += generator.text(
      formatLine('TOTAL',
          'PHP${_safeDouble(transaction['total_amount']).toStringAsFixed(2)}'),
      styles: PosStyles(bold: true),
    );

    bytes += generator.text(
      formatLine('CASH',
          'PHP${_safeDouble(transaction['amount_received']).toStringAsFixed(2)}'),
    );

    bytes += generator.text(
      formatLine('CHANGE',
          'PHP${_safeDouble(transaction['change_amount']).toStringAsFixed(2)}'),
    );

    bytes += generator.feed(2);

    bytes += generator.text('Thank you!',
        styles: PosStyles(align: PosAlign.center));

    bytes += generator.cut();

    return bytes;
  }

  /// =========================
  /// PRINT WITH AUTO FALLBACK
  /// =========================
  Future<void> printReceipt(
      BuildContext context, Map<String, dynamic> transaction) async {
    try {

    bool granted = await requestBluetoothPermission();

   if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable Bluetooth permission in settings')),
      );

      await openAppSettings();
      return;
    }


      final bytes = await generateReceiptBytes(transaction);

      bool isConnected = await PrintBluetoothThermal.connectionStatus;

      if (isConnected) {
        await PrintBluetoothThermal.writeBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printing...')),
        );
      } else {
        showPreview(context, transaction);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No printer connected. Showing preview.')),
        );
      }
    } catch (e) {
      debugPrint('Print error: $e');
    }
  }

  /// =========================
  /// HELPERS
  /// =========================
  double _safeDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  int _safeInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text
        .split(' ')
        .map((w) =>
            w.isNotEmpty
                ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
                : '')
        .join(' ');
  }



Future<bool> requestBluetoothPermission() async {
  final bluetooth = await Permission.bluetooth.request();
  final connect = await Permission.bluetoothConnect.request();
  final scan = await Permission.bluetoothScan.request();

  // location is optional, don't block printing because of it
  await Permission.location.request();

  return bluetooth.isGranted && connect.isGranted && scan.isGranted;
}

}