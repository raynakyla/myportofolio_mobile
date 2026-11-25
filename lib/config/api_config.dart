/// Backend origin configured at compile time with --dart-define=API_BASE_URL=...
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static Uri get projectsUri => Uri.parse(baseUrl).resolve('/api/v1/projects/');
}
