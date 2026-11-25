import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/auth/auth_state.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';
import 'package:myportofolio_mobile/widgets/portfolio_background.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_button.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_panel.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _sending = false;
  bool _submitted = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthState>();
    if (_sending || auth.isBusy || !_form.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _submitted = true;
    });
    final success = await auth.login(_username.text, _password.text);
    if (!mounted) return;
    if (success) {
      _password.clear();
      Navigator.of(context).pop(true);
    } else {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final busy = _sending || auth.isBusy;
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: PortfolioBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              narrow ? 16 : 28,
              narrow ? 20 : 48,
              narrow ? 16 : 28,
              40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: PortfolioGlassPanel(
                  padding: EdgeInsets.all(narrow ? 24 : 40),
                  borderRadius: BorderRadius.circular(28),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: PortfolioColors.lavender.withValues(
                              alpha: 0.65,
                            ),
                            border: Border.all(color: Colors.white, width: 1.5),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.lock_open_rounded,
                            size: 30,
                            color: PortfolioColors.roseInk,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'YOUR PORTFOLIO',
                          style: TextStyle(
                            color: PortfolioColors.roseInk,
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Selamat datang kembali.',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: narrow ? 32 : 38,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            color: PortfolioColors.ink,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Masuk untuk melanjutkan ke Tambah Project. Anda tetap dapat menjelajahi proyek tanpa login.',
                          style: TextStyle(
                            color: PortfolioColors.ink,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          key: const ValueKey('login_username'),
                          controller: _username,
                          enabled: !busy,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Masukkan username.'
                              : null,
                        ),
                        const SizedBox(height: 22),
                        TextFormField(
                          key: const ValueKey('login_password'),
                          controller: _password,
                          enabled: !busy,
                          obscureText: true,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Masukkan password.'
                              : null,
                        ),
                        if (_submitted && auth.failure != null) ...[
                          const SizedBox(height: 22),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              auth.failure!.message,
                              key: const ValueKey('login_error'),
                              style: const TextStyle(
                                color: PortfolioColors.error,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        PortfolioGlassButton(
                          label: busy ? 'Memproses…' : 'Login',
                          icon: busy
                              ? Icons.hourglass_top_rounded
                              : Icons.login_rounded,
                          onPressed: busy ? null : _submit,
                        ),
                        if (busy) ...[
                          const SizedBox(height: 18),
                          const LinearProgressIndicator(
                            semanticsLabel: 'Memproses login',
                            color: PortfolioColors.roseInk,
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              foregroundColor: PortfolioColors.roseInk,
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sesi hanya berlaku selama aplikasi terbuka.',
                          style: TextStyle(
                            color: PortfolioColors.roseInk,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
