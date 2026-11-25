import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Detail satu proyek. Gambar hanya ditampilkan kalau `thumbnailUrl` diisi.
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (project.thumbnailUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                project.thumbnailUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 80,
                  child: Center(child: Text('Gambar tidak bisa dimuat.')),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            project.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text(
                  project.categoryDisplay ??
                      projectCategories[project.category] ??
                      project.category,
                ),
              ),
              Chip(
                label: Text(
                  project.statusDisplay ??
                      projectStatuses[project.status] ??
                      project.status,
                ),
              ),
              if (project.featured) const Chip(label: Text('Featured')),
            ],
          ),
          const SizedBox(height: 16),
          _DetailItem(label: 'Role', value: project.role),
          _DetailItem(label: 'Tech Stack', value: project.technologies),
          _DetailItem(label: 'Summary', value: project.summary),
          if (project.projectUrl.isNotEmpty)
            _DetailItem(label: 'Project URL', value: project.projectUrl),
          _DetailItem(label: 'Stars', value: '${project.starCount}'),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SelectableText(value),
        ],
      ),
    );
  }
}
