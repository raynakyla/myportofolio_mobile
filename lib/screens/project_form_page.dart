import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project_data.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';
import 'package:myportofolio_mobile/widgets/portfolio_background.dart';
import 'package:myportofolio_mobile/widgets/portfolio_drawer.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_button.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_panel.dart';
import 'package:myportofolio_mobile/widgets/project_summary_dialog.dart';

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

  void _save() {
    setState(() => _attemptedSave = true);
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
    final project = ProjectDraft(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category!,
      role: _roleController.text.trim(),
      skills: _skillsController.text.trim(),
    );
    showDialog<void>(
      context: context,
      builder: (_) => ProjectSummaryDialog(project: project),
    );
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

    return Scaffold(
      drawer: const PortfolioDrawer(
        currentDestination: PortfolioDestination.project,
      ),
      appBar: AppBar(
        leading: const BackButton(),
        actions: const [DrawerButton()],
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
                        'Semua kolom bertanda * wajib diisi. '
                        'Save menampilkan preview lokal; data belum dikirim ke Django.',
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
                              onChanged: (value) =>
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
                            PortfolioGlassButton(
                              label: 'Save',
                              icon: Icons.check_rounded,
                              onPressed: _save,
                            ),
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
  }
}
