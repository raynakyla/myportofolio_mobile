import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/auth/auth_state.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/home_page.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:provider/provider.dart';

import 'support/auth_test_support.dart';

void main() {
  final token = sessionTestToken();
  final password = sessionTestToken();
  AuthState stateFor(Future<http.Response> Function(http.Request) handler) {
    final client = MockClient(handler);
    addTearDown(client.close);
    final auth = AuthState(ApiClient(client: client));
    addTearDown(auth.dispose);
    return auth;
  }

  test(
    'successful login updates listeners and keeps a memory-only session',
    () async {
      final auth = stateFor((_) async => tokenResponse(token));
      final states = <bool>[];
      auth.addListener(() => states.add(auth.isLoggedIn));
      expect(auth.isLoggedIn, isFalse);
      expect(await auth.login('  test-reader  ', password), isTrue);
      expect(auth.token == token, isTrue);
      expect(auth.username, 'test-reader');
      expect(auth.isBusy, isFalse);
      expect(auth.failure, isNull);
      expect(states.first, isFalse);
      expect(states.last, isTrue);
      final fresh = stateFor((_) async => tokenResponse(token));
      expect(fresh.isLoggedIn, isFalse);
      expect(fresh.token, isNull);
    },
  );

  test(
    'failed login retains no token and a retry clears the failure',
    () async {
      var calls = 0;
      final auth = stateFor(
        (_) async =>
            ++calls == 1 ? http.Response('private', 400) : tokenResponse(token),
      );
      expect(await auth.login('test-reader', password), isFalse);
      expect(auth.token, isNull);
      expect(auth.isBusy, isFalse);
      expect(auth.failure?.kind, ApiFailureKind.invalidCredentials);
      expect(await auth.login('test-reader', password), isTrue);
      expect(auth.failure, isNull);
    },
  );

  test('duplicate login submission makes only one request', () async {
    final pending = Completer<http.Response>();
    var calls = 0;
    final auth = stateFor((_) {
      calls++;
      return pending.future;
    });
    final first = auth.login('test-reader', password);
    expect(auth.isBusy, isTrue);
    expect(await auth.login('test-reader', password), isFalse);
    pending.complete(tokenResponse(token));
    expect(await first, isTrue);
    expect(calls, 1);
  });

  test('cancel ignores a late successful login', () async {
    final pending = Completer<http.Response>();
    final auth = stateFor((_) => pending.future);
    final attempt = auth.login('test-reader', password);
    auth.cancelLogin();
    pending.complete(tokenResponse(token));
    expect(await attempt, isFalse);
    expect(auth.token, isNull);
    expect(auth.isBusy, isFalse);
  });

  for (final status in [204, 401, 500]) {
    test(
      'logout clears local session even with server status $status',
      () async {
        final pending = Completer<http.Response>();
        final auth = stateFor((request) async {
          if (request.url.path.endsWith('/token/')) return tokenResponse(token);
          expect(request.headers['Authorization'] == 'Token $token', isTrue);
          return pending.future;
        });
        await auth.login('test-reader', password);
        final logout = auth.logout();
        expect(auth.token, isNull);
        expect(auth.username, isNull);
        expect(auth.isLoggedIn, isFalse);
        pending.complete(http.Response('', status));
        await logout;
        expect(auth.isBusy, isFalse);
        expect(auth.isLoggedIn, isFalse);
        expect(auth.failure == null, status == 204);
      },
    );
  }

  test('logout connection failure still clears the session', () async {
    final auth = stateFor((request) async {
      if (request.url.path.endsWith('/token/')) return tokenResponse(token);
      throw http.ClientException('private');
    });
    await auth.login('test-reader', password);
    await auth.logout();
    expect(auth.token, isNull);
    expect(auth.isBusy, isFalse);
    expect(auth.failure?.kind, ApiFailureKind.connection);
  });

  test(
    'logout without a token skips network and cancels pending login',
    () async {
      var calls = 0;
      final pending = Completer<http.Response>();
      final auth = stateFor((_) {
        calls++;
        return pending.future;
      });
      await auth.logout();
      expect(calls, 0);
      final login = auth.login('test-reader', password);
      await auth.logout();
      pending.complete(tokenResponse(token));
      expect(await login, isFalse);
      expect(calls, 1);
      expect(auth.token, isNull);
    },
  );

  test('disposed state ignores request completion', () async {
    final pending = Completer<http.Response>();
    final client = MockClient((_) => pending.future);
    addTearDown(client.close);
    final auth = AuthState(ApiClient(client: client));
    final login = auth.login('test-reader', password);
    auth.dispose();
    pending.complete(tokenResponse(token));
    expect(await login, isFalse);
    expect(auth.token, isNull);
  });

  test(
    'cancelling a login route does not interrupt an ongoing logout',
    () async {
      final pending = Completer<http.Response>();
      final auth = stateFor((request) async {
        if (request.url.path.endsWith('/token/')) return tokenResponse(token);
        return pending.future;
      });
      await auth.login('test-reader', password);
      final logout = auth.logout();
      auth.cancelLogin();
      expect(auth.isBusy, isTrue);
      expect(await auth.login('test-reader', password), isFalse);
      pending.complete(http.Response('', 204));
      await logout;
      expect(auth.isBusy, isFalse);
      expect(auth.token, isNull);
    },
  );

  testWidgets(
    'providers preserve injected client and notifier across app rebuilds',
    (tester) async {
      final client = MockClient((_) async => tokenResponse(token));
      addTearDown(client.close);
      final api = ApiClient(client: client);
      await tester.pumpWidget(MyApp(apiClient: api));
      final context = tester.element(find.byType(MyHomePage));
      final auth = context.read<AuthState>();
      expect(identical(context.read<ApiClient>(), api), isTrue);
      await auth.login('test-reader', password);
      await tester.pumpWidget(MyApp(apiClient: api));
      expect(
        identical(
          tester.element(find.byType(MyHomePage)).read<AuthState>(),
          auth,
        ),
        isTrue,
      );
      expect(auth.isLoggedIn, isTrue);
    },
  );
}
