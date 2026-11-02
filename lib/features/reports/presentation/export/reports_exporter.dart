import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' as xl;
import '../../domain/entities/reports.dart';

final _fmt = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

class ReportsExporter {
  // ---------- PDF ----------
  static Future<void> exportPdf(Reports r, String periodLabel) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('CtrlCash — Informe financiero',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text('Periodo: $periodLabel',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          pw.SizedBox(height: 20),

          _pdfSection('Balance del periodo'),
          _pdfRow('Ingresos', _fmt.format(r.balance.income)),
          _pdfRow('Gastos', _fmt.format(r.balance.expense)),
          _pdfRow('Queda', _fmt.format(r.balance.remaining)),
          pw.SizedBox(height: 16),

          _pdfSection('Tasa de ahorro'),
          _pdfRow('Porcentaje', '${r.savingsRate.rate.toStringAsFixed(0)}%'),
          _pdfRow('Valoración', r.savingsRate.message),
          pw.SizedBox(height: 16),

          _pdfSection('Resumen de gastos'),
          _pdfRow('Total gastado', _fmt.format(r.summary.total)),
          _pdfRow('Número de gastos', '${r.summary.count}'),
          _pdfRow('Gasto promedio', _fmt.format(r.summary.average)),
          _pdfRow('Mayor gasto', _fmt.format(r.summary.highest)),
          pw.SizedBox(height: 16),

          _pdfSection('Distribución por prioridad'),
          _pdfRow('Prioridad alta', '${_fmt.format(r.byPriority.alta)} (${r.byPriority.altaPct.toStringAsFixed(0)}%)'),
          _pdfRow('Prioridad baja', '${_fmt.format(r.byPriority.baja)} (${r.byPriority.bajaPct.toStringAsFixed(0)}%)'),
          pw.SizedBox(height: 16),

          _pdfSection('Mayores gastos'),
          ...r.topExpenses.map((e) => _pdfRow(e.name, _fmt.format(e.amount))),
          pw.SizedBox(height: 16),

          _pdfSection('Gastos hormiga (total: ${_fmt.format(r.antExpenses.total)})'),
          ...r.antExpenses.items.map((e) =>
              _pdfRow('${e.name} (${e.occurrences}x)', _fmt.format(e.total))),
          pw.SizedBox(height: 16),

          _pdfSection('Gastos vampiro (total: ${_fmt.format(r.vampireExpenses.total)})'),
          ...r.vampireExpenses.items.map((e) =>
              _pdfRow('${e.name} (${e.occurrences}x)', _fmt.format(e.total))),
        ],
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: 'informe_ctrlcash.pdf');
  }

  static pw.Widget _pdfSection(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(title,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(child: pw.Text(label, style: const pw.TextStyle(fontSize: 11))),
          pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  // ---------- EXCEL ----------
  static Future<void> exportExcel(Reports r, String periodLabel) async {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Informe'];
    excel.delete('Sheet1');

    void row(List<dynamic> cells) {
      sheet.appendRow(cells.map((c) => xl.TextCellValue(c.toString())).toList());
    }

    row(['CtrlCash — Informe financiero']);
    row(['Periodo', periodLabel]);
    row([]);

    row(['BALANCE']);
    row(['Ingresos', r.balance.income]);
    row(['Gastos', r.balance.expense]);
    row(['Queda', r.balance.remaining]);
    row([]);

    row(['TASA DE AHORRO']);
    row(['Porcentaje', '${r.savingsRate.rate}%']);
    row(['Valoración', r.savingsRate.message]);
    row([]);

    row(['RESUMEN']);
    row(['Total gastado', r.summary.total]);
    row(['Número de gastos', r.summary.count]);
    row(['Gasto promedio', r.summary.average]);
    row(['Mayor gasto', r.summary.highest]);
    row([]);

    row(['PRIORIDAD']);
    row(['Alta', r.byPriority.alta, '${r.byPriority.altaPct}%']);
    row(['Baja', r.byPriority.baja, '${r.byPriority.bajaPct}%']);
    row([]);

    row(['MAYORES GASTOS']);
    for (final e in r.topExpenses) {
      row([e.name, e.amount]);
    }
    row([]);

    row(['GASTOS HORMIGA', 'Total', r.antExpenses.total]);
    row(['Nombre', 'Veces', 'Total']);
    for (final e in r.antExpenses.items) {
      row([e.name, e.occurrences, e.total]);
    }
    row([]);

    row(['GASTOS VAMPIRO', 'Total', r.vampireExpenses.total]);
    row(['Nombre', 'Veces', 'Total']);
    for (final e in r.vampireExpenses.items) {
      row([e.name, e.occurrences, e.total]);
    }

    final bytes = excel.encode();
    if (bytes != null) {
      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: 'informe_ctrlcash.xlsx',
      );
    }
  }
}