import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/config/api_config.dart';
import 'package:myportofolio_mobile/models/project_data.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  const project = {
    'id': '26c530b1-5de2-4279-a3b4-719c3972797f',
    'title': 'Karya • Desain',
    'description': 'Cerita portofolio',
    'category': 'creative',
    'role': 'Designer',
    'skills': 'Figma',
    'thumbnail': null,
    'project_url': '',
    'is_featured': true,
    'star_count': 2,
    'is_starred': false,
    'starred_by_names': 'reader, owner',
  };

  ApiClient clientFor(http.Response response) {
    final mock = MockClient((_) async => response);
    addTearDown(mock.close);
    return ApiClient(client: mock);
  }

  TypeMatcher<ApiException> failure(ApiFailureKind kind, {int? status}) =>
      isA<ApiException>()
          .having((error) => error.kind, 'kind', kind)
          .having((error) => error.statusCode, 'statusCode', status);

  test(
    'GET is public, uses configured URI, and parses UTF-8 Projects',
    () async {
      final mock = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url, ApiConfig.projectsUri);
        expect(request.headers['Accept'], 'application/json');
        expect(request.headers.containsKey('authorization'), isFalse);
        return http.Response.bytes(utf8.encode(jsonEncode([project])), 200);
      });
      addTearDown(mock.close);

      final result = await ApiClient(client: mock).getProjects();

      expect(result, hasLength(1));
      expect(result.single.id, project['id']);
      expect(result.single.title, 'Karya • Desain');
      expect(result.single.category, ProjectCategory.creative);
      expect(result.single.thumbnail, isEmpty);
      expect(result.single.starCount, 2);
    },
  );

  test('an empty backend list remains empty', () async {
    expect(await clientFor(http.Response('[]', 200)).getProjects(), isEmpty);
  });

  test(
    'HTTP failures preserve status without exposing HTML or details',
    () async {
      for (final code in [401, 403, 404, 500, 503]) {
        final client = clientFor(
          http.Response('<html>Internal traceback</html>', code),
        );
        await expectLater(
          client.getProjects(),
          throwsA(failure(ApiFailureKind.http, status: code)),
        );
      }
      const error = ApiException(ApiFailureKind.http, statusCode: 500);
      expect(error.message, isNot(contains('traceback')));
      expect(error.toString(), error.message);
    },
  );

  test(
    'malformed JSON and HTML with status 200 are invalid responses',
    () async {
      for (final body in ['[{', '<html>Server details</html>']) {
        await expectLater(
          clientFor(http.Response(body, 200)).getProjects(),
          throwsA(failure(ApiFailureKind.invalidResponse)),
        );
      }
    },
  );

  test('rejects non-list roots instead of inventing data', () async {
    for (final root in [
      null,
      'projects',
      {
        'results': [project],
      },
    ]) {
      await expectLater(
        clientFor(http.Response.bytes(utf8.encode(jsonEncode(root)), 200))
            .getProjects(),
        throwsA(failure(ApiFailureKind.invalidResponse)),
      );
    }
  });

  test(
    'invalid entries fail the list rather than silently dropping projects',
    () async {
      for (final entry in [
        null,
        'invalid',
        {'title': 'Incomplete'},
        {...project, 'category': 'career'},
      ]) {
        await expectLater(
          clientFor(
            http.Response.bytes(utf8.encode(jsonEncode([project, entry])), 200),
          ).getProjects(),
          throwsA(failure(ApiFailureKind.invalidResponse)),
        );
      }
    },
  );

  test('connection errors become a safe structured failure', () async {
    final mock = MockClient(
      (_) async => throw http.ClientException('Private socket details'),
    );
    addTearDown(mock.close);
    await expectLater(
      ApiClient(client: mock).getProjects(),
      throwsA(
        failure(ApiFailureKind.connection).having(
          (error) => error.message,
          'safe message',
          isNot(contains('Private')),
        ),
      ),
    );
  });

  test('a timed out request becomes a connection failure', () async {
    final mock = MockClient((_) => Completer<http.Response>().future);
    addTearDown(mock.close);
    await expectLater(
      ApiClient(client: mock, timeout: Duration.zero).getProjects(),
      throwsA(failure(ApiFailureKind.connection)),
    );
  });
}
