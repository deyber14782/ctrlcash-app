import 'package:flutter/foundation.dart' show kDebugMode;

class EnvConfig {
  static String get apiBaseUrl {
    // En desarrollo (flutter run) usa el backend local
    if (kDebugMode) {
      return 'http://localhost:3000/api/v1';
    }
    // En producción (builds de release) usa el backend desplegado
    return 'https://ctrl-cash.onrender.com/api/v1';
  }
}