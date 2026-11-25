import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:myportofolio_mobile/screens/project_form.dart';

import 'helpers.dart';

void main() {
  testWidgets('Halaman utama menampilkan kartu profil dan tombol aksi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

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

  testWidgets('Menekan tombol aksi memunculkan SnackBar sesuai nama tombol', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    // Tambah Experience dan Tambah Proyek membuka halaman lain, jadi diuji terpisah.
    for (final name in ['Lihat Experience', 'Logout']) {
      await tester.ensureVisible(find.text(name));
      await tester.tap(find.text(name));
      await tester.pump();
      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);
    }
  });

  testWidgets('Tambah Proyek tanpa login membuka halaman Login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await tester.ensureVisible(find.text('Tambah Proyek'));
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.text('Username'), findsWidgets);
    expect(find.text('Add Project Form'), findsNothing);

    // Batal login: kembali ke menu, form tidak dibuka.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Login lewat drawer lalu Add Project membuka form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp((request) async {
        if (request.url.path == '/api/v1/auth/token/') {
          return http.Response('{"token": "abc123"}', 200);
        }
        return http.Response('[]', 200);
      }),
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'owner');
    await tester.enterText(fields.at(1), 'rahasia');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('Add Project Form'), findsOneWidget);
  });

  testWidgets('Form proyek memvalidasi input lalu POST dengan token', (
    WidgetTester tester,
  ) async {
    http.Request? sent;
    final api = fakeApi((request) async {
      sent = request;
      return http.Response(sampleProjectJson, 201);
    });
    await tester.pumpWidget(
      wrapPage(const ProjectFormPage(), api: api, token: 'abc123'),
    );

    final save = find.text('Save');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();
    expect(find.text('Title tidak boleh kosong!'), findsOneWidget);
    expect(sent, isNull);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Sortify AI');
    await tester.enterText(fields.at(1), 'Klasifikasi sampah dengan AI.');
    await tester.enterText(fields.at(2), 'Developer');
    await tester.enterText(fields.at(3), 'Flutter, Django');
    await tester.enterText(fields.at(4), 'bukan-url');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();
    expect(
      find.text('Masukkan URL valid (http:// atau https://).'),
      findsOneWidget,
    );
    expect(sent, isNull);

    await tester.enterText(fields.at(4), '');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(sent, isNotNull);
    expect(sent!.method, 'POST');
    expect(sent!.headers['Authorization'], 'Token abc123');
    expect(sent!.body, contains('"title":"Sortify AI"'));
    expect(sent!.body, isNot(contains('"id"')));
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
  });
}
