import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/config/api_config.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/models/project_data.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'support/auth_test_support.dart';

void main() {
  final token = sessionTestToken();
  const project = Project(
    id: 'local-id',
    title: 'Draft',
    description: 'Description',
    category: ProjectCategory.creative,
    role: 'Designer',
    skills: 'Figma',
    starCount: 12,
    isStarred: true,
    starredByNames: 'local',
  );
  const input = {
    'title': 'Draft',
    'description': 'Description',
    'category': 'creative',
    'role': 'Designer',
    'skills': 'Figma',
    'thumbnail': '',
    'project_url': '',
    'is_featured': false,
  };
  ApiClient api(
    Future<http.Response> Function(http.Request) handler, {
    Duration timeout = const Duration(seconds: 15),
  }) {
    final client = MockClient(handler);
    addTearDown(client.close);
    return ApiClient(client: client, timeout: timeout);
  }

  Matcher failure(ApiFailureKind kind, int? statusCode) => isA<ApiException>()
      .having((e) => e.kind, 'kind', kind)
      .having((e) => e.statusCode, 'status', statusCode)
      .having((e) => e.operation, 'operation', ApiOperation.createProject)
      .having(
        (e) => e.message.contains(token) || e.message.contains('PRIVATE'),
        'exposes server/secret data',
        false,
      );

  test(
    'POST sends only writable JSON and returns the 201 server object',
    () async {
      final client = api((request) async {
        expect(request.method, 'POST');
        expect(request.url, ApiConfig.projectsUri);
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.headers['Accept'], 'application/json');
        expect(request.headers['Authorization'] == 'Token $token', isTrue);
        expect(jsonDecode(request.body), input);
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              ...input,
              'id': '8556ce82-72e1-4f83-904d-5fba9e35db54',
              'title': 'Portofolio ✨',
              'star_count': 3,
            }),
          ),
          201,
        );
      });
      final saved = await client.createProject(project, token);
      expect(saved.id, '8556ce82-72e1-4f83-904d-5fba9e35db54');
      expect(saved.title, 'Portofolio ✨');
      expect(saved.starCount, 3);
    },
  );

  for (final (status, body, kind) in [
    (400, '{"title":["PRIVATE"]}', ApiFailureKind.validation),
    (401, 'PRIVATE', ApiFailureKind.invalidToken),
    (
      403,
      '{"detail":"You do not have permission to perform this action."}',
      ApiFailureKind.forbidden,
    ),
    (403, '{"detail":"Invalid token."}', ApiFailureKind.invalidToken),
    (
      403,
      '{"detail":"User inactive or deleted."}',
      ApiFailureKind.invalidToken,
    ),
    (403, '<html>PRIVATE</html>', ApiFailureKind.forbidden),
    (500, 'PRIVATE', ApiFailureKind.http),
    (200, '{}', ApiFailureKind.invalidResponse),
    (201, '<html>PRIVATE</html>', ApiFailureKind.invalidResponse),
    (201, '[]', ApiFailureKind.invalidResponse),
    (201, '{"id":"returned-id"}', ApiFailureKind.invalidResponse),
    (201, jsonEncode(input), ApiFailureKind.invalidResponse),
  ]) {
    test(
      'maps $status response case ${kind.name} without exposing its body',
      () async {
        await expectLater(
          api((_) async => http.Response(body, status))
              .createProject(project, token),
          throwsA(failure(kind, status)),
        );
      },
    );
  }

  test('invalid local token stops before the request', () async {
    final client = api((_) async => throw StateError('Unexpected request'));
    await expectLater(
      client.createProject(project, ''),
      throwsA(failure(ApiFailureKind.invalidToken, null)),
    );
  });

  test('transport failure is transformed into a safe error', () async {
    final client = api(
      (_) async => throw http.ClientException('PRIVATE $token'),
    );
    await expectLater(
      client.createProject(project, token),
      throwsA(failure(ApiFailureKind.connection, null)),
    );
  });

  test('timeout is transformed into a safe error', () async {
    final client = api(
      (_) => Completer<http.Response>().future,
      timeout: Duration.zero,
    );
    await expectLater(
      client.createProject(project, token),
      throwsA(failure(ApiFailureKind.connection, null)),
    );
  });
}
