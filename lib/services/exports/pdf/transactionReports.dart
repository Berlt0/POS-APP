import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

pw.Widget _cell(String text, pw.Font font, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        font: font,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}


Future<pw.Font> _getFont() async {
  final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');

  return pw.Font.ttf(
    fontData.buffer.asByteData(
      fontData.offsetInBytes,
      fontData.lengthInBytes,
    ),
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


Future<File> exportTransactionPDF({
  required List<Map<String, dynamic>> transactions,
  required DateTimeRange? dateRange,
  required String filter,
}) async {
  final pdf = pw.Document();
  final font = await _getFont();

  DateTime now = DateTime.now();
  DateTime start;
  DateTime end;

  if (filter == 'Today') {
    start = DateTime(now.year, now.month, now.day);
    end = start;
  } else if (filter == 'Weekly') {
    start = now.subtract(const Duration(days: 7));
    end = now;
  } else if (filter == 'Custom' && dateRange != null) {
    start = dateRange.start;
    end = dateRange.end;
  } else {
    start = now;
    end = now;
  }

  final periodText =
      '${DateFormat('yyyy-MM-dd').format(start)} - ${DateFormat('yyyy-MM-dd').format(end)}';

  
  Map<int, Map<String, dynamic>> grouped = {};

  for (var t in transactions) {
    final id = t['transaction_id'];

    if (grouped.containsKey(id)) {
      grouped[id]!['products'].add({
        'product_name': t['product_name'],
        'quantity': t['quantity'],
        'price': t['price'],
      });
    } else {
      grouped[id] = {
        'id': id,
        'created_at': t['created_at'],
        'processed_by': t['username'],
        'payment_type': t['payment_type'],
        'action': t['action'],
        'products': [],
      };
    }
  }

  List<Map<String, dynamic>> groupedList = grouped.values.toList();


  if (groupedList.length > 1000) {
    groupedList = groupedList.take(1000).toList();
  }


  List<pw.Widget> buildTables() {
    const int chunkSize = 20;

    List<pw.Widget> widgets = [];

    for (int i = 0; i < groupedList.length; i += chunkSize) {
      final chunk = groupedList.skip(i).take(chunkSize).toList();

      widgets.add(
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
          columnWidths: const {
            0: pw.FlexColumnWidth(1.5),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(2),
            4: pw.FlexColumnWidth(2),
          },
          children: [
            // HEADER
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _cell('ID', font, bold: true),
                _cell('Processed By', font, bold: true),
                _cell('Date', font, bold: true),
                _cell('Action', font, bold: true),
                _cell('Payment', font, bold: true),
              ],
            ),

            // DATA
            ...chunk.map((t) {
              final date = t['created_at'] != null
                  ? DateFormat('yyyy-MM-dd')
                      .format(DateTime.parse(t['created_at'].toString()))
                  : 'N/A';

              return pw.TableRow(
                children: [
                  _cell('${t['id']}', font),
                  _cell(capitalizeEachWord(t['processed_by']), font),
                  _cell(date, font),
                  _cell(t['action']?.toString() ?? 'N/A', font),
                  _cell(capitalizeEachWord(t['payment_type']), font),
                ],
              );
            }),
          ],
        ),
      );

      widgets.add(pw.SizedBox(height: 20));
    }

    return widgets;
  }


  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
      ),
      build: (context) => [
        pw.Text(
          'Transaction Records',
          style: pw.TextStyle(
            font: font,
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 6),

        pw.Text(
          'Period: $periodText',
          style: pw.TextStyle(font: font, fontSize: 12),
        ),

        pw.SizedBox(height: 20),

        if (groupedList.isEmpty)
          pw.Text(
            'No transactions available',
            style: pw.TextStyle(font: font),
          )
        else
          ...buildTables(),
      ],
    ),
  );

  final bytes = await pdf.save();


  final dir = Directory('/storage/emulated/0/Download');

  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final file = File(
    '${dir.path}/Transaction_Report_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now())}.pdf',
  );

  await file.writeAsBytes(bytes, flush: true);

  return file;
}