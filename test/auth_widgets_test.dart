import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/auth/auth_navigation.dart';
import 'package:myportofolio_mobile/auth/auth_state.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form_page.dart';
import 'package:myportofolio_mobile/screens/home_page.dart';
import 'package:myportofolio_mobile/screens/login_page.dart';
import 'package:myportofolio_mobile/screens/project_form_page.dart';
import 'package:myportofolio_mobile/screens/project_list_page.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'support/auth_test_support.dart';

Finder loginField(String name) => find.byKey(ValueKey('login_$name'));
Finder loginSubmit() => find.widgetWithText(FilledButton, 'Login');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final token = sessionTestToken();
  final password = sessionTestToken();

  setUpAll(() async {
    for (final entry in {
      'DM Sans': ['assets/fonts/dm_sans/DMSans-Variable.ttf'],
      'Playfair Display': [
        'assets/fonts/playfair_display/PlayfairDisplay-Variable.ttf',
      ],
    }.entries) {
      final loader = FontLoader(entry.key);
      for (final asset in entry.value) {
        loader.addFont(rootBundle.load(asset));
      }
      await loader.load();
    }
  });

  ApiClient apiFor(Future<http.Response> Function(http.Request) handler) {
    final client = MockClient(handler);
    addTearDown(client.close);
    return ApiClient(client: client);
  }

  Future<AuthState> launch(WidgetTester tester, {ApiClient? api}) async {
    api ??= apiFor(
      (request) async => request.url.path.endsWith('/token/')
          ? tokenResponse(token)
          : http.Response('', 204),
    );
    final auth = AuthState(api);
    addTearDown(auth.dispose);
    await tester.pumpWidget(MyApp(apiClient: api, authState: auth));
    return auth;
  }

  Future<void> tapText(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> credentials(WidgetTester tester) async {
    await tester.ensureVisible(loginField('username'));
    await tester.enterText(loginField('username'), 'test-reader');
    await tester.ensureVisible(loginField('password'));
    await tester.enterText(loginField('password'), password);
    await tester.ensureVisible(loginSubmit());
  }

  Future<void> submit(WidgetTester tester) async {
    await credentials(tester);
    await tester.tap(loginSubmit());
    await tester.pumpAndSettle();
  }

  Future<void> drawerAction(WidgetTester tester, String label) async {
    final button = find.byType(DrawerButton);
    if (button.evaluate().isNotEmpty) {
      await tester.tap(button);
    } else {
      await tester.tap(find.byTooltip('Buka navigasi'));
    }
    await tester.pumpAndSettle();
    final tile = find.widgetWithText(ListTile, label);
    await tester.scrollUntilVisible(
      tile,
      180,
      scrollable: find
          .descendant(
            of: find.byType(Drawer),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  testWidgets('Login validates empty fields without sending credentials', (
    tester,
  ) async {
    var calls = 0;
    await launch(
      tester,
      api: apiFor((_) async {
        calls++;
        return tokenResponse(token);
      }),
    );
    await tapText(tester, 'Login');
    await tester.ensureVisible(loginSubmit());
    await tester.tap(loginSubmit());
    await tester.pumpAndSettle();
    expect(find.text('Masukkan username.'), findsOneWidget);
    expect(find.text('Masukkan password.'), findsOneWidget);
    expect(calls, 0);
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: loginField('password'),
              matching: find.byType(TextField),
            ),
          )
          .obscureText,
      isTrue,
    );
  });

  testWidgets(
    'successful Login returns Home and reactively changes Login to Logout',
    (tester) async {
      final auth = await launch(tester);
      final home = tester.element(find.byType(MyHomePage));
      await tapText(tester, 'Login');
      await submit(tester);
      expect(auth.isLoggedIn, isTrue);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.text('Logout'), findsOneWidget);
      expect(tester.element(find.byType(MyHomePage)), same(home));
    },
  );

  testWidgets('failed Login stays on screen with a safe error and can retry', (
    tester,
  ) async {
    var calls = 0;
    final auth = await launch(
      tester,
      api: apiFor(
        (_) async => ++calls == 1
            ? http.Response('<html>private $token $password</html>', 400)
            : tokenResponse(token),
      ),
    );
    await tapText(tester, 'Login');
    await submit(tester);
    expect(auth.isLoggedIn, isFalse);
    expect(find.text('Username atau password tidak cocok.'), findsOneWidget);
    expect(find.textContaining('<html>'), findsNothing);
    await tester.ensureVisible(loginSubmit());
    await tester.tap(loginSubmit());
    await tester.pumpAndSettle();
    expect(auth.isLoggedIn, isTrue);
  });

  testWidgets(
    'sending indicator and disabled submit prevent duplicate requests',
    (tester) async {
      var calls = 0;
      final pending = Completer<http.Response>();
      await launch(
        tester,
        api: apiFor((_) {
          calls++;
          return pending.future;
        }),
      );
      await tapText(tester, 'Login');
      await credentials(tester);
      await tester.tap(loginSubmit());
      await tester.pump();
      final button = find.widgetWithText(FilledButton, 'Memproses…');
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await tester.tap(button);
      await tester.pump();
      expect(calls, 1);
      pending.complete(tokenResponse(token));
      await tester.pumpAndSettle();
      expect(find.text('Logout'), findsOneWidget);
    },
  );

  testWidgets('cancelling a pending login ignores success and keeps Home', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    final auth = await launch(tester, api: apiFor((_) => pending.future));
    await tapText(tester, 'Tambah Project');
    await credentials(tester);
    await tester.tap(loginSubmit());
    await tester.pump();
    await tester.ensureVisible(find.text('Batal'));
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    pending.complete(tokenResponse(token));
    await tester.pumpAndSettle();
    expect(auth.isLoggedIn, isFalse);
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home guard cancellation does not open Project preview', (
    tester,
  ) async {
    await launch(tester);
    final home = tester.element(find.byType(MyHomePage));
    await tapText(tester, 'Tambah Project');
    expect(find.byType(LoginPage), findsOneWidget);
    await tapText(tester, 'Batal');
    expect(tester.element(find.byType(MyHomePage)), same(home));
    expect(find.byType(ProjectFormPage), findsNothing);
  });

  testWidgets(
    'Home guard success opens preview and Back returns original Home',
    (tester) async {
      await launch(tester);
      final home = tester.element(find.byType(MyHomePage));
      await tapText(tester, 'Tambah Project');
      await submit(tester);
      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.byType(LoginPage, skipOffstage: false), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(tester.element(find.byType(MyHomePage)), same(home));
    },
  );

  testWidgets('drawer guard cancellation returns to the same public list', (
    tester,
  ) async {
    await launch(tester, api: apiFor((_) async => http.Response('[]', 200)));
    await tapText(tester, 'Lihat Proyek');
    final list = tester.element(find.byType(ProjectListPage));
    await drawerAction(tester, 'Tambah Project');
    expect(find.byType(LoginPage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(tester.element(find.byType(ProjectListPage)), same(list));
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(
      tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
      isFalse,
    );
  });

  testWidgets(
    'drawer guard success replaces Experience with Project above Home',
    (tester) async {
      await launch(tester);
      await tapText(tester, 'Tambah Experience');
      await drawerAction(tester, 'Tambah Project');
      await submit(tester);
      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(
        find.byType(ExperienceFormPage, skipOffstage: false),
        findsNothing,
      );
      expect(find.byType(MyHomePage, skipOffstage: false), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    },
  );

  testWidgets('already authenticated guard is true and does not push Login', (
    tester,
  ) async {
    final auth = await launch(tester);
    await auth.login('test-reader', password);
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(MyHomePage));
    expect(await ensureLoggedIn(context), isTrue);
    expect(find.byType(LoginPage), findsNothing);
    await tapText(tester, 'Tambah Project');
    expect(find.byType(ProjectFormPage), findsOneWidget);
  });

  testWidgets('drawer Login and Logout follow session state reactively', (
    tester,
  ) async {
    final auth = await launch(tester);
    await drawerAction(tester, 'Login');
    await submit(tester);
    expect(auth.isLoggedIn, isTrue);
    await drawerAction(tester, 'Logout');
    expect(auth.isLoggedIn, isFalse);
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets(
    'Home logout clears local state and changes action even if server fails',
    (tester) async {
      final auth = await launch(
        tester,
        api: apiFor(
          (request) async => request.url.path.endsWith('/token/')
              ? tokenResponse(token)
              : http.Response('<html>private</html>', 500),
        ),
      );
      await tapText(tester, 'Login');
      await submit(tester);
      await tapText(tester, 'Logout');
      expect(auth.isLoggedIn, isFalse);
      expect(auth.token, isNull);
      expect(find.text('Login'), findsOneWidget);
      expect(
        find.text(
          'Anda sudah keluar dari aplikasi. Pencabutan sesi server belum berhasil.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('Experience remains public local preview', (tester) async {
    final auth = await launch(tester);
    await tapText(tester, 'Tambah Experience');
    expect(find.byType(ExperienceFormPage), findsOneWidget);
    expect(auth.isLoggedIn, isFalse);
    expect(find.byType(LoginPage), findsNothing);
  });

  for (final width in [320.0, 1280.0]) {
    testWidgets('Login fits 200 percent text and keyboard at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await launch(tester);
      await tapText(tester, 'Login');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await credentials(tester);
      await tester.ensureVisible(loginSubmit());
      await tester.pumpAndSettle();
      expect(loginSubmit().hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(loginSubmit());
      await tester.pumpAndSettle();
      expect(find.text('Logout'), findsOneWidget);
    });
  }
}
