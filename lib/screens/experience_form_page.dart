import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/experience_data.dart';
import 'package:myportofolio_mobile/theme/portfolio_colors.dart';
import 'package:myportofolio_mobile/widgets/experience_summary_dialog.dart';
import 'package:myportofolio_mobile/widgets/portfolio_background.dart';
import 'package:myportofolio_mobile/widgets/portfolio_drawer.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_button.dart';
import 'package:myportofolio_mobile/widgets/portfolio_glass_panel.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  ExperienceCategory? _category;
  bool _isOngoing = true;
  bool _attemptedSave = false;
  ExperienceDraft? _savedExperience;

  @override
  void dispose() {
    for (final controller in [
      _titleController,
      _descriptionController,
      _thumbnailController,
      _startController,
      _endController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _markDirty() {
    if (_savedExperience != null) {
      setState(() => _savedExperience = null);
    }
  }

  String? _requiredText(String? value, String label) {
    return value == null || value.trim().isEmpty ? '$label wajib diisi.' : null;
  }

  String? _validateThumbnail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    final host = uri?.host ?? '';
    final labels = host.split('.');
    final domainLabel = RegExp(
      r'^[a-zA-Z0-9\u00a1-\uffff](?:[a-zA-Z0-9\u00a1-\uffff-]{0,61}[a-zA-Z0-9\u00a1-\uffff])?$',
    );
    var validHost =
        host == 'localhost' ||
        host.contains(':') || // Uri parsing already validates IPv6 syntax.
        (labels.length > 1 && labels.every(domainLabel.hasMatch));
    if (RegExp(r'^[0-9.]+$').hasMatch(host)) {
      validHost =
          labels.length == 4 &&
          labels.every((label) {
            final number = int.tryParse(label);
            return number != null && number >= 0 && number <= 255;
          });
    }
    if (text.runes.length > 200 ||
        RegExp(r'\s').hasMatch(text) ||
        uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        !validHost ||
        (uri.hasPort && uri.port > 65535)) {
      return 'Gunakan URL http:// atau https:// yang valid (maks. 200 karakter).';
    }
    return null;
  }

  // DateTime normalizes impossible dates; compare components to reject them.
  DateTime? _parseDate(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})$')
        .firstMatch(value.trim());
    if (match == null) return null;
    final parts = [for (var i = 1; i <= 5; i++) int.parse(match.group(i)!)];
    if (parts[0] < 1) return null;
    final date = DateTime.utc(parts[0], parts[1], parts[2], parts[3], parts[4]);
    if (date.year != parts[0] ||
        date.month != parts[1] ||
        date.day != parts[2] ||
        date.hour != parts[3] ||
        date.minute != parts[4]) {
      return null;
    }
    return date;
  }

  String? _validateDate(String? value, {bool isEnd = false}) {
    if (isEnd && _isOngoing) return null;
    if (value == null || value.trim().isEmpty) {
      return isEnd
          ? 'Isi tanggal akhir atau aktifkan Masih berlangsung.'
          : null;
    }
    final date = _parseDate(value);
    if (date == null) return 'Gunakan tanggal valid: YYYY-MM-DD HH:mm (UTC).';
    final start = _parseDate(_startController.text);
    if (isEnd && start != null && date.isBefore(start)) {
      return 'Tanggal akhir tidak boleh sebelum tanggal mulai.';
    }
    return null;
  }

  Future<void> _pickDateTime(TextEditingController controller) async {
    final current = _parseDate(controller.text) ?? DateTime.now().toUtc();
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
      helpText: 'Pilih tanggal (UTC)',
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
      helpText: 'Pilih waktu (UTC)',
    );
    if (time == null || !mounted) return;
    String two(int value) => value.toString().padLeft(2, '0');
    controller.text =
        '${date.year.toString().padLeft(4, '0')}-'
        '${two(date.month)}-${two(date.day)} ${two(time.hour)}:${two(time.minute)}';
    _markDirty();
  }

  void _save() {
    setState(() {
      _attemptedSave = true;
      _savedExperience = null;
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
    setState(() {
      final thumbnail = _thumbnailController.text.trim();
      _savedExperience = ExperienceDraft(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category!,
        thumbnail: thumbnail.isEmpty ? null : thumbnail,
        startedAt: _parseDate(_startController.text),
        endedAt: _isOngoing ? null : _parseDate(_endController.text),
      );
    });
    final experience = _savedExperience!;
    showDialog<void>(
      context: context,
      builder: (context) => ExperienceSummaryDialog(experience: experience),
    );
  }

  Widget _dateField({required bool isEnd}) {
    final enabled = !isEnd || !_isOngoing;
    final controller = isEnd ? _endController : _startController;
    return TextFormField(
      key: ValueKey(isEnd ? 'ended_at' : 'started_at'),
      controller: controller,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? PortfolioColors.ink : PortfolioColors.muted,
      ),
      keyboardType: TextInputType.datetime,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: isEnd ? 'Tanggal akhir · UTC' : 'Tanggal mulai · UTC',
        hintText: 'YYYY-MM-DD HH:mm',
        helperText: isEnd && _isOngoing
            ? 'Tidak diperlukan untuk pengalaman yang masih berlangsung.'
            : isEnd
            ? 'YYYY-MM-DD HH:mm · gunakan waktu UTC.'
            : 'Opsional · YYYY-MM-DD HH:mm · waktu UTC.',
        suffixIcon: IconButton(
          tooltip: isEnd ? 'Pilih tanggal akhir' : 'Pilih tanggal mulai',
          onPressed: enabled ? () => _pickDateTime(controller) : null,
          icon: const Icon(Icons.calendar_month_outlined),
        ),
      ),
      validator: (value) => _validateDate(value, isEnd: isEnd),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      drawer: const PortfolioDrawer(
        currentDestination: PortfolioDestination.experience,
      ),
      appBar: AppBar(
        leading: const BackButton(),
        actions: const [DrawerButton()],
        title: const Text('Tambah Experience'),
        titleTextStyle: const TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: PortfolioColors.ink,
        ),
        toolbarHeight: isNarrow ? 72 : 88,
        backgroundColor: PortfolioColors.cream,
        surfaceTintColor: Colors.transparent,
        foregroundColor: PortfolioColors.mauve,
        elevation: 0,
      ),
      body: PortfolioBackground(
        child: SizedBox.expand(
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
                            Icons.work_outline_rounded,
                            color: Color(0xFF765621),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Setiap pengalaman punya cerita.',
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
                          'Ceritakan peran, kegiatan, dan hal yang kamu pelajari. '
                          'Judul, deskripsi, dan kategori wajib diisi.',
                          style: TextStyle(
                            color: PortfolioColors.muted,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Form(
                          key: _formKey,
                          onChanged: _markDirty,
                          autovalidateMode: _attemptedSave
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _FormSectionTitle('Detail pengalaman'),
                              const SizedBox(height: 20),
                              TextFormField(
                                key: const ValueKey('title'),
                                controller: _titleController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Judul *',
                                  hintText: 'Contoh: Koordinator acara kampus',
                                  helperText: 'Maksimal 255 karakter.',
                                ),
                                validator: (value) {
                                  final required = _requiredText(
                                    value,
                                    'Judul',
                                  );
                                  if (required != null) return required;
                                  return value!.trim().runes.length > 255
                                      ? 'Judul maksimal 255 karakter.'
                                      : null;
                                },
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                key: const ValueKey('description'),
                                controller: _descriptionController,
                                minLines: 4,
                                maxLines: 8,
                                keyboardType: TextInputType.multiline,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: const InputDecoration(
                                  labelText: 'Deskripsi *',
                                  alignLabelWithHint: true,
                                  hintText:
                                      'Apa yang kamu kerjakan dan pelajari?',
                                ),
                                validator: (value) =>
                                    _requiredText(value, 'Deskripsi'),
                              ),
                              const SizedBox(height: 24),
                              DropdownButtonFormField<ExperienceCategory>(
                                key: const ValueKey('category'),
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Kategori *',
                                ),
                                items: [
                                  for (final category
                                      in ExperienceCategory.values)
                                    DropdownMenuItem(
                                      value: category,
                                      child: Text(category.label),
                                    ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _category = value),
                                validator: (value) => value == null
                                    ? 'Pilih kategori pengalaman.'
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                key: const ValueKey('thumbnail'),
                                controller: _thumbnailController,
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.next,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                  labelText: 'URL thumbnail',
                                  helperText: 'Opsional · tautan http:// atau https://.',
                                  hintText:
                                      'https://example.com/experience.jpg',
                                ),
                                validator: _validateThumbnail,
                              ),
                              const SizedBox(height: 24),
                              const _FormSectionTitle('Waktu & status'),
                              const SizedBox(height: 20),
                              _dateField(isEnd: false),
                              const SizedBox(height: 16),
                              SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Masih berlangsung'),
                                subtitle: const Text(
                                  'Aktifkan jika belum ada tanggal akhir.',
                                ),
                                value: _isOngoing,
                                onChanged: (value) {
                                  setState(() {
                                    _isOngoing = value;
                                    _savedExperience = null;
                                    if (value) _endController.clear();
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              _dateField(isEnd: true),
                              const SizedBox(height: 32),
                              PortfolioGlassButton(
                                label: 'Save',
                                icon: Icons.check_rounded,
                                onPressed: _save,
                              ),
                              if (_savedExperience != null) ...[
                                const SizedBox(height: 16),
                                Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    'Data “${_savedExperience!.title}” valid dan siap '
                                    'digunakan. Belum dikirim ke server.',
                                    key: const ValueKey('save_status'),
                                    style: const TextStyle(
                                      color: PortfolioColors.ink,
                                      height: 1.5,
                                    ),
                                  ),
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
      ),
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Playfair Display',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: PortfolioColors.roseInk,
      ),
    );
  }
}
