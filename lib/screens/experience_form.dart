import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/utils/experience_validators.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Halaman form untuk menambah Experience.
///
/// Field-nya mengikuti model `Experience` di Django. Data belum dikirim ke
/// server; setelah lolos validasi, ringkasan isian ditampilkan di dialog.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller menyimpan isi tiap TextFormField, jadi tidak perlu setState
  // di setiap ketikan seperti pola onChanged di Tutorial 09.
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _endedAtController = TextEditingController();

  String _category = 'full-time';
  bool _isOngoing = true;
  DateTime? _endedAt;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    _endedAtController.dispose();
    super.dispose();
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endedAt ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Pilih tanggal selesai',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _endedAt = picked;
      _endedAtController.text = formatDate(picked);
    });
  }

  void _setOngoing(bool value) {
    setState(() {
      _isOngoing = value;
      if (value) {
        _endedAt = null;
        _endedAtController.clear();
      }
    });
  }

  /// Menjalankan semua validator; dialog hanya muncul jika semuanya lolos.
  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final thumbnail = _thumbnailController.text.trim();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Experience berhasil disimpan!'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(
                  label: 'Judul',
                  value: stripTags(_titleController.text),
                ),
                _SummaryRow(
                  label: 'Deskripsi',
                  value: stripTags(_descriptionController.text),
                ),
                _SummaryRow(
                  label: 'Kategori',
                  value: experienceCategories[_category]!,
                ),
                _SummaryRow(
                  label: 'Thumbnail',
                  value: thumbnail.isEmpty ? '-' : thumbnail,
                ),
                _SummaryRow(
                  label: 'Status',
                  value: _isOngoing
                      ? 'Sedang berlangsung'
                      : 'Selesai pada ${formatDate(_endedAt!)}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _decoration(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Experience Form',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // Warna sama dengan AppBar halaman utama (colorScheme.primary).
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      // SafeArea + SingleChildScrollView menjaga semua input dan tombol
      // Simpan tetap bisa dijangkau di layar sempit atau saat keyboard muncul.
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      maxLength: experienceTitleMaxLength,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        'Judul Experience',
                        Icons.work_outline,
                        hint: 'Contoh: RISTEK Fasilkom UI',
                      ),
                      validator: validateExperienceTitle,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: _decoration(
                        'Deskripsi',
                        Icons.notes,
                        hint: 'Apa peran dan kontribusimu?',
                      ),
                      validator: validateExperienceDescription,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: _decoration(
                        'Kategori',
                        Icons.category_outlined,
                      ),
                      items: experienceCategories.entries
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _category = value);
                      },
                      validator: validateExperienceCategory,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _thumbnailController,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      decoration: _decoration(
                        'URL Thumbnail (opsional)',
                        Icons.link,
                        hint: 'https://...',
                      ),
                      validator: validateThumbnailUrl,
                    ),
                    const SizedBox(height: 4),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Masih berlangsung'),
                      subtitle: const Text(
                        'Matikan jika experience ini sudah selesai.',
                      ),
                      value: _isOngoing,
                      onChanged: _setOngoing,
                    ),
                    // Tanggal selesai hanya muncul kalau experience sudah selesai.
                    if (!_isOngoing) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _endedAtController,
                        readOnly: true,
                        onTap: _pickEndDate,
                        decoration: _decoration(
                          'Tanggal Selesai',
                          Icons.event,
                          hint: 'Ketuk untuk memilih tanggal',
                        ),
                        validator: (_) => validateEndedAt(
                          _endedAt,
                          isOngoing: _isOngoing,
                          today: DateTime.now(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Simpan'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Satu baris ringkasan di dialog: label tebal lalu nilainya.
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
