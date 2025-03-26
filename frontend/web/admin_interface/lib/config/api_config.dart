import 'package:flutter/foundation.dart';

class ApiConfig {
  static final String baseUrl = kDebugMode
      ? 'http://localhost:3000/api/v1'
      : 'https://api.ecar.tn/api/v1';
} 