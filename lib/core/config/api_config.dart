class ApiConfig {
  static const String baseUrl = 'https://integrate.api.nvidia.com/v1';
  static const String chatEndpoint = '/chat/completions';
  static const String model = 'stepfun-ai/step-3.5-flash';
  
  static String get fullUrl => '$baseUrl$chatEndpoint';
}
