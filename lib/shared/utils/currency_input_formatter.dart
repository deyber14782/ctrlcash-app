import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _fmt = NumberFormat.decimalPattern('es_CO');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Quita todo lo que no sea dígito
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final number = int.parse(digits);
    final formatted = _fmt.format(number); // 150000 -> "150.000"
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  // Helper para extraer el número limpio del texto formateado
  static double parse(String formatted) {
    final digits = formatted.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? 0 : double.parse(digits);
  }
}