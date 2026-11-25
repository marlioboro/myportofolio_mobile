import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/services/api_client.dart';

import 'helpers.dart';

void main() {
  test('getProjects mengubah JSON dari DRF menjadi list Project', () async {
    final api = fakeApi(
      (request) async => http.Response('[$sampleProjectJson]', 200),
    );
    final projects = await api.getProjects();

    expect(projects, hasLength(1));
    expect(projects.first.title, 'Sortify AI');
    expect(projects.first.categoryDisplay, 'Data & AI');
    expect(projects.first.starCount, 2);
  });

  test('obtainToken mengembalikan token dari server', () async {
    final api = fakeApi(
      (request) async => http.Response('{"token": "abc123"}', 200),
    );
    expect(await api.obtainToken('owner', 'rahasia'), 'abc123');
  });

  test('status selain 2xx dilempar sebagai ApiException', () async {
    final api = fakeApi(
      (request) async => http.Response('{"detail": "Invalid token."}', 401),
    );
    expect(
      () => api.logout(token: 'lama'),
      throwsA(
        isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
      ),
    );
  });
}
