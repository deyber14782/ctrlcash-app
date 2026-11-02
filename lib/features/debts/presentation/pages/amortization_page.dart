import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/amortization.dart';
import '../../domain/usecases/get_amortization.dart';

class AmortizationPage extends ConsumerStatefulWidget {
  final String debtId;
  final String debtName;
  const AmortizationPage({super.key, required this.debtId, required this.debtName});

  @override
  ConsumerState<AmortizationPage> createState() => _AmortizationPageState();
}

class _AmortizationPageState extends ConsumerState<AmortizationPage> {
  Amortization? data;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final usecase = sl<GetAmortization>();
      final result = await usecase(widget.debtId);
      setState(() {
        data = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.debtName),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: loading
            ? const Center(
                child: SizedBox(
                    width: 28, height: 28,
                    child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)))
            : error != null
                ? Center(child: Text(error!, style: const TextStyle(color: AppColors.error)))
                : _buildContent(fmt),
      ),
    );
  }

  Widget _buildContent(NumberFormat fmt) {
    final d = data!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Resumen destacado
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accent, AppColors.surfaceElevated],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _summaryRow('Cuota mensual', fmt.format(d.monthlyPayment), highlight: true),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: AppColors.textPrimary.withValues(alpha: 0.2), height: 1),
              ),
              _summaryRow('Total a pagar', fmt.format(d.totalPaid)),
              const SizedBox(height: 10),
              _summaryRow('Total en intereses', fmt.format(d.totalInterest)),
            ],
          ),
        ),
        const SizedBox(height: 28),

        Text('Tabla de amortización',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('Cuota por cuota: cuánto va a capital y a interés',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                color: AppColors.surfaceElevated,
                child: Row(
                  children: const [
                    _HeaderCell('#', flex: 1),
                    _HeaderCell('Cuota', flex: 3),
                    _HeaderCell('Capital', flex: 3),
                    _HeaderCell('Interés', flex: 3),
                    _HeaderCell('Saldo', flex: 3),
                  ],
                ),
              ),
              ...d.schedule.map((row) => Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
                ),
                child: Row(
                  children: [
                    _DataCell('${row.number}', flex: 1),
                    _DataCell(_short(row.payment), flex: 3),
                    _DataCell(_short(row.principal), flex: 3),
                    _DataCell(_short(row.interest), flex: 3, color: AppColors.error),
                    _DataCell(_short(row.balance), flex: 3),
                  ],
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _short(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  Widget _summaryRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.8), fontSize: 14)),
        Text(value,
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: highlight ? 22 : 15,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.normal)),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  const _HeaderCell(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final int flex;
  final Color? color;
  const _DataCell(this.text, {required this.flex, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text,
          style: TextStyle(color: color ?? AppColors.textPrimary, fontSize: 13)),
    );
  }
}