import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/utils/experience_validators.dart';

void main() {
  group('validateExperienceTitle', () {
    test('menolak kosong, spasi, dan isi yang cuma tag HTML', () {
      expect(validateExperienceTitle(null), isNotNull);
      expect(validateExperienceTitle('   '), isNotNull);
      expect(
        validateExperienceTitle('<img src=x onerror=alert(1)>'),
        isNotNull,
      );
    });

    test('menolak judul lebih dari 255 karakter', () {
      expect(validateExperienceTitle('a' * 255), isNull);
      expect(validateExperienceTitle('a' * 256), isNotNull);
    });

    test('menerima judul biasa', () {
      expect(validateExperienceTitle('RISTEK Fasilkom UI'), isNull);
    });
  });

  test('validateExperienceDescription menolak kosong dan tag saja', () {
    expect(validateExperienceDescription(''), isNotNull);
    expect(validateExperienceDescription('<p> </p>'), isNotNull);
    expect(validateExperienceDescription('Game Development SIG.'), isNull);
  });

  test('validateExperienceCategory hanya menerima kategori dari Django', () {
    expect(validateExperienceCategory('organization'), isNull);
    expect(validateExperienceCategory('part-time'), isNull);
    expect(validateExperienceCategory('astronaut'), isNotNull);
    expect(validateExperienceCategory(null), isNotNull);
  });

  group('validateThumbnailUrl', () {
    test('boleh kosong karena opsional', () {
      expect(validateThumbnailUrl(''), isNull);
      expect(validateThumbnailUrl(null), isNull);
    });

    test('menerima URL http dan https', () {
      expect(validateThumbnailUrl('https://example.com/a.png'), isNull);
      expect(validateThumbnailUrl('http://example.com'), isNull);
    });

    test('menolak format yang bukan URL web', () {
      expect(validateThumbnailUrl('bukan-url'), isNotNull);
      expect(validateThumbnailUrl('ftp://example.com/a.png'), isNotNull);
      expect(validateThumbnailUrl('https://localhost'), isNotNull);
    });

    test('menolak URL lebih dari 200 karakter', () {
      final longUrl = 'https://example.com/${'a' * 200}';
      expect(validateThumbnailUrl(longUrl), isNotNull);
    });
  });

  group('validateEndedAt', () {
    final today = DateTime(2026, 11, 23, 15);

    test('tidak wajib kalau masih berlangsung', () {
      expect(validateEndedAt(null, isOngoing: true, today: today), isNull);
    });

    test('wajib dipilih kalau sudah selesai', () {
      expect(validateEndedAt(null, isOngoing: false, today: today), isNotNull);
    });

    test('boleh hari ini atau sebelumnya, tidak boleh setelah hari ini', () {
      expect(
        validateEndedAt(DateTime(2026, 11, 23), isOngoing: false, today: today),
        isNull,
      );
      expect(
        validateEndedAt(DateTime(2025, 6, 30), isOngoing: false, today: today),
        isNull,
      );
      expect(
        validateEndedAt(DateTime(2026, 11, 24), isOngoing: false, today: today),
        isNotNull,
      );
    });
  });

  test('formatDate memakai format dd/MM/yyyy', () {
    expect(formatDate(DateTime(2026, 1, 5)), '05/01/2026');
  });
}
