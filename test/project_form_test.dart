import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/auth/auth_state.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/project_data.dart';
import 'package:myportofolio_mobile/screens/experience_form_page.dart';
import 'package:myportofolio_mobile/screens/home_page.dart';
import 'package:myportofolio_mobile/screens/login_page.dart';
import 'package:myportofolio_mobile/screens/project_form_page.dart';
import 'package:myportofolio_mobile/screens/project_list_page.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/project_summary_dialog.dart';

import 'support/auth_test_support.dart';

Finder field(String name) => find.byKey(ValueKey('project_$name'));

http.Response savedResponse(http.Request request, {String? title}) {
  final input = jsonDecode(request.body) as Map<String, dynamic>;
  return http.Response.bytes(
    utf8.encode(
      jsonEncode({
        ...input,
        'id': '57336b4c-d7fe-4ae3-9c02-65d772eb8526',
        'title': ?title,
      }),
    ),
    201,
  );
}

Future<AuthState> launch(
  WidgetTester tester, {
  double width = 390,
  Future<http.Response> Function(http.Request)? handleProject,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final token = sessionTestToken();
  final client = MockClient((request) async {
    if (request.url.path.endsWith('/auth/token/')) return tokenResponse(token);
    if (handleProject != null) return handleProject(request);
    expect(request.method, 'POST');
    return savedResponse(request);
  });
  addTearDown(client.close);
  final api = ApiClient(client: client);
  final auth = AuthState(api);
  addTearDown(auth.dispose);
  expect(await auth.login('test-owner', sessionTestToken()), isTrue);
  await tester.pumpWidget(MyApp(apiClient: api, authState: auth));
  return auth;
}

Future<AuthState> openProject(
  WidgetTester tester, {
  double width = 390,
  Future<http.Response> Function(http.Request)? handleProject,
}) async {
  final auth = await launch(tester, width: width, handleProject: handleProject);
  await tester.ensureVisible(find.text('Tambah Project'));
  await tester.tap(find.text('Tambah Project'));
  await tester.pumpAndSettle();
  return auth;
}

Future<void> selectDrawer(WidgetTester tester, String label) async {
  await tester.tap(find.byType(DrawerButton));
  await tester.pumpAndSettle();
  final tile = find.widgetWithText(ListTile, label);
  await tester.ensureVisible(tile);
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

Future<void> enter(WidgetTester tester, String name, String text) async {
  await tester.ensureVisible(field(name));
  await tester.enterText(field(name), text);
  await tester.pump();
}

Future<void> fillRequired(
  WidgetTester tester, {
  String categoryLabel = 'Web Development',
}) async {
  await enter(tester, 'title', '  Portfolio kampus  ');
  await enter(tester, 'description', '  Menampilkan karya dan pengalaman.  ');
  await enter(tester, 'role', '  Frontend developer  ');
  await enter(tester, 'skills', '  Flutter, Dart  ');
  await tester.ensureVisible(field('category'));
  await tester.tap(field('category'));
  await tester.pumpAndSettle();
  for (final label in ['Web Development', 'Product & UX', 'Creative Work']) {
    expect(find.text(label).last, findsOneWidget);
  }
  expect(find.text('Career'), findsNothing);
  await tester.tap(find.text(categoryLabel).last);
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

Future<void> closeSummary(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(TextButton, 'Tutup'));
  await tester.pumpAndSettle();
  expect(find.byType(AlertDialog), findsNothing);
}

void expectSummary(WidgetTester tester, String name, String value) {
  final text = find.byKey(ValueKey('project_summary_$name'));
  expect(tester.widget<Text>(text).data, value);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry in {
      'DM Sans': ['assets/fonts/dm_sans/DMSans-Variable.ttf'],
      'Playfair Display': [
        'assets/fonts/playfair_display/PlayfairDisplay-Variable.ttf',
        'assets/fonts/playfair_display/PlayfairDisplay-Italic-Variable.ttf',
      ],
    }.entries) {
      final loader = FontLoader(entry.key);
      for (final asset in entry.value) {
        loader.addFont(rootBundle.load(asset));
      }
      await loader.load();
    }
  });

  for (final width in [390.0, 1280.0]) {
    testWidgets('Home opens Project and Back reuses Home at $width', (
      tester,
    ) async {
      await launch(tester, width: width);
      final home = tester.element(find.byType(MyHomePage));
      expect(find.text('Tambah Experience'), findsOneWidget);
      await tester.ensureVisible(find.text('Tambah Project'));
      await tester.tap(find.text('Tambah Project'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(tester.element(find.byType(MyHomePage)), same(home));
      expect(find.byType(ProjectFormPage, skipOffstage: false), findsNothing);
      expect(
        tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('drawer opens both forms without duplicate routes at $width', (
      tester,
    ) async {
      await launch(tester, width: width);
      final home = tester.element(find.byType(MyHomePage));
      for (var cycle = 0; cycle < 2; cycle++) {
        await selectDrawer(tester, 'Tambah Project');
        final project = tester.element(find.byType(ProjectFormPage));
        await enter(tester, 'title', 'Judul tetap ada');
        await selectDrawer(tester, 'Tambah Project');
        expect(tester.element(find.byType(ProjectFormPage)), same(project));
        expect(
          tester.widget<TextFormField>(field('title')).controller!.text,
          'Judul tetap ada',
        );
        expect(
          tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
          isFalse,
        );

        await selectDrawer(tester, 'Tambah Experience');
        expect(find.byType(ExperienceFormPage), findsOneWidget);
        expect(find.byType(ProjectFormPage, skipOffstage: false), findsNothing);
        await selectDrawer(tester, 'Tambah Project');
        expect(
          find.byType(ProjectFormPage, skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.byType(ExperienceFormPage, skipOffstage: false),
          findsNothing,
        );
        expect(find.byType(MyHomePage, skipOffstage: false), findsOneWidget);

        await selectDrawer(tester, 'Home');
        expect(tester.element(find.byType(MyHomePage)), same(home));
        expect(
          tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
          isFalse,
        );
      }
      await selectDrawer(tester, 'Tambah Project');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(tester.element(find.byType(MyHomePage)), same(home));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('empty and whitespace fields prevent saving', (tester) async {
    await openProject(tester);
    for (final whitespace in ['', ' \n ']) {
      if (whitespace.isNotEmpty) {
        for (final name in ['title', 'description', 'role', 'skills']) {
          await enter(tester, name, whitespace);
        }
      }
      await save(tester);
      for (final label in ['Judul', 'Deskripsi', 'Peran', 'Keahlian']) {
        expect(find.text('$label wajib diisi.'), findsOneWidget);
      }
      expect(find.text('Pilih kategori proyek.'), findsOneWidget);
      expect(field('title').hitTestable(), findsOneWidget);
      expect(find.byType(ProjectSummaryDialog), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Django CharField limits block long title, role, and skills', (
    tester,
  ) async {
    await openProject(tester);
    await fillRequired(tester);
    for (final name in ['title', 'role', 'skills']) {
      await enter(tester, name, 'x' * 256);
    }
    await save(tester);
    for (final label in ['Judul', 'Peran', 'Keahlian']) {
      expect(find.text('$label maksimal 255 karakter.'), findsOneWidget);
    }
    expect(find.byType(AlertDialog), findsNothing);
    // Django counts Unicode characters, not UTF-16 code units.
    for (final name in ['title', 'role', 'skills']) {
      await enter(tester, name, '🌸' * 255);
    }
    await save(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    expectSummary(tester, 'title', '🌸' * 255);
    await closeSummary(tester);
    expect(tester.takeException(), isNull);
  });

  for (final category in ProjectCategory.values) {
    testWidgets('valid ${category.value} input shows all entered values', (
      tester,
    ) async {
      await openProject(tester);
      await fillRequired(tester, categoryLabel: category.label);
      await save(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Proyek tersimpan'), findsOneWidget);
      expectSummary(tester, 'title', 'Portfolio kampus');
      expectSummary(tester, 'description', 'Menampilkan karya dan pengalaman.');
      expectSummary(tester, 'category', category.label);
      expectSummary(tester, 'role', 'Frontend developer');
      expectSummary(tester, 'skills', 'Flutter, Dart');
      await closeSummary(tester);
      expect(
        tester.widget<TextFormField>(field('title')).controller!.text,
        isEmpty,
      );
      expect(
        tester.state<FormFieldState<ProjectCategory>>(field('category')).value,
        isNull,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Save remains reachable with the keyboard open', (tester) async {
    await openProject(tester);
    await fillRequired(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'));
    expect(find.text('Save').hitTestable(), findsOneWidget);
    await save(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Tutup').hitTestable(), findsOneWidget);
    await closeSummary(tester);
    expect(tester.takeException(), isNull);
  });

  void expectRetained(WidgetTester tester) {
    for (final entry in {
      'title': '  Portfolio kampus  ',
      'description': '  Menampilkan karya dan pengalaman.  ',
      'role': '  Frontend developer  ',
      'skills': '  Flutter, Dart  ',
    }.entries) {
      expect(
        tester.widget<TextFormField>(field(entry.key)).controller!.text,
        entry.value,
      );
    }
    expect(
      tester.state<FormFieldState<ProjectCategory>>(field('category')).value,
      ProjectCategory.web,
    );
  }

  Future<void> completeLogin(WidgetTester tester) async {
    final username = find.byKey(const ValueKey('login_username'));
    final password = find.byKey(const ValueKey('login_password'));
    await tester.ensureVisible(username);
    await tester.enterText(username, 'test-owner');
    await tester.ensureVisible(password);
    await tester.enterText(password, sessionTestToken());
    final login = find.widgetWithText(FilledButton, 'Login');
    await tester.ensureVisible(login);
    await tester.tap(login);
    await tester.pumpAndSettle();
  }

  testWidgets('confirmed Save uses server data and loads a fresh list', (
    tester,
  ) async {
    final methods = <String>[];
    late http.Response saved;
    await launch(
      tester,
      handleProject: (request) async {
        methods.add(request.method);
        if (request.method == 'POST') {
          saved = savedResponse(request, title: 'Judul dari Django');
          return saved;
        }
        return http.Response.bytes(
          methods.length == 1
              ? utf8.encode('[]')
              : utf8.encode('[${utf8.decode(saved.bodyBytes)}]'),
          200,
        );
      },
    );
    await tester.ensureVisible(find.text('Lihat Proyek'));
    await tester.tap(find.text('Lihat Proyek'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada proyek'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Tambah Project'));
    await tester.tap(find.text('Tambah Project'));
    await tester.pumpAndSettle();
    await fillRequired(tester);
    await save(tester);
    expectSummary(tester, 'title', 'Judul dari Django');
    await tester.tap(find.text('Lihat daftar proyek'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectListPage), findsOneWidget);
    expect(find.text('Judul dari Django'), findsOneWidget);
    expect(methods, ['GET', 'POST', 'GET']);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage, skipOffstage: false), findsNothing);
    expect(methods, ['GET', 'POST', 'GET']);
  });

  testWidgets(
    'Save after session loss preserves the draft if login is cancelled',
    (tester) async {
      var posts = 0;
      final auth = await openProject(
        tester,
        handleProject: (request) async {
          posts++;
          return savedResponse(request);
        },
      );
      await fillRequired(tester);
      auth.invalidateSession(auth.token!);
      await save(tester);
      expect(find.byType(LoginPage), findsOneWidget);
      await tester.ensureVisible(find.text('Batal'));
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(posts, 0);
      expectRetained(tester);
      expect(find.byType(ProjectSummaryDialog), findsNothing);
      await save(tester);
      await completeLogin(tester);
      expect(posts, 1);
      expect(find.byType(ProjectSummaryDialog), findsOneWidget);
    },
  );

  testWidgets(
    'pending Save disables duplicate submissions and Back; closing success clears input',
    (tester) async {
      var posts = 0;
      final response = Completer<http.Response>();
      late http.Request sent;
      await openProject(
        tester,
        handleProject: (request) {
          sent = request;
          posts++;
          return response.future;
        },
      );
      await fillRequired(tester);
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump();
      final busy = find.widgetWithText(FilledButton, 'Menyimpan…');
      expect(tester.widget<FilledButton>(busy).onPressed, isNull);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(posts, 1);
      response.complete(savedResponse(sent));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectSummaryDialog), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ProjectSummaryDialog), findsNothing);
      await save(tester);
      expect(posts, 1);
      expect(find.text('Judul wajib diisi.'), findsOneWidget);
    },
  );

  for (final (kind, status, body) in [
    (ApiFailureKind.validation, 400, '{"title":["INTERNAL"]}'),
    (
      ApiFailureKind.forbidden,
      403,
      '{"detail":"You do not have permission to perform this action."}',
    ),
    (ApiFailureKind.connection, 0, 'INTERNAL'),
  ]) {
    testWidgets(
      '${kind.name} preserves session, input and shows a safe message',
      (tester) async {
        final auth = await openProject(
          tester,
          handleProject: (_) async {
            if (status == 0) throw http.ClientException(body);
            return http.Response(body, status);
          },
        );
        await fillRequired(tester);
        await save(tester);
        final error = tester.widget<Text>(field('save_error')).data;
        expect(
          error,
          ApiException(kind, operation: ApiOperation.createProject).message,
        );
        expect(error, isNot(contains('INTERNAL')));
        expect(find.byType(ProjectSummaryDialog), findsNothing);
        expect(find.byType(LoginPage), findsNothing);
        expect(auth.isLoggedIn, isTrue);
        expectRetained(tester);
      },
    );
  }

  for (final (status, body) in [
    (401, '{}'),
    (403, '{"detail":"Invalid token."}'),
  ]) {
    testWidgets(
      '$status invalidates local session and re-login never resubmits on its own',
      (tester) async {
        final methods = <String>[];
        final auth = await openProject(
          tester,
          handleProject: (request) async {
            methods.add('${request.method} ${request.url.path}');
            if (methods.length == 1) return http.Response(body, status);
            return savedResponse(request);
          },
        );
        await fillRequired(tester);
        await save(tester);
        expect(auth.isLoggedIn, isFalse);
        expectRetained(tester);
        expect(methods, ['POST /api/v1/projects/']);
        await tester.ensureVisible(find.text('Login ulang'));
        await tester.tap(find.text('Login ulang'));
        await tester.pumpAndSettle();
        await completeLogin(tester);
        expect(auth.isLoggedIn, isTrue);
        expectRetained(tester);
        expect(methods, ['POST /api/v1/projects/']);
        await save(tester);
        expect(find.byType(ProjectSummaryDialog), findsOneWidget);
        expect(methods, List.filled(2, 'POST /api/v1/projects/'));
      },
    );
  }

  for (final width in [320.0, 1280.0]) {
    testWidgets(
      'errors and long confirmation stay usable at 200% text, $width',
      (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await openProject(tester, width: width);
        await save(tester);
        for (final message in [
          'Judul wajib diisi.',
          'Deskripsi wajib diisi.',
          'Pilih kategori proyek.',
          'Peran wajib diisi.',
          'Keahlian wajib diisi.',
        ]) {
          final error = find.text(message);
          await tester.ensureVisible(error);
          expect(error.hitTestable(), findsOneWidget);
          expect(
            tester.renderObject<RenderParagraph>(error).didExceedMaxLines,
            isFalse,
          );
        }
        await fillRequired(tester);
        final description = List.filled(
          60,
          'Deskripsi proyek yang panjang.',
        ).join('\n');
        await enter(tester, 'description', description);
        await save(tester);
        expectSummary(tester, 'description', description);
        expect(find.text('Tutup').hitTestable(), findsOneWidget);
        final scrollable = find.descendant(
          of: field('summary_scroll'),
          matching: find.byType(Scrollable),
        );
        await tester.scrollUntilVisible(
          field('summary_skills'),
          600,
          scrollable: scrollable,
          maxScrolls: 100,
        );
        expect(field('summary_skills').hitTestable(), findsOneWidget);
        expect(find.text('Tutup').hitTestable(), findsOneWidget);
        await closeSummary(tester);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
