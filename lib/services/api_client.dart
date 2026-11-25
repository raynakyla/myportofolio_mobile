import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:myportofolio_mobile/config/api_config.dart';
import 'package:myportofolio_mobile/models/project.dart';

enum ApiFailureKind { http, invalidResponse, connection }

/// Public error metadata, without response bodies or internal server details.
class ApiException implements Exception {
  const ApiException(this.kind, {this.statusCode});

  final ApiFailureKind kind;
  final int? statusCode;

  String get message => switch (kind) {
    ApiFailureKind.http =>
      'Proyek belum dapat dimuat. Coba lagi beberapa saat.',
    ApiFailureKind.invalidResponse =>
      'Data proyek belum dapat dibaca. Silakan coba lagi.',
    ApiFailureKind.connection =>
      'Tidak dapat terhubung. Periksa koneksi Anda lalu coba lagi.',
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
