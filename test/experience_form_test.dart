import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/experience_data.dart';
import 'package:myportofolio_mobile/screens/experience_form_page.dart';
import 'package:myportofolio_mobile/widgets/experience_summary_dialog.dart';

Finder field(String name) => find.byKey(ValueKey(name));

Future<void> openForm(
  WidgetTester tester, {
  double width = 390,
  double height = 844,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const MyApp());
  await tester.ensureVisible(find.text('Tambah Experience'));
  await tester.tap(find.text('Tambah Experience'));
  await tester.pumpAndSettle();
}

Future<void> enter(WidgetTester tester, String name, String text) async {
  await tester.ensureVisible(field(name));
  await tester.enterText(field(name), text);
  await tester.pump();
}

Future<void> chooseCategory(WidgetTester tester) async {
  await tester.ensureVisible(field('category'));
  await tester.tap(field('category'));
  await tester.pumpAndSettle();
  // The options come from Experience.EXPERIENCE_CHOICES, not Project categories.
  for (final category in ExperienceCategory.values) {
    expect(find.text(category.label).last, findsOneWidget);
  }
  await tester.tap(find.text('Community').last);
  await tester.pumpAndSettle();
}

Future<void> fillRequired(WidgetTester tester) async {
  await enter(tester, 'title', '  Panitia kampus  ');
  await enter(
    tester,
    'description',
    '  Menyelenggarakan kegiatan komunitas.  ',
  );
  await chooseCategory(tester);
}

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void expectSummary(WidgetTester tester, String name, String value) {
  expect(tester.widget<Text>(field('summary_$name')).data, value);
}

Future<void> closeSummary(WidgetTester tester) async {
  expect(find.byType(AlertDialog), findsOneWidget);
  final form = tester.element(find.byType(ExperienceFormPage));
  await tester.tap(find.widgetWithText(FilledButton, 'Tutup'));
  await tester.pumpAndSettle();
  expect(find.byType(AlertDialog), findsNothing);
  expect(find.byType(ExperienceSummaryDialog), findsNothing);
  expect(tester.element(find.byType(ExperienceFormPage)), same(form));
}

Future<void> setCompleted(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(SwitchListTile));
  await tester.tap(find.byType(SwitchListTile));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Use the bundled fonts for responsive layout checks, as widget_test does.
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

  testWidgets('empty and whitespace-only required fields are rejected', (
    tester,
  ) async {
    await openForm(tester);
    await save(tester);
    expect(find.text('Judul wajib diisi.'), findsOneWidget);
    expect(find.text('Deskripsi wajib diisi.'), findsOneWidget);
    expect(find.text('Pilih kategori pengalaman.'), findsOneWidget);
    expect(field('save_status'), findsNothing);
    expect(find.byType(ExperienceSummaryDialog), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    // Save scrolls back to the first invalid field on a phone.
    expect(field('title').hitTestable(), findsOneWidget);

    await enter(tester, 'title', '   ');
    await enter(tester, 'description', ' \n ');
    await save(tester);
    expect(find.text('Judul wajib diisi.'), findsOneWidget);
    expect(find.text('Deskripsi wajib diisi.'), findsOneWidget);
    expect(field('save_status'), findsNothing);
    expect(find.byType(ExperienceSummaryDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'rejects a title over the Django limit and invalid optional URLs',
    (tester) async {
      await openForm(tester);
      await fillRequired(tester);
      await enter(tester, 'title', 'x' * 256);
      for (final url in [
        'bukan-url',
        'javascript:alert(1)',
        'https://',
        'https://exa mple.com',
        'https://example..com',
        'https://-example.com',
        'https://999.999.999.999',
        'https://example.com:99999',
        'https://example.com/${'x' * 200}',
      ]) {
        await enter(tester, 'thumbnail', url);
        await save(tester);
        expect(find.text('Judul maksimal 255 karakter.'), findsOneWidget);
        expect(find.textContaining('Gunakan URL http://'), findsOneWidget);
        expect(field('save_status'), findsNothing);
        expect(find.byType(ExperienceSummaryDialog), findsNothing);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Save reaches the first remaining error and edits revalidate', (
    tester,
  ) async {
    await openForm(tester);
    await fillRequired(tester);
    await enter(tester, 'thumbnail', 'bukan-url');
    await enter(tester, 'started_at', '2026-02-30 10:00');
    // Errors appear after the first Save attempt, then update on edits.
    expect(find.textContaining('Gunakan URL http://'), findsNothing);
    await save(tester);
    expect(field('thumbnail').hitTestable(), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await enter(tester, 'thumbnail', 'https://example.com/photo.jpg');
    await tester.pumpAndSettle();
    expect(find.textContaining('Gunakan URL http://'), findsNothing);
    await save(tester);
    expect(field('started_at').hitTestable(), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await enter(tester, 'started_at', '2026-05-20 10:00');
    await tester.pumpAndSettle();
    expect(
      find.text('Gunakan tanggal valid: YYYY-MM-DD HH:mm (UTC).'),
      findsNothing,
    );

    await setCompleted(tester);
    expect(
      find.text('Isi tanggal akhir atau aktifkan Masih berlangsung.'),
      findsOneWidget,
    );
    await enter(tester, 'ended_at', '2026-05-19 10:00');
    expect(
      find.text('Tanggal akhir tidak boleh sebelum tanggal mulai.'),
      findsOneWidget,
    );
    await setCompleted(tester);
    expect(
      find.text('Tanggal akhir tidak boleh sebelum tanggal mulai.'),
      findsNothing,
    );
    await save(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    await closeSummary(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'rejects impossible dates, reversed dates, and missing end for completed work',
    (tester) async {
      await openForm(tester);
      await fillRequired(tester);
      await enter(tester, 'started_at', '2026-02-30 10:00');
      await save(tester);
      expect(
        find.text('Gunakan tanggal valid: YYYY-MM-DD HH:mm (UTC).'),
        findsOneWidget,
      );
      expect(field('save_status'), findsNothing);
      expect(find.byType(ExperienceSummaryDialog), findsNothing);

      await enter(tester, 'started_at', '2026-05-20 10:00');
      await setCompleted(tester);
      await save(tester);
      expect(
        find.text('Isi tanggal akhir atau aktifkan Masih berlangsung.'),
        findsOneWidget,
      );
      await enter(tester, 'ended_at', '2026-05-19 10:00');
      await save(tester);
      expect(
        find.text('Tanggal akhir tidak boleh sebelum tanggal mulai.'),
        findsOneWidget,
      );
      expect(field('save_status'), findsNothing);
      expect(find.byType(ExperienceSummaryDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [390.0, 1280.0]) {
    testWidgets(
      'valid ongoing experience allows empty optional fields at $width',
      (tester) async {
        await openForm(tester, width: width);
        await fillRequired(tester);
        expect(
          tester.widget<TextFormField>(field('ended_at')).enabled,
          isFalse,
        );
        await save(tester);
        expect(find.text('Ringkasan Experience'), findsOneWidget);
        expectSummary(tester, 'title', 'Panitia kampus');
        expectSummary(
          tester,
          'description',
          'Menyelenggarakan kegiatan komunitas.',
        );
        expectSummary(tester, 'category', 'Community');
        expectSummary(tester, 'thumbnail', 'Tidak diisi');
        expectSummary(tester, 'started_at', 'Tidak diisi');
        expectSummary(tester, 'is_ongoing', 'Ya');
        expectSummary(tester, 'ended_at', 'Belum berakhir — masih berlangsung');
        await closeSummary(tester);
        expect(
          find.textContaining('Data “Panitia kampus” valid'),
          findsOneWidget,
        );
        expect(
          tester.widget<TextFormField>(field('title')).controller!.text,
          '  Panitia kampus  ',
        );
        expect(
          tester.widget<TextFormField>(field('description')).controller!.text,
          '  Menyelenggarakan kegiatan komunitas.  ',
        );
        expect(
          tester
              .state<FormFieldState<ExperienceCategory>>(field('category'))
              .value,
          ExperienceCategory.community,
        );
        expect(find.text('Community'), findsOneWidget);
        expect(
          tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
          isTrue,
        );
        expect(tester.takeException(), isNull);

        await enter(tester, 'description', 'Keterangan diperbarui.');
        expect(field('save_status'), findsNothing);
        await save(tester);
        expectSummary(tester, 'description', 'Keterangan diperbarui.');
        await closeSummary(tester);
      },
    );
  }

  testWidgets(
    'valid completed dates can become ongoing and stale end dates are cleared',
    (tester) async {
      await openForm(tester);
      await fillRequired(tester);
      await enter(tester, 'thumbnail', '  https://example.com/photo.jpg  ');
      await enter(tester, 'started_at', '2026-05-20 10:00');
      await setCompleted(tester);
      await enter(tester, 'ended_at', '2026-06-21 17:35');
      await save(tester);
      expectSummary(tester, 'thumbnail', 'https://example.com/photo.jpg');
      expectSummary(tester, 'started_at', '2026-05-20 10:00 UTC');
      expectSummary(tester, 'is_ongoing', 'Tidak');
      expectSummary(tester, 'ended_at', '2026-06-21 17:35 UTC');
      await closeSummary(tester);
      expect(
        tester.widget<TextFormField>(field('thumbnail')).controller!.text,
        '  https://example.com/photo.jpg  ',
      );
      expect(
        tester.widget<TextFormField>(field('started_at')).controller!.text,
        '2026-05-20 10:00',
      );
      expect(
        tester.widget<TextFormField>(field('ended_at')).controller!.text,
        '2026-06-21 17:35',
      );
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );
      expect(field('save_status'), findsOneWidget);

      await setCompleted(tester);
      expect(
        tester.widget<TextFormField>(field('ended_at')).controller!.text,
        isEmpty,
      );
      expect(tester.widget<TextFormField>(field('ended_at')).enabled, isFalse);
      expect(field('save_status'), findsNothing);
      await save(tester);
      expectSummary(tester, 'is_ongoing', 'Ya');
      expectSummary(tester, 'ended_at', 'Belum berakhir — masih berlangsung');
      await closeSummary(tester);
      expect(field('save_status'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'form scrolls with keyboard insets and retains input when its drawer closes',
    (tester) async {
      await openForm(tester);
      await enter(tester, 'title', 'Tetap tersimpan di form');
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save'));
      expect(find.text('Save').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(DrawerButton));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Tambah Experience'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextFormField>(field('title')).controller!.text,
        'Tetap tersimpan di form',
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [320.0, 390.0, 1280.0]) {
    testWidgets(
      'form errors remain readable at 200 percent text and width $width',
      (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await openForm(tester, width: width);
        await enter(tester, 'thumbnail', 'bukan-url');
        await save(tester);
        for (final message in [
          'Judul wajib diisi.',
          'Deskripsi wajib diisi.',
          'Pilih kategori pengalaman.',
          'Gunakan URL http:// atau https:// yang valid (maks. 200 karakter).',
        ]) {
          final error = find.text(message);
          expect(error, findsOneWidget);
          await tester.ensureVisible(error);
          expect(error.hitTestable(), findsOneWidget);
          expect(
            tester.renderObject<RenderParagraph>(error).didExceedMaxLines,
            isFalse,
          );
        }
        expect(find.byType(ExperienceSummaryDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('long summary scrolls while Close stays reachable at $width', (
      tester,
    ) async {
      await openForm(tester, width: width, height: width < 600 ? 640 : 900);
      if (width == 320) {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();
      }
      await fillRequired(tester);
      final description = List.generate(
        60,
        (index) =>
            'Paragraf $index: Mengatur kegiatan, berkolaborasi dengan tim, '
            'dan mempelajari hal baru dalam pengalaman ini.',
      ).join('\n\n');
      await enter(tester, 'description', description);
      await save(tester);
      expectSummary(tester, 'description', description);
      expect(find.text('Tutup').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);

      final scrollable = find.descendant(
        of: field('summary_scroll'),
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        field('summary_ended_at'),
        600,
        scrollable: scrollable,
        maxScrolls: 100,
      );
      await tester.pumpAndSettle();
      expect(field('summary_ended_at').hitTestable(), findsOneWidget);
      expect(find.text('Tutup').hitTestable(), findsOneWidget);
      await closeSummary(tester);
      expect(
        tester.widget<TextFormField>(field('description')).controller!.text,
        description,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Save supports keyboard focus and only submits a mouse press on release',
    (tester) async {
      await openForm(tester, width: 1280);
      await fillRequired(tester);
      await tester.ensureVisible(find.text('Save'));
      Focus.of(tester.element(find.text('Save'))).requestFocus();
      await tester.pumpAndSettle();
      expect(Focus.of(tester.element(find.text('Save'))).hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceSummaryDialog), findsOneWidget);
      await closeSummary(tester);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer();
      await mouse.moveTo(tester.getCenter(find.text('Save')));
      await tester.pumpAndSettle();
      await mouse.down(tester.getCenter(find.text('Save')));
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(ExperienceSummaryDialog), findsNothing);
      await mouse.up();
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceSummaryDialog), findsOneWidget);
      await closeSummary(tester);
      expect(tester.takeException(), isNull);
    },
  );
}
