// Convierte errores técnicos (Firebase, red, etc.) en mensajes claros en español
String humanizeError(Object error) {
  final raw = error.toString().toLowerCase();

  // --- Errores de autenticación de Firebase ---
  if (raw.contains('wrong-password') || raw.contains('invalid-credential')) {
    return 'Correo o contraseña incorrectos';
  }
  if (raw.contains('user-not-found')) {
    return 'No existe una cuenta con ese correo';
  }
  if (raw.contains('email-already-in-use')) {
    return 'Ya existe una cuenta con ese correo';
  }
  if (raw.contains('invalid-email')) {
    return 'El correo no tiene un formato válido';
  }
  if (raw.contains('weak-password')) {
    return 'La contraseña es muy débil (mínimo 6 caracteres)';
  }
  if (raw.contains('too-many-requests')) {
    return 'Demasiados intentos. Espera un momento e inténtalo de nuevo';
  }
  if (raw.contains('requires-recent-login')) {
    return 'Por seguridad, vuelve a iniciar sesión para hacer este cambio';
  }
  if (raw.contains('user-disabled')) {
    return 'Esta cuenta ha sido deshabilitada';
  }

  // --- Errores de red / conexión ---
  if (raw.contains('socketexception') ||
      raw.contains('network') ||
      raw.contains('connection') ||
      raw.contains('failed host lookup')) {
    return 'Sin conexión. Revisa tu internet e inténtalo de nuevo';
  }
  if (raw.contains('timeout')) {
    return 'La conexión tardó demasiado. Inténtalo de nuevo';
  }

  // --- Errores del backend (HTTP) ---
  if (raw.contains('401') || raw.contains('unauthorized')) {
    return 'Tu sesión expiró. Vuelve a iniciar sesión';
  }
  if (raw.contains('403') || raw.contains('forbidden')) {
    return 'No tienes permiso para hacer esto';
  }
  if (raw.contains('404')) {
    return 'No se encontró lo que buscabas';
  }
  if (raw.contains('500') || raw.contains('internal server')) {
    return 'Hubo un problema en el servidor. Inténtalo más tarde';
  }

  // --- Mensaje genérico si no reconocemos el error ---
  return 'Algo salió mal. Inténtalo de nuevo';
}