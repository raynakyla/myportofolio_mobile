import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/config/api_config.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'support/auth_test_support.dart';

void main() {
  final token = sessionTestToken();
  final password = sessionTestToken();
  ApiClient apiFor(
    Future<http.Response> Function(http.Request) handler, {
    Duration? timeout,
  }) {
    final client = MockClient(handler);
    addTearDown(client.close);
    return ApiClient(
      client: client,
      timeout: timeout ?? const Duration(seconds: 15),
    );
  }

  TypeMatcher<ApiException> failure(
    ApiFailureKind kind,
    ApiOperation operation,
  ) => isA<ApiException>()
      .having((e) => e.kind, 'kind', kind)
      .having((e) => e.operation, 'operation', operation);

  test(
    'login POST sends JSON and returns a valid token without a session header',
    () async {
      final api = apiFor((request) async {
        expect(request.method, 'POST');
        expect(request.url, ApiConfig.tokenUri);
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.headers.containsKey('authorization'), isFalse);
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body.keys.toSet(), {'username', 'password'});
        expect(body['username'] == 'test-reader', isTrue);
        expect(body['password'] == password, isTrue);
        return tokenResponse(token);
      });
      expect(await api.obtainToken('test-reader', password) == token, isTrue);
    },
  );

  test(
    'credential failures do not expose server bodies or supplied secrets',
    () async {
      for (final status in [400, 401, 403]) {
        final api = apiFor(
          (_) async => http.Response('private $password $token', status),
        );
        try {
          await api.obtainToken('test-reader', password);
          fail('Expected safe failure');
        } on ApiException catch (error) {
          expect(error.kind, ApiFailureKind.invalidCredentials);
          expect(error.statusCode, status);
          expect(error.toString().contains(password), isFalse);
          expect(error.toString().contains(token), isFalse);
          expect(error.toString().contains('private'), isFalse);
        }
      }
    },
  );

  test('login server error retains only safe status metadata', () async {
    await expectLater(
      apiFor((_) async => http.Response('<html>traceback</html>', 503))
          .obtainToken('test-reader', password),
      throwsA(
        failure(
          ApiFailureKind.http,
          ApiOperation.login,
        ).having((e) => e.statusCode, 'status', 503),
      ),
    );
  });

  test(
    'login rejects malformed JSON and missing or invalid token fields',
    () async {
      for (final body in [
        '<html>',
        '{}',
        '[]',
        'null',
        '{"token":null}',
        '{"token":4}',
        '{"token":""}',
        '{"token":"invalid"}',
      ]) {
        await expectLater(
          apiFor((_) async => http.Response(body, 200))
              .obtainToken('test-reader', password),
          throwsA(failure(ApiFailureKind.invalidResponse, ApiOperation.login)),
        );
      }
    },
  );

  test('logout sends caller token and requires 204', () async {
    final api = apiFor((request) async {
      expect(request.method, 'POST');
      expect(request.url, ApiConfig.logoutUri);
      expect(request.headers['Authorization'] == 'Token $token', isTrue);
      expect(request.body, isEmpty);
      return http.Response('', 204);
    });
    await api.logout(token);
  });

  test(
    'logout refuses empty or invalid tokens before making a request',
    () async {
      var calls = 0;
      final api = apiFor((_) async {
        calls++;
        return http.Response('', 204);
      });
      for (final invalid in ['', 'invalid', '$token\r\nextra']) {
        await expectLater(
          api.logout(invalid),
          throwsA(failure(ApiFailureKind.invalidToken, ApiOperation.logout)),
        );
      }
      expect(calls, 0);
    },
  );

  test('logout distinguishes rejected token, server error, and wrong success response', () async {
    for (final status in [401, 403, 500, 200]) {
      final expected = status == 200
          ? ApiFailureKind.invalidResponse
          : status == 500
          ? ApiFailureKind.http
          : ApiFailureKind.invalidToken;
      await expectLater(
        apiFor((_) async => http.Response('private', status)).logout(token),
        throwsA(failure(expected, ApiOperation.logout)),
      );
    }
  });

  for (final operation in [ApiOperation.login, ApiOperation.logout]) {
    test('$operation connection failure is safe', () async {
      final api = apiFor(
        (_) async => throw http.ClientException('private $password $token'),
      );
      final Future<Object?> result = operation == ApiOperation.login
          ? api.obtainToken('test-reader', password)
          : api.logout(token);
      await expectLater(
        result,
        throwsA(failure(ApiFailureKind.connection, operation)),
      );
    });
    test('$operation timeout is safe', () async {
      final api = apiFor(
        (_) => Completer<http.Response>().future,
        timeout: Duration.zero,
      );
      final Future<Object?> result = operation == ApiOperation.login
          ? api.obtainToken('test-reader', password)
          : api.logout(token);
      await expectLater(
        result,
        throwsA(failure(ApiFailureKind.connection, operation)),
      );
    });
  }
}
