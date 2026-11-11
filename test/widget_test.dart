import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final body = FontLoader('DM Sans')
      ..addFont(rootBundle.load('assets/fonts/dm_sans/DMSans-Variable.ttf'));
    final heading = FontLoader('Playfair Display')
      ..addFont(
        rootBundle.load(
          'assets/fonts/playfair_display/PlayfairDisplay-Variable.ttf',
        ),
      )
      ..addFont(
        rootBundle.load(
          'assets/fonts/playfair_display/PlayfairDisplay-Italic-Variable.ttf',
        ),
      );
    await Future.wait([body.load(), heading.load()]);
  });

  testWidgets('shows owner identity and all menu items', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('2506657283'), findsOneWidget);
    expect(find.text('Rayna Kayla Rayvanka'), findsWidgets);
    expect(find.text('PBP F'), findsOneWidget);
    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the selected menu item in a SnackBar', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.text('Lihat Proyek'));
    await tester.tap(find.text('Lihat Proyek'));
    await tester.pump();
    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Tambah Proyek'));
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pump();
    expect(
      find.text('Kamu telah menekan tombol Tambah Proyek!'),
      findsOneWidget,
    );
    expect(find.text('Kamu telah menekan tombol Lihat Proyek!'), findsNothing);

    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pump();
    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
    expect(find.text('Kamu telah menekan tombol Tambah Proyek!'), findsNothing);
  });

  testWidgets('fits a narrow viewport without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());

    expect(tester.takeException(), isNull);
    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });
}
