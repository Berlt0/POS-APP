import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

Future<pw.Font> _getFont() async {
  final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');

  if (fontData.lengthInBytes < 1000) {
    throw StateError(
      'Invalid font asset: assets/fonts/NotoSans-Regular.ttf '
      '(${fontData.lengthInBytes} bytes). Check the file path and pubspec.yaml.',
    );
  }

  return pw.Font.ttf(
    fontData.buffer.asByteData(
      fontData.offsetInBytes,
      fontData.lengthInBytes,
    ),
  );
}

String _money(dynamic value) {
  final numValue = value is num ? value.toDouble() : double.tryParse('$value') ?? 0.0;
  return '₱${numValue.toStringAsFixed(2)}';
}

pw.Widget _buildWatermark(pw.Context context) {
  return pw.Center(
    child: pw.Opacity(
      opacity: 0.08,
      child: pw.Transform.rotate(
        angle: -0.5,
        child: pw.Text(
          'CONFIDENTIAL',
          style: pw.TextStyle(
            fontSize: 60,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.red400,
            letterSpacing: 6,
          ),
        ),
      ),
    ),
  );
}

Future<File> exportReportPDF({
  required Map<String, dynamic>? reportCard,
  required List<Map<String, dynamic>> salesTrend,
  required List<Map<String, dynamic>> rcogsp,
  required List<Map<String, dynamic>> topProducts,
  required DateTimeRange? dateRange,
  required String filter,
}) async {
  final pdf = pw.Document();
  final font = await _getFont();        

  final periodText = dateRange == null
      ? 'All Time'
      : '${DateFormat('yyyy-MM-dd').format(dateRange.start)} - ${DateFormat('yyyy-MM-dd').format(dateRange.end)}';

  final grossMargin = ((reportCard?['margin'] ?? 0) as num).toDouble();

  final safeTopProducts = List<Map<String, dynamic>>.from(topProducts);

  pdf.addPage(
  pw.MultiPage(
    pageTheme: pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      buildBackground: (context) => _buildWatermark(context),
    ),
    build: (context) => [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Sales Report',
            style: pw.TextStyle(
              font: font,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Period: $periodText',
              style: pw.TextStyle(font: font, fontSize: 12)),        
          pw.SizedBox(height: 25),

          pw.Text(
            'Summary',
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),

          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.2),
              1: pw.FlexColumnWidth(3),
            },
            children: [
              _buildRow('Total Sales Transactions', '${reportCard?['totalSales'] ?? 0}', font),
              _buildRow('Revenue', _money(reportCard?['revenue']), font),
              _buildRow('Profit', _money(reportCard?['profit']), font),
              _buildRow('Gross Margin', '${grossMargin.toStringAsFixed(2)}%', font),
            ],
          ),

          pw.SizedBox(height: 35),

          pw.Text(
            'Top Selling Products',
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),

          if (safeTopProducts.isEmpty)
            pw.Text(
              'No top products available',
              style: pw.TextStyle(font: font, fontSize: 12),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
              columnWidths: const {
                0: pw.FlexColumnWidth(5),
                1: pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        'Product Name',
                        style: pw.TextStyle(
                          font: font,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Text(
                        'Quantity',
                        style: pw.TextStyle(
                          font: font,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...safeTopProducts.map((p) {
                  final rawName = p['product_name']?.toString() ?? 'Unknown Product';
                  final name = capitalizeEachWord(rawName);
                  final qty = p['total_sold']?.toString() ??
                      p['quantity']?.toString() ??
                      '0';

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(name, style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          qty,
                          style: pw.TextStyle(font: font),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),

          pw.SizedBox(height: 30),
        ],
      ),
    ],
  ),
);

  final bytes = await pdf.save();

  final downloadDir = Directory('/storage/emulated/0/Download');
  if (!await downloadDir.exists()) {
    await downloadDir.create(recursive: true);
  }

  final fileName = 'Sales_Report_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now())}.pdf';
  final file = File('${downloadDir.path}/$fileName');

  await file.writeAsBytes(bytes, flush: true);
  return file;
}

// Updated helper
pw.TableRow _buildRow(String label, String value, pw.Font font) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(10),
        child: pw.Text(label, style: pw.TextStyle(font: font)),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(10),
        child: pw.Text(value, style: pw.TextStyle(font: font)),
      ),
    ],
  );
}

String capitalizeEachWord(String text) {
  return text
      .split(' ')
      .map((word) => word.isNotEmpty
          ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
          : '')
      .join(' ');
}