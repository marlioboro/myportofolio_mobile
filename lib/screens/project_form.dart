import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Form tambah proyek yang mengirim `POST /api/v1/projects/` dengan token.
/// Field-nya mengikuti `ProjectSerializer` di Django.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _roleController = TextEditingController();
  final _technologiesController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();

  String _category = 'game';
  String _status = 'released';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _roleController.dispose();
    _technologiesController.dispose();
    _projectUrlController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label tidak boleh kosong!';
    }
    return null;
  }

  /// URL boleh kosong, tapi kalau diisi harus http/https yang valid.
  String? _optionalUrl(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    final isValid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.');
    return isValid ? null : 'Masukkan URL valid (http:// atau https://).';
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    for (final controller in [
      _titleController,
      _summaryController,
      _roleController,
      _technologiesController,
      _projectUrlController,
      _thumbnailUrlController,
    ]) {
      controller.clear();
    }
    setState(() {
      _category = 'game';
      _status = 'released';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final auth = context.read<AuthState>();
    final api = context.read<ApiClient>();
    final messenger = ScaffoldMessenger.of(context);
    final project = Project(
      title: _titleController.text.trim(),
      summary: _summaryController.text.trim(),
      category: _category,
      status: _status,
      role: _roleController.text.trim(),
      technologies: _technologiesController.text.trim(),
      projectUrl: _projectUrlController.text.trim(),
      thumbnailUrl: _thumbnailUrlController.text.trim(),
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      final created = await api.createProject(project, token: auth.token!);
      if (!mounted) return;
      // Matikan loading sebelum dialog muncul, supaya tombol Save tidak
      // tetap berputar selama dialog terbuka.
      setState(() {
        _isSubmitting = false;
      });
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Judul: ${created.title}'),
                Text(
                  'Kategori: ${created.categoryDisplay ?? created.category}',
                ),
                Text('Status: ${created.statusDisplay ?? created.status}'),
                Text('Role: ${created.role}'),
                Text('Tech Stack: ${created.technologies}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      _resetForm();
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        // Token sudah tidak berlaku: hapus token lalu minta login ulang.
        await auth.logout();
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Sesi habis. Silakan login lagi.')),
        );
        await ensureLoggedIn(context);
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              error.statusCode == 403
                  ? 'Akun ini tidak punya izin menambah proyek (403).'
                  : 'Gagal menyimpan proyek (${error.statusCode}).',
            ),
          ),
        );
      }
    } on Exception {
      messenger.showSnackBar(
        const SnackBar(content: Text('Tidak bisa terhubung ke server.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
    );
  }

  Widget _field(Widget child) =>
      Padding(padding: const EdgeInsets.all(8), child: child);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(
                TextFormField(
                  controller: _titleController,
                  maxLength: 255,
                  decoration: _decoration('Title'),
                  validator: (value) => _required(value, 'Title'),
                ),
              ),
              _field(
                TextFormField(
                  controller: _summaryController,
                  maxLines: 5,
                  decoration: _decoration('Description'),
                  validator: (value) => _required(value, 'Description'),
                ),
              ),
              _field(
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: _decoration('Category'),
                  items: projectCategories.entries
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
                ),
              ),
              _field(
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: _decoration('Status'),
                  items: projectStatuses.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
              ),
              _field(
                TextFormField(
                  controller: _roleController,
                  maxLength: 120,
                  decoration: _decoration('Role', hint: 'Contoh: Developer'),
                  validator: (value) => _required(value, 'Role'),
                ),
              ),
              _field(
                TextFormField(
                  controller: _technologiesController,
                  decoration: _decoration(
                    'Tech Stack',
                    hint: 'Contoh: Flutter, Django, Figma',
                  ),
                  validator: (value) => _required(value, 'Tech Stack'),
                ),
              ),
              _field(
                TextFormField(
                  controller: _projectUrlController,
                  keyboardType: TextInputType.url,
                  decoration: _decoration('Project URL', hint: 'https://...'),
                  validator: _optionalUrl,
                ),
              ),
              _field(
                TextFormField(
                  controller: _thumbnailUrlController,
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    'Project Image URL (Optional)',
                    hint: 'https://...',
                  ),
                  validator: _optionalUrl,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
