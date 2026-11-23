import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/project_data.dart';
import 'package:myportofolio_mobile/screens/experience_form_page.dart';
import 'package:myportofolio_mobile/screens/home_page.dart';
import 'package:myportofolio_mobile/screens/project_form_page.dart';
import 'package:myportofolio_mobile/widgets/project_summary_dialog.dart';

Finder field(String name) => find.byKey(ValueKey('project_$name'));

Future<void> launch(WidgetTester tester, {double width = 390}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MyApp());
}

Future<void> openProject(WidgetTester tester, {double width = 390}) async {
  await launch(tester, width: width);
  await tester.ensureVisible(find.text('Tambah Project'));
  await tester.tap(find.text('Tambah Project'));
  await tester.pumpAndSettle();
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
  await tester.tap(find.widgetWithText(FilledButton, 'Tutup'));
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

  testWidgets('empty and whitespace fields block the preview dialog', (
    tester,
  ) async {
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
      expect(find.text('Ringkasan Project'), findsOneWidget);
      expect(
        find.text('Preview lokal. Data ini belum dikirim ke Django.'),
        findsOneWidget,
      );
      expectSummary(tester, 'title', 'Portfolio kampus');
      expectSummary(tester, 'description', 'Menampilkan karya dan pengalaman.');
      expectSummary(tester, 'category', category.label);
      expectSummary(tester, 'role', 'Frontend developer');
      expectSummary(tester, 'skills', 'Flutter, Dart');
      await closeSummary(tester);
      expect(
        tester.widget<TextFormField>(field('title')).controller!.text,
        '  Portfolio kampus  ',
      );
      expect(
        tester.state<FormFieldState<ProjectCategory>>(field('category')).value,
        category,
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

  for (final width in [320.0, 1280.0]) {
    testWidgets('errors and long preview stay usable at 200% text, $width', (
      tester,
    ) async {
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
    });
  }
}
