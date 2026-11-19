import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/experience_data.dart';
import 'package:myportofolio_mobile/main.dart';

Finder field(String name) => find.byKey(ValueKey(name));

Future<void> openForm(WidgetTester tester, {double width = 390}) async {
  tester.view.physicalSize = Size(width, 844);
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

Future<void> setCompleted(WidgetTester tester) async {
  await tester.ensureVisible(find.byType(SwitchListTile));
  await tester.tap(find.byType(SwitchListTile));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty and whitespace-only required fields are rejected', (
    tester,
  ) async {
    await openForm(tester);
    await save(tester);
    expect(find.text('Judul wajib diisi.'), findsOneWidget);
    expect(find.text('Deskripsi wajib diisi.'), findsOneWidget);
    expect(find.text('Pilih kategori pengalaman.'), findsOneWidget);
    expect(field('save_status'), findsNothing);
    // Save scrolls back to the first invalid field on a phone.
    expect(field('title').hitTestable(), findsOneWidget);

    await enter(tester, 'title', '   ');
    await enter(tester, 'description', ' \n ');
    await save(tester);
    expect(find.text('Judul wajib diisi.'), findsOneWidget);
    expect(find.text('Deskripsi wajib diisi.'), findsOneWidget);
    expect(field('save_status'), findsNothing);
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
      }
      expect(tester.takeException(), isNull);
    },
  );

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
        expect(
          find.textContaining('Data “Panitia kampus” valid'),
          findsOneWidget,
        );
        expect(find.byType(Dialog), findsNothing);
        expect(tester.takeException(), isNull);

        await enter(tester, 'description', 'Keterangan diperbarui.');
        expect(field('save_status'), findsNothing);
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
      await enter(tester, 'ended_at', '2026-05-20 10:00');
      await save(tester);
      expect(field('save_status'), findsOneWidget);

      await setCompleted(tester);
      expect(
        tester.widget<TextFormField>(field('ended_at')).controller!.text,
        isEmpty,
      );
      expect(tester.widget<TextFormField>(field('ended_at')).enabled, isFalse);
      expect(field('save_status'), findsNothing);
      await save(tester);
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
}
