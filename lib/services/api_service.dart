import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/announcement.dart';
import '../models/faculty.dart';

const apiBaseUrl = 'http://localhost/flutter_college_news_app/php_api';

class ApiService {
  const ApiService();

  Future<List<Announcement>> fetchAnnouncements({
    int? visibleFacultyId,
    String? visibleRole,
    String? status,
  }) async {
    final Map<String, String> query = <String, String>{};
    if (status != null) {
      query['status'] = status;
    }
    if (visibleFacultyId != null) {
      query['visible_faculty_id'] = '$visibleFacultyId';
    }
    if (visibleRole != null && visibleRole.trim().isNotEmpty) {
      query['visible_role'] = visibleRole.trim().toLowerCase();
    }

    final List<dynamic> rows = await _getList('announcements/index.php', query);
    return rows
        .whereType<Map<String, dynamic>>()
        .map(Announcement.fromJson)
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final List<dynamic> rows = await _getList('users/get_users.php');
    return rows.whereType<Map<String, dynamic>>().toList();
  }

  Future<List<Faculty>> fetchFaculties() async {
    final List<dynamic> rows = await _getList('faculties/index.php');
    return rows
        .whereType<Map<String, dynamic>>()
        .map(Faculty.fromJson)
        .toList();
  }

  Future<int> createAnnouncement(Map<String, dynamic> payload) async {
    final Map<String, dynamic> body = await _sendJson(
      'POST',
      'announcements/index.php',
      payload,
    );
    return int.tryParse('${body['id'] ?? 0}') ?? 0;
  }

  Future<void> updateAnnouncement(int id, Map<String, dynamic> payload) async {
    await _sendJson('PUT', 'announcements/index.php?id=$id', payload);
  }

  Future<int> uploadAnnouncementImage({
    required int announcementId,
    required Uint8List bytes,
    required String fileName,
    bool replaceExisting = false,
  }) async {
    final Uri url = Uri.parse('$apiBaseUrl/attachments/index.php');
    final http.MultipartRequest request = http.MultipartRequest('POST', url)
      ..fields['announcement_id'] = '$announcementId'
      ..fields['replace_existing'] = replaceExisting ? '1' : '0'
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

    final http.StreamedResponse streamedResponse = await request.send();
    final http.Response response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Image upload failed: ${response.statusCode}');
    }

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    if (body['status'] != 'success') {
      throw Exception(body['message'] ?? 'Image upload error');
    }

    return int.tryParse('${body['id'] ?? 0}') ?? 0;
  }

  Future<void> deleteAnnouncement(int id) async {
    await _request('DELETE', 'announcements/index.php?id=$id');
  }

  Future<void> updateUser(Map<String, dynamic> payload) async {
    await _sendJson('POST', 'users/update_user.php', payload);
  }

  Future<void> createUser(Map<String, dynamic> payload) async {
    await _sendJson('POST', 'users/create_user.php', payload);
  }

  Future<void> updateFaculty(int id, Map<String, dynamic> payload) async {
    await _sendJson('PUT', 'faculties/index.php?id=$id', payload);
  }

  Future<void> createFaculty(Map<String, dynamic> payload) async {
    await _sendJson('POST', 'faculties/index.php', payload);
  }

  Future<List<dynamic>> _getList(
    String path, [
    Map<String, String>? query,
  ]) async {
    final Map<String, dynamic> body = await _request('GET', path, query: query);
    return body['data'] as List<dynamic>? ?? <dynamic>[];
  }

  Future<Map<String, dynamic>> _sendJson(
    String method,
    String path,
    Map<String, dynamic> payload,
  ) {
    return _request(method, path, payload: payload);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? payload,
  }) async {
    final Uri baseUrl = Uri.parse('$apiBaseUrl/$path');
    final Uri url = query == null || query.isEmpty
        ? baseUrl
        : baseUrl.replace(queryParameters: query);
    final http.Response response;

    switch (method) {
      case 'POST':
        response = await http.post(
          url,
          headers: _headers,
          body: jsonEncode(payload),
        );
        break;
      case 'PUT':
        response = await http.put(
          url,
          headers: _headers,
          body: jsonEncode(payload),
        );
        break;
      case 'DELETE':
        response = await http.delete(url);
        break;
      default:
        response = await http.get(url);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed: ${response.statusCode}');
    }

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    if (body['status'] != 'success') {
      throw Exception(body['message'] ?? 'API error');
    }

    return body;
  }

  static const Map<String, String> _headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  };
}
