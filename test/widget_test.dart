import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form_page.dart';
import 'package:myportofolio_mobile/screens/home_page.dart';
import 'package:myportofolio_mobile/widgets/portfolio_drawer.dart';

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
    expect(find.text('Tambah Experience'), findsOneWidget);
    expect(find.text('Tambah Project'), findsOneWidget);
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

    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pump();
    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
    expect(find.text('Kamu telah menekan tombol Lihat Proyek!'), findsNothing);
  });

  testWidgets('fits a narrow viewport without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());

    expect(tester.takeException(), isNull);
    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Experience'), findsOneWidget);
    expect(find.text('Tambah Project'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  for (final width in [320.0, 390.0]) {
    testWidgets('Home and drawer fit 200 percent text at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 740);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Tambah Experience'));
      expect(find.text('Tambah Experience').hitTestable(), findsOneWidget);

      await tester.tap(find.byType(DrawerButton));
      await tester.pumpAndSettle();
      final homeTile = find.widgetWithText(ListTile, 'Home');
      final formTile = find.widgetWithText(ListTile, 'Tambah Experience');
      expect(tester.widget<ListTile>(homeTile).selected, isTrue);
      await tester.ensureVisible(formTile);
      expect(tester.getSize(formTile).height, greaterThanOrEqualTo(64));
      expect(tester.takeException(), isNull);
      await tester.tap(formTile);
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [390.0, 1280.0]) {
    testWidgets('drawer reuses Home and keeps Back predictable at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp());

      final home = tester.element(find.byType(MyHomePage));
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      Finder drawerTile(String label) => find.descendant(
        of: find.byType(PortfolioDrawer),
        matching: find.widgetWithText(ListTile, label),
      );
      Future<void> openDrawer() async {
        await tester.tap(find.byType(DrawerButton));
        await tester.pumpAndSettle();
      }

      await openDrawer();
      expect(tester.widget<ListTile>(drawerTile('Home')).selected, isTrue);
      await tester.tap(drawerTile('Home'));
      await tester.pumpAndSettle();
      expect(
        tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
        isFalse,
      );
      expect(navigator.canPop(), isFalse);

      for (var cycle = 0; cycle < 3; cycle++) {
        await openDrawer();
        await tester.tap(drawerTile('Tambah Experience'));
        await tester.pumpAndSettle();
        final form = tester.element(find.byType(ExperienceFormPage));
        expect(navigator.canPop(), isTrue);
        expect(find.byType(MyHomePage, skipOffstage: false), findsOneWidget);
        expect(
          find.byType(ExperienceFormPage, skipOffstage: false),
          findsOneWidget,
        );

        await openDrawer();
        expect(
          tester.widget<ListTile>(drawerTile('Tambah Experience')).selected,
          isTrue,
        );
        await tester.tap(drawerTile('Tambah Experience'));
        await tester.pumpAndSettle();
        expect(tester.element(find.byType(ExperienceFormPage)), same(form));
        expect(
          tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
          isFalse,
        );

        await openDrawer();
        await tester.tap(drawerTile('Home'));
        await tester.pumpAndSettle();
        expect(tester.element(find.byType(MyHomePage)), same(home));
        expect(
          find.byType(ExperienceFormPage, skipOffstage: false),
          findsNothing,
        );
        expect(navigator.canPop(), isFalse);
      }

      await openDrawer();
      await tester.tap(drawerTile('Tambah Experience'));
      await tester.pumpAndSettle();
      await openDrawer();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(
        tester.state<ScaffoldState>(find.byType(Scaffold)).isDrawerOpen,
        isFalse,
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(tester.element(find.byType(MyHomePage)), same(home));
      expect(navigator.canPop(), isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('opens Experience and returns Home at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MyApp());
      await tester.ensureVisible(find.text('Tambah Experience'));
      await tester.tap(find.text('Tambah Experience'));
      await tester.pumpAndSettle();

      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(find.text('Tambah Experience'), findsOneWidget);
      expect(find.text('Setiap pengalaman punya cerita.'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(ExperienceFormPage), findsNothing);
      expect(find.text('Hi, I’m Vanka.'), findsOneWidget);
      expect(find.text('Tambah Experience'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
