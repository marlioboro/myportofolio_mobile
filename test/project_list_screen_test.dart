import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/screens/project_list_screen.dart';

import 'helpers.dart';

void main() {
  testWidgets('Daftar proyek diambil dari API dan detail bisa dibuka', (
    WidgetTester tester,
  ) async {
    final api = fakeApi(
      (request) async => http.Response('[$sampleProjectJson]', 200),
    );
    await tester.pumpWidget(wrapPage(const ProjectListScreen(), api: api));
    await tester.pumpAndSettle();

    expect(find.text('Sortify AI'), findsOneWidget);
    await tester.tap(find.text('Sortify AI'));
    await tester.pumpAndSettle();
    expect(find.text('Data & AI'), findsOneWidget);
    expect(find.text('Developer'), findsOneWidget);
  });

  testWidgets('Error dari API menampilkan tombol Retry', (
    WidgetTester tester,
  ) async {
    final api = fakeApi((request) async => http.Response('error', 500));
    await tester.pumpWidget(wrapPage(const ProjectListScreen(), api: api));
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
  });
}
