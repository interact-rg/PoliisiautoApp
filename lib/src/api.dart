/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'data.dart';

/// initialize the global API accessor
PoliisiautoApi api =
    PoliisiautoApi(host: dotenv.get('POLIISIAUTO_API_HOST'), version: 'v1');

class PoliisiautoApi {
  final String host;
  final String version;
  final _storage = const FlutterSecureStorage();

  // Cache for reports and messages
  List<Report>? _reportsCache;
  DateTime? _lastFetchTime;
  final Map<int, List<Message>> _messagesCache = {};
  final Map<int, DateTime> _messagesCacheTime = {};
  final Duration _cacheDuration = const Duration(minutes: 5);

  PoliisiautoApi({required this.host, required this.version});

  //////////////////////////////////////////////////////////////////////////////
  /// API endpoints
  //////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////
  /// Auth endpoints
  //////////////////////////////////////////////////////////////////////////////

  Future<String?> registerDevice(Map<String, dynamic> data) async {
    var request = await buildRequest('POST', 'register');

    request.fields.addAll({
      'first_name': data['first_name'],
      'last_name': data['last_name'],
      'email': data['email'],
      'password': data['password'],
      'password_confirmation': data['password_confirmation'],
      'device_name': data['device_name'],
    });

    http.StreamedResponse response = await request.send();

    if (_isOk(response)) {
      final body = jsonDecode(await response.stream.bytesToString());
      return body['access_token'];
    }
    return null;
  }

  Future<String?> sendLogin(Credentials credentials) async {
    var request = await buildRequest('POST', 'login');

    request.fields.addAll({
      'email': credentials.email,
      'password': credentials.password,
      'device_name': 'TAMAGOTCHI',
      'api_key': dotenv.get('POLIISIAUTO_API_KEY')
    });

    http.StreamedResponse response = await request.send();

    if (_isOk(response)) {
      final respStr = await response.stream.bytesToString();
      try {
        final body = jsonDecode(respStr);
        // Try 'access_token' first (standard), then 'token' (common alternative)
        final token = body['access_token'] ?? body['token'];
        if (token != null) return token.toString();

        // If no token field found, maybe it's just the plain string? (Unlikely for API)
        
        return respStr;
      } catch (e) {
        // Not JSON?
        return respStr;
      }
    }

    return null;
  }

  Future<bool> sendLogout() async {
    var request = await buildAuthenticatedRequest('POST', 'logout');
    http.StreamedResponse response = await request.send();

    if (_isOk(response)) {
      await _storage.delete(key: 'bearer_token');
      return true;
    }

    return false;
  }

  Future<Organization> fetchAuthenticatedUserOrganization() async {
    final token = await getTokenAsync();
    final uri = Uri.parse('$baseAddress/profile/organization');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (_isOk(response)) {
      return Organization.fromJson(jsonDecode(response.body));
    }

    throw Exception(
        'Failed to load authenticated user organization (Status: ${response.statusCode}): ${response.body}');
  }

  Future<User> fetchAuthenticatedUser() async {
    final token = await getTokenAsync();
    final uri = Uri.parse('$baseAddress/profile');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (_isOk(response)) {
      return User.fromJson(jsonDecode(response.body));
    }

    throw Exception(
        'Failed to load authenticated user (Status: ${response.statusCode}): ${response.body}');
  }

  //////////////////////////////////////////////////////////////////////////////
  /// Organization endpoints
  //////////////////////////////////////////////////////////////////////////////

  Future<Organization> fetchOrganization(int organizationId) async {
    final token = await getTokenAsync();
    final uri = Uri.parse('$baseAddress/organizations/$organizationId');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (_isOk(response)) {
      return Organization.fromJson(jsonDecode(response.body));
    }

    throw Exception(
        'Request failed (Status: ${response.statusCode}): ${response.body}');
  }

  Future<List<User>> fetchTeachers() async {
    final token = await getTokenAsync();
    final uri = Uri.parse('$baseAddress/teachers');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (_isOk(response)) {
      final List<dynamic> teachersJson = jsonDecode(response.body);

      List<User> teachers = [];
      for (var t in teachersJson) {
        teachers.add(User.fromJson(t));
      }

      return teachers;
    }

    throw Exception(
        'Request failed (Status: ${response.statusCode}): ${response.body}');
  }

  Future<List<User>> fetchStudents() async {
    final token = await getTokenAsync();
    final uri = Uri.parse('$baseAddress/students');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (_isOk(response)) {
      final List<dynamic> studentsJson = jsonDecode(response.body);

      List<User> students = [];
      for (var s in studentsJson) {
        students.add(User.fromJson(s));
      }

      return students;
    }

    throw Exception(
        'Request failed (Status: ${response.statusCode}): ${response.body}');
  }

  //////////////////////////////////////////////////////////////////////////////
  /// Report endpoints
  //////////////////////////////////////////////////////////////////////////////

  Future<List<Report>> fetchReports(
      {String order = 'DESC', String? route, bool forceRefresh = false}) async {
    // Check cache
    if (!forceRefresh &&
        _reportsCache != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
  
      return _reportsCache!;
    }

    // final token = await getTokenAsync();
    const token = "21|YJXRRy2zMq3RPzadkxnYlTduexd8DX1mxt7mtjs68ab466da";
    final uri = Uri.parse('$baseAddress/${route ?? 'reports'}');

    // FIXME: Throws if logged out from '/report' as teacher
    try {
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (_isOk(response)) {
        final List<dynamic> reportsJson = jsonDecode(response.body);

        List<Report> reports = [];
        for (var r in reportsJson) {
          reports.add(Report.fromJson(r));
        }

        // order the reports by creation date
        if (order == 'DESC') {
          reports.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        } else {
          reports.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        }

        // Update cache
        _reportsCache = reports;
        _lastFetchTime = DateTime.now();

        return reports;
      }
    } catch (e) {
      return [];
    }

    return [];
  }

  Future<Report> fetchReport(int reportId) async {
    // final token = await getTokenAsync();
    const token = "21|YJXRRy2zMq3RPzadkxnYlTduexd8DX1mxt7mtjs68ab466da";
    // The user specified that messages/{report_id} helps fetch report details
    final uri = Uri.parse('$baseAddress/reports/$reportId');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

   

    if (_isOk(response)) {
      final body = jsonDecode(response.body);
      // Map 'content' to 'description' if we are treating a Message JSON as a Report
      if (body['content'] != null && body['description'] == null) {
        body['description'] = body['content'];
      }
      return Report.fromJson(body);
    }

    throw Exception(
        'Request failed (Status: ${response.statusCode}): ${response.body}');
  }

  Future<bool> sendNewReport(Report report) async {
    //print('$report');
    var request = await buildAuthenticatedRequest('POST', 'reports');

    request.fields.addAll({
      'description': _stringify(report.description),
      'is_anonymous': _stringify(report.isAnonymous),
      'reporter_id': _stringify(report.reporterId),
      'handler_id': _stringify(report.handlerId),
      'bully_id': _stringify(report.bullyId),
      'bullied_id': _stringify(report.bulliedId),
    });

    http.StreamedResponse response = await request.send();

    // DEBUG: Print response content if the request fails
    if (!_isOk(response)) _dbgPrintResponse(response);

    return _isOk(response);
  }

  Future<bool> deleteReport(int id) async {
    var request = await buildAuthenticatedRequest('DELETE', 'reports/$id');

    http.StreamedResponse response = await request.send();

    return _isOk(response);
  }

  //////////////////////////////////////////////////////////////////////////////
  /// Message endpoints
  //////////////////////////////////////////////////////////////////////////////

  Future<List<Message>> fetchMessages(int reportId,
      {bool forceRefresh = false}) async {
    // Check cache
    if (!forceRefresh &&
        _messagesCache.containsKey(reportId) &&
        DateTime.now().difference(_messagesCacheTime[reportId]!) <
            _cacheDuration) {
      return _messagesCache[reportId]!;
    }

    // final token = await getTokenAsync();
    const token = "21|YJXRRy2zMq3RPzadkxnYlTduexd8DX1mxt7mtjs68ab466da";
    // print('DEBUG: fetchMessages using token: token');

    // // Check who we are
    // try {
    //   final user = await fetchAuthenticatedUser();
    //   print(
    //       'DEBUG: Current User: ${user.id} (${user.firstName} ${user.lastName}), Role: ${user.role}');
    // } catch (e) {`
    //   print('DEBUG: Could not fetch user details: $e');
    // }

    // final uri = Uri.parse('$baseAddress/reports/$reportId/messages');
    final uri = Uri.parse('$baseAddress/reports/$reportId/messages');
 

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (_isOk(response)) {
      final decoded = jsonDecode(response.body);
      List<dynamic> messagesJson;
      if (decoded is List) {
        messagesJson = decoded;
      } else if (decoded is Map) {
        messagesJson = [decoded];
      } else {
        messagesJson = [];
      }


      List<Message> messages = [];
      for (var r in messagesJson) {
        final msg = Message.fromJson(r);
        messages.add(msg);
      }

      // order the messages by creation date
      messages.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

      // Update cache
      _messagesCache[reportId] = messages;
      _messagesCacheTime[reportId] = DateTime.now();

      return messages;
    }

    // final errorBody = response.body;
    throw Exception('Request failed (Status: ${response.statusCode})');
  }

  Future<Message> fetchMessage(int messageId) async {
    // final token = await getTokenAsync();
    const token = "21|YJXRRy2zMq3RPzadkxnYlTduexd8DX1mxt7mtjs68ab466da";
    final uri = Uri.parse('$baseAddress/messages/$messageId');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (_isOk(response)) {
      return Message.fromJson(jsonDecode(response.body));
    }

    throw Exception(
        'Request failed (Status: ${response.statusCode}): ${response.body}');
  }

  Future<bool> sendNewMessage(Message message, {File? audioFile}) async {
    var request = await buildAuthenticatedRequest(
        'POST', 'reports/${message.reportId}/messages');

    request.fields.addAll({
      'content': _stringify(message.content),
      'is_anonymous': _stringify(message.isAnonymous),
      'type': message.type ?? 'text',
    });

    if (message.lat != null) request.fields['lat'] = message.lat.toString();
    if (message.lon != null) request.fields['lon'] = message.lon.toString();

    if (audioFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          audioFile.path,
          contentType: MediaType('audio', 'wav'), // Adjust extension if needed
        ),
      );
    }

    http.StreamedResponse response = await request.send();

    // DEBUG: Print response content if the request fails
    if (!_isOk(response)) _dbgPrintResponse(response);

    return _isOk(response);
  }

  Future<bool> deleteMessage(int id) async {
    //print('$report');
    var request =
        await buildAuthenticatedRequest('DELETE', 'report-messages/$id');

    http.StreamedResponse response = await request.send();

    return _isOk(response);
  }

  //////////////////////////////////////////////////////////////////////////////
  /// Bearer Token
  //////////////////////////////////////////////////////////////////////////////

  Future<void> setTokenAsync(String token) async {
    _storage.write(key: 'bearer_token', value: token);
  }

  Future<String?> getTokenAsync() async {
    return _storage.read(key: 'bearer_token');
  }

  /// Synchronously set token.
  void setToken(String token) {
    setTokenAsync(token).whenComplete(() => null);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'bearer_token');
  }

  //////////////////////////////////////////////////////////////////////////////
  /// Helpers
  //////////////////////////////////////////////////////////////////////////////

  Future<bool> hasTokenStored() async {
    return (await getTokenAsync() != null);
  }

  Future<http.MultipartRequest> buildRequest(String method, String endpoint,
      {Map<String, String>? headers}) async {
    headers ??= {};
    headers['Accept'] = 'application/json';

    var request =
        http.MultipartRequest(method, Uri.parse('$baseAddress/$endpoint'));
    request.headers.addAll(headers);
    return request;
  }

  Future<http.MultipartRequest> buildAuthenticatedRequest(
      String method, String endpoint,
      {Map<String, String>? headers}) async {
    headers ??= {};

    String? token = await getTokenAsync();
    if (token == null) throw Exception('Unauthenticated! No token found');
    headers['Authorization'] = 'Bearer $token';

    return buildRequest(method, endpoint, headers: headers);
  }

  /// Get the base address of the API.
  // String get baseAddress => '$host/api/$version';
  // Hardcoded for development as requested
  String get baseAddress => 'https://poliisiautoweb.onrender.com/api/v1';

  /// Return true if given response is successful.
  bool _isOk(http.BaseResponse response) =>
      200 <= response.statusCode && response.statusCode < 300;

  /// Convert a variable to string as in JSON field.
  String _stringify(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is int) return v.toString();
    if (v is bool) return v ? '1' : '0';

    throw Exception('Cannot _stringify type ${v.runtimeType}');
  }

  void _dbgPrintResponse(http.StreamedResponse response) async {
    
  }
}
