const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
const String _localApiBaseUrl =
    'http://localhost/flutter_college_news_app/php_api';

String get apiBaseUrl {
  final String override = _apiBaseUrlOverride.trim();
  if (override.isNotEmpty) return _withoutTrailingSlash(override);

  final Uri currentUrl = Uri.base;
  if (currentUrl.scheme == 'http' || currentUrl.scheme == 'https') {
    final String host = currentUrl.host.toLowerCase();
    final bool isLocalHost =
        host == 'localhost' || host == '127.0.0.1' || host == '::1';

    if (!isLocalHost) {
      return _withoutTrailingSlash(currentUrl.resolve('php_api').toString());
    }
  }

  return _localApiBaseUrl;
}

String apiUrl(String path) {
  final String normalizedPath = path.replaceFirst(RegExp(r'^/+'), '');
  return '$apiBaseUrl/$normalizedPath';
}

String _withoutTrailingSlash(String value) {
  return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}
