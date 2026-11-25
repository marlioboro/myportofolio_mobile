import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

/// ApiClient palsu supaya test tidak memanggil server sungguhan.
ApiClient fakeApi([MockClientHandler? handler]) => ApiClient(
  client: MockClient(handler ?? (_) async => http.Response('[]', 200)),
  baseUrl: 'http://test',
);

/// Aplikasi lengkap dengan ApiClient palsu.
Widget buildTestApp([MockClientHandler? handler]) =>
    MyApp(apiClient: fakeApi(handler));

/// Satu halaman dengan provider yang sama seperti di main.dart.
Widget wrapPage(Widget page, {required ApiClient api, String? token}) {
  return MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: api),
      ChangeNotifierProvider(
        create: (_) => AuthState(api, initialToken: token),
      ),
    ],
    child: MaterialApp(home: page),
  );
}

const sampleProjectJson =
    '{"id": "8f0c", "slug": "sortify-ai", "title": "Sortify AI", '
    '"summary": "Klasifikasi sampah dengan AI.", "category": "data", '
    '"category_display": "Data & AI", "status": "released", '
    '"status_display": "Released", "role": "Developer", '
    '"technologies": "Flutter, Django", "technology_list": ["Flutter"], '
    '"project_url": "", "thumbnail_url": "", "featured": false, '
    '"star_count": 2, "is_starred": false, "starred_by_names": ""}';
