import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/home_page.dart';
import 'package:myportofolio_mobile/screens/project_detail_page.dart';
import 'package:myportofolio_mobile/screens/project_list_page.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/portfolio_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:myportofolio_mobile/widgets/project_thumbnail.dart';

const projectJson = {
  'id': '26c530b1-5de2-4279-a3b4-719c3972797f',
  'title': 'Portfolio dari backend',
  'description': 'Cerita lengkap proyek nyata.',
  'category': 'web',
  'role': 'Developer',
  'skills': 'Django, Flutter',
  'thumbnail': '',
  'project_url': 'https://example.com/work',
  'is_featured': true,
  'star_count': 7,
  'is_starred': false,
  'starred_by_names': 'reader, owner',
};

http.Response projectsResponse(List<Map<String, Object?>> projects) =>
    http.Response.bytes(utf8.encode(jsonEncode(projects)), 200);

ApiClient makeClient(Future<http.Response> Function(http.Request) handler) {
  final httpClient = MockClient(handler);
  addTearDown(httpClient.close);
  return ApiClient(client: httpClient);
}

Widget listApp(ApiClient client) => MaterialApp(
  theme: ThemeData(fontFamily: 'DM Sans'),
  home: ProjectListPage(apiClient: client),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

  testWidgets(
    'loading waits for GET and rebuild does not create another future',
    (tester) async {
      final pending = Completer<http.Response>();
      var calls = 0;
      final client = makeClient((_) {
        calls++;
        return pending.future;
      });
      await tester.pumpWidget(listApp(client));
      expect(find.text('Memuat proyek…'), findsOneWidget);
      await tester.pumpWidget(listApp(client));
      await tester.pump();
      expect(calls, 1);
      pending.complete(projectsResponse([]));
      await tester.pumpAndSettle();
      expect(find.text('Belum ada proyek'), findsOneWidget);
    },
  );

  testWidgets('empty list can pull to refresh and display new backend data', (
    tester,
  ) async {
    var calls = 0;
    final client = makeClient(
      (_) async => projectsResponse(++calls == 1 ? [] : [projectJson]),
    );
    await tester.pumpWidget(listApp(client));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada proyek'), findsOneWidget);
    expect(find.byType(ProjectCard), findsNothing);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 420));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Portfolio dari backend'), findsOneWidget);
  });

  testWidgets('HTTP error is safe and retry replaces it with a real list', (
    tester,
  ) async {
    var calls = 0;
    final client = makeClient(
      (_) async => ++calls == 1
          ? http.Response('<html>Secret traceback</html>', 500)
          : projectsResponse([projectJson]),
    );
    await tester.pumpWidget(listApp(client));
    await tester.pumpAndSettle();
    expect(find.text('Belum bisa memuat proyek'), findsOneWidget);
    expect(find.textContaining('Secret'), findsNothing);
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byType(ProjectCard), findsOneWidget);
  });

  testWidgets('refresh failure finishes the indicator and allows retry', (
    tester,
  ) async {
    var calls = 0;
    final client = makeClient((_) async {
      calls++;
      if (calls == 2) throw http.ClientException('private connection detail');
      return projectsResponse(calls == 1 ? [] : [projectJson]);
    });
    await tester.pumpWidget(listApp(client));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 420));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.textContaining('Periksa koneksi'), findsOneWidget);
    expect(find.byType(RefreshProgressIndicator), findsNothing);
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();
    expect(calls, 3);
    expect(find.byType(ProjectCard), findsOneWidget);
  });

  testWidgets('populated list refresh replaces the previous response', (
    tester,
  ) async {
    var calls = 0;
    final client = makeClient(
      (_) async => projectsResponse([
        {
          ...projectJson,
          'title': ++calls == 1 ? 'Versi pertama' : 'Versi terbaru',
        },
      ]),
    );
    await tester.pumpWidget(listApp(client));
    await tester.pumpAndSettle();
    expect(find.text('Versi pertama'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 420));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Versi terbaru'), findsOneWidget);
    expect(find.text('Versi pertama'), findsNothing);
  });

  testWidgets('list opens full detail and Back retains the fetched list', (
    tester,
  ) async {
    var calls = 0;
    final client = makeClient((_) async {
      calls++;
      return projectsResponse([projectJson]);
    });
    await tester.pumpWidget(listApp(client));
    await tester.pumpAndSettle();
    expect(find.text('Web Development'), findsOneWidget);
    await tester.ensureVisible(find.text('Lihat detail'));
    await tester.tap(find.text('Lihat detail'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectDetailPage), findsOneWidget);
    expect(find.text('Cerita lengkap proyek nyata.'), findsOneWidget);
    expect(find.text('Django, Flutter'), findsOneWidget);
    expect(find.text('reader, owner'), findsOneWidget);
    expect(find.text('7 bintang'), findsOneWidget);
    expect(find.text('https://example.com/work'), findsOneWidget);
    expect(find.text(projectJson['id'] as String), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ProjectListPage), findsOneWidget);
    expect(calls, 1);
  });

  testWidgets('Home action and drawer navigate without duplicating Home', (
    tester,
  ) async {
    final client = makeClient((_) async => projectsResponse([]));
    await tester.pumpWidget(MyApp(apiClient: client));
    final originalHome = tester.element(find.byType(MyHomePage));
    await tester.ensureVisible(find.text('Lihat Proyek'));
    await tester.tap(find.text('Lihat Proyek'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectListPage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(tester.element(find.byType(MyHomePage)), same(originalHome));
    await tester.tap(find.byType(DrawerButton));
    await tester.pumpAndSettle();
    final destination = find.widgetWithText(ListTile, 'Lihat Proyek');
    await tester.ensureVisible(destination);
    await tester.pumpAndSettle();
    await tester.tap(destination);
    await tester.pumpAndSettle();
    expect(find.byType(ProjectListPage), findsOneWidget);
    await tester.tap(find.byTooltip('Buka navigasi'));
    await tester.pumpAndSettle();
    expect(tester.widget<ListTile>(destination).selected, isTrue);
    await tester.tap(destination);
    await tester.pumpAndSettle();
    expect(find.byType(PortfolioDrawer), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(tester.element(find.byType(MyHomePage)), same(originalHome));
  });

  testWidgets('detail opens an HTTP link and handles launcher failure safely', (
    tester,
  ) async {
    Uri? opened;
    await tester.pumpWidget(
      MaterialApp(
        home: ProjectDetailPage(
          project: Project.fromJson(projectJson),
          openUrl: (uri) async {
            opened = uri;
            return false;
          },
        ),
      ),
    );
    await tester.ensureVisible(find.text('Kunjungi proyek'));
    await tester.tap(find.text('Kunjungi proyek'));
    await tester.pumpAndSettle();
    expect(opened, Uri.parse('https://example.com/work'));
    expect(
      find.text('Tautan belum dapat dibuka. Silakan coba lagi.'),
      findsOneWidget,
    );
  });

  testWidgets('missing and failed thumbnail URLs display a fallback', (
    tester,
  ) async {
    for (final url in ['', 'https://example.invalid/missing.png']) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: ProjectThumbnail(url: url, title: 'Karya'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.layers_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('detail excludes unsafe links and internal identifiers', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProjectDetailPage(
          project: Project.fromJson({
            ...projectJson,
            'project_url': 'javascript:alert(1)',
          }),
        ),
      ),
    );
    expect(find.text('Kunjungi proyek'), findsNothing);
    expect(find.textContaining('javascript'), findsNothing);
    expect(find.text(projectJson['id'] as String), findsNothing);
  });

  for (final width in [320.0, 1280.0]) {
    testWidgets('list and detail support long text at 200% and width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final client = makeClient(
        (_) async => projectsResponse([
          {
            ...projectJson,
            'title': 'Judul karya yang panjang dan tetap terbaca ' * 4,
            'description':
                'Deskripsi lengkap dengan banyak cerita dan pengalaman. ' * 20,
            'role': 'Perancang dan pengembang antarmuka',
          },
        ]),
      );
      await tester.pumpWidget(listApp(client));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('Lihat detail'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      for (
        var attempt = 0;
        attempt < 12 &&
            find.text('Lihat detail').hitTestable().evaluate().isEmpty;
        attempt++
      ) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Lihat detail'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectDetailPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('project card has hover, keyboard focus, and pressed feedback', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectCard(
              project: Project.fromJson(projectJson),
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(1, 1));
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Lihat detail')));
    await tester.pumpAndSettle();
    final ink = tester.widget<InkWell>(find.byType(InkWell));
    expect(ink.statesController!.value, contains(WidgetState.hovered));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(ink.statesController!.value, contains(WidgetState.focused));
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Lihat detail')),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      lessThan(1),
    );
    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 1);
  });
}
