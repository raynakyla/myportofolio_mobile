import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/auth/auth_state.dart';
import 'package:myportofolio_mobile/screens/login_page.dart';
import 'package:provider/provider.dart';

Future<bool> ensureLoggedIn(BuildContext context) async {
  final auth = context.read<AuthState>();
  if (auth.isLoggedIn) return true;
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      settings: const RouteSettings(name: '/login'),
      builder: (_) => const LoginPage(),
    ),
  );
  if (result != true) auth.cancelLogin();
  return context.mounted && result == true && auth.isLoggedIn;
}

Future<void> logoutAndReturnHome(BuildContext context) async {
  final auth = context.read<AuthState>();
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  await auth.logout();
  if (!context.mounted) return;
  navigator.popUntil((route) => route.isFirst);
  messenger
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          auth.failure == null ? 'Anda sudah keluar.' : 'Anda sudah keluar dari aplikasi. Pencabutan sesi server belum berhasil.',
        ),
      ),
    );
}
