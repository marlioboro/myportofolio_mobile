import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Drawer menu yang dipakai bersama di semua halaman.
///
/// Opsi Login/Logout ikut berubah otomatis karena drawer membaca
/// [AuthState] lewat `context.watch`.
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  void _replaceWith(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Portfolio',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Explore personal projects and experiences!',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => _replaceWith(context, MyHomePage()),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Projects'),
            // Daftar proyek publik, tidak perlu login.
            onTap: () => _replaceWith(context, const ProjectListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            // Menambah proyek butuh token, jadi minta login dulu.
            onTap: () async {
              final loggedIn = await ensureLoggedIn(context);
              if (!loggedIn || !context.mounted) return;
              _replaceWith(context, const ProjectFormPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Add Experience'),
            onTap: () => _replaceWith(context, const ExperienceFormPage()),
          ),
          const Divider(),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                await context.read<AuthState>().logout();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Kamu sudah logout.')),
                );
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () => ensureLoggedIn(context),
            ),
        ],
      ),
    );
  }
}
