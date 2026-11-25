import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/auth/auth_navigation.dart';
import 'package:myportofolio_mobile/auth/auth_state.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/models/project_data.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';
import 'package:myportofolio_mobile/widgets/portfolio_background.dart';
import 'package:myportofolio_mobile/widgets/portfolio_drawer.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_button.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_panel.dart';
import 'package:myportofolio_mobile/widgets/project_summary_dialog.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _roleController = TextEditingController();
  final _skillsController = TextEditingController();
  ProjectCategory? _category;
  bool _attemptedSave = false;
  bool _saving = false;
  bool _confirming = false;
  bool _signingIn = false;
  ApiException? _saveError;

  @override
  void dispose() {
    for (final controller in [
      _titleController,
      _descriptionController,
      _roleController,
      _skillsController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validateText(String? value, String label, {int? maxLength}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label wajib diisi.';
    if (maxLength != null && text.runes.length > maxLength) {
      return '$label maksimal $maxLength karakter.';
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving || _signingIn || _confirming) return;
    setState(() {
      _attemptedSave = true;
      _saveError = null;
    });
    final invalidFields = _formKey.currentState!.validateGranularly();
    if (invalidFields.isNotEmpty) {
      Scrollable.ensureVisible(
        invalidFields.first.context,
        alignment: 0.15,
        duration: const Duration(milliseconds: 250),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final project = Project(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category!,
      role: _roleController.text.trim(),
      skills: _skillsController.text.trim(),
    );
    setState(() => _saving = true);
    try {
      final auth = context.read<AuthState>();
      final api = context.read<ApiClient>();
      if (auth.token == null && !await ensureLoggedIn(context)) return;
      if (!mounted) return;
      final token = auth.token;
      if (token == null) return;
      final Project saved;
      try {
        saved = await api.createProject(project, token);
      } on ApiException catch (error) {
        if (error.kind == ApiFailureKind.invalidToken) {
          auth.invalidateSession(token);
        }
        if (mounted) setState(() => _saveError = error);
        return;
      }
      if (!mounted) return;
      _clearSavedFields();
      final openList = await showDialog<bool>(
        context: context,
        builder: (_) => ProjectSummaryDialog(project: saved),
      );
      if (mounted && openList == true) {
        await openPortfolioDestination(context, PortfolioDestination.projects);
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          _confirming = false;
        });
      }
    }
  }

  void _clearSavedFields() {
    _formKey.currentState!.reset();
    _titleController.clear();
    _descriptionController.clear();
    _roleController.clear();
    _skillsController.clear();
    setState(() {
      _category = null;
      _attemptedSave = false;
      _saving = false;
      _confirming = true;
    });
  }

  Future<void> _loginAgain() async {
    if (_saving || _signingIn) return;
    setState(() => _signingIn = true);
    try {
      final signedIn = await ensureLoggedIn(context);
      if (mounted && signedIn) setState(() => _saveError = null);
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  Widget _shortTextField({
    required String name,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextFormField(
      key: ValueKey('project_$name'),
      controller: controller,
      enabled: !_saving,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: textInputAction,
      onFieldSubmitted: textInputAction == TextInputAction.done
          ? (_) => _save()
          : null,
      decoration: InputDecoration(
        labelText: '$label *',
        hintText: hint,
        helperText: 'Maksimal 255 karakter.',
      ),
      validator: (value) => _validateText(value, label, maxLength: 255),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    final page = Scaffold(
      drawerEnableOpenDragGesture: !_saving,
      drawer: _saving
          ? null
          : const PortfolioDrawer(
              currentDestination: PortfolioDestination.project,
            ),
      appBar: AppBar(
        leading: const BackButton(),
        actions: [if (!_saving) const DrawerButton()],
        title: const Text('Tambah Project'),
        titleTextStyle: const TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: PortfolioColors.ink,
        ),
        toolbarHeight: isNarrow ? 72 : 88,
      ),
      body: PortfolioBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              isNarrow ? 16 : 28,
              isNarrow ? 16 : 24,
              isNarrow ? 16 : 28,
              40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: PortfolioGlassPanel(
                  padding: EdgeInsets.all(isNarrow ? 20 : 40),
                  borderRadius: BorderRadius.circular(isNarrow ? 25 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: PortfolioColors.yellow,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white),
                        ),
                        child: const Icon(
                          Icons.add_to_photos_outlined,
                          color: Color(0xFF765621),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Setiap proyek berawal dari ide.',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: isNarrow ? 30 : 40,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: PortfolioColors.ink,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ceritakan proyek, peran, dan keahlianmu. '
                        'Semua kolom bertanda * wajib diisi.',
                        style: TextStyle(
                          color: PortfolioColors.muted,
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        autovalidateMode: _attemptedSave
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _shortTextField(
                              name: 'title',
                              label: 'Judul',
                              hint: 'Contoh: Portfolio pribadi',
                              controller: _titleController,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              key: const ValueKey('project_description'),
                              controller: _descriptionController,
                              enabled: !_saving,
                              minLines: 4,
                              maxLines: 8,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                labelText: 'Deskripsi *',
                                alignLabelWithHint: true,
                                hintText: 'Apa yang dibuat dan apa tujuannya?',
                              ),
                              validator: (value) =>
                                  _validateText(value, 'Deskripsi'),
                            ),
                            const SizedBox(height: 24),
                            DropdownButtonFormField<ProjectCategory>(
                              key: const ValueKey('project_category'),
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Kategori *',
                              ),
                              items: [
                                for (final category in ProjectCategory.values)
                                  DropdownMenuItem(
                                    value: category,
                                    child: Text(category.label),
                                  ),
                              ],
                              onChanged: _saving
                                  ? null
                                  : (value) =>
                                        setState(() => _category = value),
                              validator: (value) => value == null
                                  ? 'Pilih kategori proyek.'
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            _shortTextField(
                              name: 'role',
                              label: 'Peran',
                              hint: 'Contoh: Frontend developer',
                              controller: _roleController,
                            ),
                            const SizedBox(height: 24),
                            _shortTextField(
                              name: 'skills',
                              label: 'Keahlian',
                              hint: 'Contoh: Flutter, Dart, UI design',
                              controller: _skillsController,
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 32),
                            if (_saveError case final error?) ...[
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  error.message,
                                  key: const ValueKey('project_save_error'),
                                  style: const TextStyle(
                                    color: PortfolioColors.error,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (error.kind == ApiFailureKind.invalidToken)
                                TextButton(
                                  onPressed: _signingIn ? null : _loginAgain,
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(48, 48),
                                    foregroundColor: PortfolioColors.roseInk,
                                  ),
                                  child: const Text('Login ulang'),
                                ),
                              const SizedBox(height: 16),
                            ],
                            PortfolioGlassButton(
                              label: _saving ? 'Menyimpan…' : 'Save',
                              icon: _saving
                                  ? Icons.hourglass_top_rounded
                                  : Icons.check_rounded,
                              onPressed: _saving || _signingIn || _confirming
                                  ? null
                                  : _save,
                            ),
                            if (_saving) ...[
                              const SizedBox(height: 14),
                              const LinearProgressIndicator(
                                color: PortfolioColors.roseInk,
                                semanticsLabel: 'Menyimpan proyek',
                              ),
                            ],
                          ],
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
    );
    return PopScope(canPop: !_saving, child: page);
  }
}
