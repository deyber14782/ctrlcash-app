import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/env_config.dart';

class ApiClient {
  final Dio dio;

  ApiClient() : dio = Dio(BaseOptions(baseUrl: EnvConfig.apiBaseUrl)) {
    // Adjunta el ID token de Firebase a cada petición automáticamente
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }
}