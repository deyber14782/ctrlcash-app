import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/usecases/get_analysis.dart';
import '../providers/reports_notifier.dart';


class ReportDetailPage extends ConsumerStatefulWidget {
  final String type;        // ant | vampire | balance | savings | priority
  final String title;
  final String subtitle;
  final Widget dataSection; // el contenido cuantitativo (desglose) que le pasamos

  const ReportDetailPage({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.dataSection,
  });

  @override
  ConsumerState<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends ConsumerState<ReportDetailPage> {
  String? analysis;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    setState(() { loading = true; error = null; });
    try {
      final state = ref.read(reportsNotifierProvider);
      final usecase = sl<GetAnalysis>();

      final fmt = DateFormatHelper();
      final result = await usecase(
        type: widget.type,
        period: state.period == 'custom' ? null : state.period,
        from: state.period == 'custom' && state.from != null
            ? fmt.format(state.from!) : null,
        to: state.period == 'custom' && state.to != null
            ? fmt.format(state.to!) : null,
      );
      setState(() { analysis = result; loading = false; });
    } catch (e) {
      setState(() { error = 'No se pudo generar el análisis'; loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(widget.subtitle,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),

            // Datos cuantitativos (desglose)
            widget.dataSection,
            const SizedBox(height: 28),

            // Análisis de la IA
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                Text('Análisis inteligente',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 14),
            _buildAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysis() {
    if (loading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)),
            SizedBox(width: 14),
            Expanded(child: Text('Analizando tus datos...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          ],
        ),
      );
    }
    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _loadAnalysis,
              child: const Text('Reintentar',
                  style: TextStyle(color: AppColors.accent, fontSize: 13)),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(analysis ?? '',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6)),
    );
  }
}

// Helper de formato de fecha (para no chocar con imports)
class DateFormatHelper {
  String format(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}