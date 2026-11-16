import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('Halaman utama menampilkan kartu profil dan tombol aksi',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text('Lihat Experience'), findsOneWidget);
    expect(find.text('Tambah Experience'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Menekan tombol aksi memunculkan SnackBar sesuai nama tombol',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    for (final name in ['Lihat Experience', 'Tambah Experience', 'Logout']) {
      await tester.tap(find.text(name));
      await tester.pump();
      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);
    }
  });
}
