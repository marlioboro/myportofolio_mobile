import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('Halaman utama menampilkan kartu profil dan tombol aksi',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text('2506585731'), findsOneWidget);
    expect(find.text('Muhammad Farel Ammar'), findsOneWidget);
    expect(find.text('PBP F'), findsOneWidget);
    for (final name in [
      'Lihat Experience',
      'Tambah Experience',
      'Tambah Proyek',
      'Logout',
    ]) {
      expect(find.text(name), findsOneWidget);
    }
  });

  testWidgets('Menekan tombol aksi memunculkan SnackBar sesuai nama tombol',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tambah Experience dan Tambah Proyek membuka form, jadi diuji terpisah.
    for (final name in ['Lihat Experience', 'Logout']) {
      await tester.ensureVisible(find.text(name));
      await tester.tap(find.text(name));
      await tester.pump();
      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);
    }
  });

  testWidgets('Tombol Tambah Proyek membuka form dan Back kembali ke menu',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.text('Tambah Proyek'));
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);

    // push() menyimpan menu di bawah form, jadi pageBack kembali ke menu.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Drawer bisa membuka form tambah proyek',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);
  });

  testWidgets('Form menolak isian kosong lalu menampilkan data yang valid',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.text('Tambah Proyek'));
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    final save = find.widgetWithText(ElevatedButton, 'Save');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Proyek'), 'Sortify AI');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Deskripsi Proyek'),
        'Klasifikasi sampah dengan AI.');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Nama Proyek: Sortify AI'), findsOneWidget);
    expect(find.text('Kategori: Web Development'), findsOneWidget);
  });
}
