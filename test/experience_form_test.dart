import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const formTitle = 'Add Experience Form';
const menuGreeting = 'Selamat datang di MyPortfolio Mobile!';

Future<void> openFormFromCard(WidgetTester tester) async {
  await tester.pumpWidget(buildTestApp());
  await tester.ensureVisible(find.text('Tambah Experience'));
  await tester.tap(find.text('Tambah Experience'));
  await tester.pumpAndSettle();
}

Future<void> tapSave(WidgetTester tester) async {
  final save = find.text('Simpan');
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pumpAndSettle();
}

/// Urutan TextFormField di form: judul, deskripsi, thumbnail.
Finder field(int index) => find.byType(TextFormField).at(index);

/// Mencari teks hanya di dalam dialog, supaya isi TextFormField di belakang
/// dialog tidak ikut terhitung.
Finder inDialog(String text) => find.descendant(
      of: find.byType(AlertDialog),
      // Text.rich ikut dicocokkan lewat isi TextSpan-nya.
      matching: find.textContaining(text),
    );

void main() {
  testWidgets('Kartu Tambah Experience membuka form dan Back kembali ke menu',
      (WidgetTester tester) async {
    await openFormFromCard(tester);
    expect(find.text(formTitle), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(menuGreeting), findsOneWidget);
  });

  testWidgets('Drawer membuka form, lalu Home dari form kembali ke menu',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);
    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();
    expect(find.text(formTitle), findsOneWidget);

    // Drawer yang sama juga ada di halaman form.
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text(menuGreeting), findsOneWidget);
    expect(find.text(formTitle), findsNothing);
  });

  testWidgets('Simpan dengan isian kosong atau spasi menampilkan pesan error',
      (WidgetTester tester) async {
    await openFormFromCard(tester);

    await tapSave(tester);
    expect(find.text('Judul experience tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi experience tidak boleh kosong!'),
        findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.enterText(field(0), '   ');
    await tester.enterText(field(1), '<p></p>');
    await tapSave(tester);
    expect(find.text('Judul experience tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi experience tidak boleh kosong!'),
        findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('URL thumbnail dan tanggal selesai ikut divalidasi',
      (WidgetTester tester) async {
    await openFormFromCard(tester);
    await tester.enterText(field(0), 'RISTEK Fasilkom UI');
    await tester.enterText(field(1), 'Game Development SIG.');
    await tester.enterText(field(2), 'bukan-url');

    // Matikan "Masih berlangsung" tanpa memilih tanggal selesai.
    await tester.ensureVisible(find.text('Masih berlangsung'));
    await tester.tap(find.text('Masih berlangsung'));
    await tester.pumpAndSettle();
    expect(find.text('Tanggal Selesai'), findsOneWidget);

    await tapSave(tester);
    expect(
      find.text('Masukkan URL valid yang diawali http:// atau https://'),
      findsOneWidget,
    );
    expect(
      find.text('Pilih tanggal selesai, atau aktifkan "Masih berlangsung".'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Isian valid menampilkan ringkasan, lalu Tutup kembali ke form',
      (WidgetTester tester) async {
    await openFormFromCard(tester);
    await tester.enterText(field(0), '<b>RISTEK Fasilkom UI</b>');
    await tester.enterText(field(1), 'Game Development SIG.');
    await tester.enterText(field(2), 'https://ristek.cs.ui.ac.id/logo.png');

    await tapSave(tester);
    expect(find.text('Experience berhasil disimpan!'), findsOneWidget);
    expect(inDialog('RISTEK Fasilkom UI'), findsOneWidget);
    expect(inDialog('Game Development SIG.'), findsOneWidget);
    expect(inDialog('Full-Time'), findsOneWidget);
    expect(inDialog('https://ristek.cs.ui.ac.id/logo.png'), findsOneWidget);
    expect(inDialog('Sedang berlangsung'), findsOneWidget);
    // Tag HTML sudah dibuang dari ringkasan.
    expect(inDialog('<b>'), findsNothing);

    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text(formTitle), findsOneWidget);
  });
}
