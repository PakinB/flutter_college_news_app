const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');

String get apiBaseUrl {
  if (_configuredApiBaseUrl.isNotEmpty) {
    return _configuredApiBaseUrl;
  }

  final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
  return 'http://$host/flutter_college_news/php_api';
}
