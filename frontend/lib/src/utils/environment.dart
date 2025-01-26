// lib/src/utils/environment.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get openAIApiKey {
    final key = dotenv.env['OPENAI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('OPENAI_API_KEY is not set in the .env file');
    }
    return key;
  }

  // Add more environment variables as needed
}
