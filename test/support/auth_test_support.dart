import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/auth/auth_state.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

String sessionTestToken() {
  final random = Random.secure();
  return List.generate(40, (_) => random.nextInt(16).toRadixString(16)).join();
}

http.Response tokenResponse(String token) => http.Response(
  jsonEncode({'token': token}),
  200,
  headers: {'content-type': 'application/json'},
);

Future<AuthState> signedInTestAuth() async {
  final token = sessionTestToken();
  final client = MockClient((_) async => tokenResponse(token));
  addTearDown(client.close);
  final auth = AuthState(ApiClient(client: client));
  addTearDown(auth.dispose);
  final success = await auth.login('test-reader', sessionTestToken());
  expect(success, isTrue);
  return auth;
}
