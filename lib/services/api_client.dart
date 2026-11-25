import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:myportofolio_mobile/config/api_config.dart';
import 'package:myportofolio_mobile/models/project.dart';

enum ApiFailureKind {
  http,
  invalidResponse,
  connection,
  invalidCredentials,
  invalidToken,
  validation,
  forbidden,
}

enum ApiOperation { projects, login, logout, createProject }

/// Public error metadata, without response bodies or internal server details.
class ApiException implements Exception {
  const ApiException(
    this.kind, {
    this.statusCode,
    this.operation = ApiOperation.projects,
  });

  final ApiFailureKind kind;
  final int? statusCode;
  final ApiOperation operation;

  String get message => switch (kind) {
    ApiFailureKind.http => switch (operation) {
      ApiOperation.projects =>
        'Proyek belum dapat dimuat. Coba lagi beberapa saat.',
      ApiOperation.login => 'Login belum dapat diproses. Silakan coba lagi.',
      ApiOperation.createProject => 'Proyek belum dapat disimpan. Periksa daftar proyek sebelum mencoba lagi.',
      ApiOperation.logout => 'Pencabutan sesi server belum berhasil. Anda tetap keluar dari aplikasi.',
    },
    ApiFailureKind.invalidResponse => switch (operation) {
      ApiOperation.projects =>
        'Data proyek belum dapat dibaca. Silakan coba lagi.',
      ApiOperation.createProject => 'Konfirmasi dari server tidak dapat dibaca. Periksa daftar proyek sebelum mencoba lagi.',
      _ => 'Respons autentikasi belum dapat dibaca. Silakan coba lagi.',
    },
    ApiFailureKind.connection =>
      operation == ApiOperation.createProject
          ? 'Penyimpanan belum dapat dikonfirmasi. Periksa koneksi dan daftar proyek sebelum mencoba lagi.'
          : 'Tidak dapat terhubung. Periksa koneksi Anda lalu coba lagi.',
    ApiFailureKind.invalidCredentials => 'Username atau password tidak cocok.',
    ApiFailureKind.invalidToken =>
      'Sesi tidak valid atau sudah berakhir. Silakan login kembali.',
    ApiFailureKind.validation =>
      'Server menolak isian proyek. Periksa kembali data yang Anda masukkan.',
    ApiFailureKind.forbidden => 'Akun ini tidak memiliki izin menyimpan proyek. Hanya superuser yang dapat menambah proyek.',
  };

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client, this.timeout = const Duration(seconds: 15)})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;

  static bool _validToken(String token) =>
      token.length == 40 && RegExp(r'^[a-fA-F0-9]{40}$').hasMatch(token);

  Future<http.Response> _request(
    Future<http.Response> Function() send,
    ApiOperation operation,
  ) async {
    try {
      return await send().timeout(timeout);
    } on http.ClientException {
      throw ApiException(ApiFailureKind.connection, operation: operation);
    } on TimeoutException {
      throw ApiException(ApiFailureKind.connection, operation: operation);
    }
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _request(
      () => _client.post(
        ApiConfig.tokenUri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      ),
      ApiOperation.login,
    );
    if ([400, 401, 403].contains(response.statusCode)) {
      throw ApiException(
        ApiFailureKind.invalidCredentials,
        statusCode: response.statusCode,
        operation: ApiOperation.login,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        ApiFailureKind.http,
        statusCode: response.statusCode,
        operation: ApiOperation.login,
      );
    }
    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic> ||
          json['token'] is! String ||
          !_validToken(json['token'] as String)) {
        throw const ApiException(
          ApiFailureKind.invalidResponse,
          operation: ApiOperation.login,
        );
      }
      return json['token'] as String;
    } on FormatException {
      throw const ApiException(
        ApiFailureKind.invalidResponse,
        operation: ApiOperation.login,
      );
    }
  }

  Future<void> logout(String token) async {
    if (!_validToken(token)) {
      throw const ApiException(
        ApiFailureKind.invalidToken,
        operation: ApiOperation.logout,
      );
    }
    final response = await _request(
      () => _client.post(
        ApiConfig.logoutUri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
      ),
      ApiOperation.logout,
    );
    if ([401, 403].contains(response.statusCode)) {
      throw ApiException(
        ApiFailureKind.invalidToken,
        statusCode: response.statusCode,
        operation: ApiOperation.logout,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        ApiFailureKind.http,
        statusCode: response.statusCode,
        operation: ApiOperation.logout,
      );
    }
    if (response.statusCode != 204) {
      throw const ApiException(
        ApiFailureKind.invalidResponse,
        operation: ApiOperation.logout,
      );
    }
  }

  Future<Project> createProject(Project project, String token) async {
    const operation = ApiOperation.createProject;
    if (!_validToken(token)) {
      throw const ApiException(
        ApiFailureKind.invalidToken,
        operation: operation,
      );
    }
    final response = await _request(
      () => _client.post(
        ApiConfig.projectsUri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(project.toJson()),
      ),
      operation,
    );
    final statusCode = response.statusCode;
    if (statusCode != 201) {
      final kind = switch (statusCode) {
        400 => ApiFailureKind.validation,
        401 => ApiFailureKind.invalidToken,
        403 =>
          _isAuthenticationRejection(response)
              ? ApiFailureKind.invalidToken
              : ApiFailureKind.forbidden,
        >= 200 && < 300 => ApiFailureKind.invalidResponse,
        _ => ApiFailureKind.http,
      };
      throw ApiException(kind, statusCode: statusCode, operation: operation);
    }

    final invalidResponse = ApiException(
      ApiFailureKind.invalidResponse,
      statusCode: statusCode,
      operation: operation,
    );
    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) throw invalidResponse;
      final saved = Project.fromJson(json);
      if (saved.id?.trim().isNotEmpty != true) throw invalidResponse;
      return saved;
    } on FormatException {
      throw invalidResponse;
    } on CheckedFromJsonException {
      throw invalidResponse;
    }
  }

  // With SessionAuthentication first, DRF can return 403 for invalid tokens.
  // Only known authentication details justify invalidating the local session.
  static bool _isAuthenticationRejection(http.Response response) {
    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) return false;
      final detail = json['detail'];
      return detail is String &&
          const {
            'Invalid token.',
            'User inactive or deleted.',
            'Authentication credentials were not provided.',
            'Invalid token header. No credentials provided.',
            'Invalid token header. Token string should not contain spaces.',
            'Invalid token header. Token string should not contain invalid characters.',
          }.contains(detail);
    } on FormatException {
      return false;
    }
  }

  Future<List<Project>> getProjects() async {
    final http.Response response;
    try {
      response = await _client
          .get(ApiConfig.projectsUri, headers: {'Accept': 'application/json'})
          .timeout(timeout);
    } on http.ClientException {
      throw const ApiException(ApiFailureKind.connection);
    } on TimeoutException {
      throw const ApiException(ApiFailureKind.connection);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(ApiFailureKind.http, statusCode: response.statusCode);
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List) {
        throw const ApiException(ApiFailureKind.invalidResponse);
      }
      return decoded
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const ApiException(ApiFailureKind.invalidResponse);
            }
            return Project.fromJson(item);
          })
          .toList(growable: false);
    } on FormatException {
      throw const ApiException(ApiFailureKind.invalidResponse);
    } on CheckedFromJsonException {
      throw const ApiException(ApiFailureKind.invalidResponse);
    } on TypeError {
      throw const ApiException(ApiFailureKind.invalidResponse);
    }
  }

  /// An injected HTTP client remains owned by the caller.
  void close() {
    if (_ownsClient) _client.close();
  }
}
