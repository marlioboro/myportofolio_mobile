/// Aturan validasi form Experience.
///
/// Aturannya mengikuti model `Experience` di proyek Django `myportofolio`:
/// `title` maksimal 255 karakter, `description` wajib, `thumbnail` berupa
/// URLField opsional (maksimal 200 karakter), dan `ended_at` boleh kosong
/// kalau experience masih berlangsung. Seperti `strip_tags` di
/// `ExperienceForm`, isian yang cuma berisi tag HTML dianggap kosong.
library;

const int experienceTitleMaxLength = 255;
const int thumbnailUrlMaxLength = 200;

/// Pilihan kategori, sama dengan `Experience.EXPERIENCE_CHOICES` di Django,
/// supaya nanti data dari form ini bisa langsung dikirim ke API `/api/v1/`.
const Map<String, String> experienceCategories = {
  'organization': 'Organization',
  'internship': 'Internship',
  'research': 'Research',
  'volunteer': 'Volunteer',
  'part-time': 'Part-Time',
  'full-time': 'Full-Time',
  'freelance': 'Freelance',
};

final RegExp _htmlTag = RegExp(r'<[^>]*>');

/// Menghapus tag HTML lalu spasi di awal dan akhir teks.
String stripTags(String value) => value.replaceAll(_htmlTag, '').trim();

String? validateExperienceTitle(String? value) {
  final raw = value ?? '';
  if (stripTags(raw).isEmpty) {
    return 'Judul experience tidak boleh kosong!';
  }
  if (raw.trim().length > experienceTitleMaxLength) {
    return 'Judul maksimal $experienceTitleMaxLength karakter.';
  }
  return null;
}

String? validateExperienceDescription(String? value) {
  if (stripTags(value ?? '').isEmpty) {
    return 'Deskripsi experience tidak boleh kosong!';
  }
  return null;
}

String? validateExperienceCategory(String? value) {
  if (value == null || !experienceCategories.containsKey(value)) {
    return 'Pilih salah satu kategori yang tersedia.';
  }
  return null;
}

/// Thumbnail boleh kosong, tapi kalau diisi harus URL http/https yang valid.
String? validateThumbnailUrl(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return null;
  if (text.length > thumbnailUrlMaxLength) {
    return 'URL maksimal $thumbnailUrlMaxLength karakter.';
  }
  final uri = Uri.tryParse(text);
  final isValid = uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.contains('.');
  if (!isValid) {
    return 'Masukkan URL valid yang diawali http:// atau https://';
  }
  return null;
}

/// Tanggal selesai wajib dipilih kalau experience sudah tidak berlangsung,
/// dan tidak boleh lebih dari hari ini.
String? validateEndedAt(
  DateTime? endedAt, {
  required bool isOngoing,
  required DateTime today,
}) {
  if (isOngoing) return null;
  if (endedAt == null) {
    return 'Pilih tanggal selesai, atau aktifkan "Masih berlangsung".';
  }
  final startOfTomorrow = DateTime(today.year, today.month, today.day + 1);
  if (!endedAt.isBefore(startOfTomorrow)) {
    return 'Tanggal selesai tidak boleh setelah hari ini.';
  }
  return null;
}

/// Format tanggal sederhana dd/MM/yyyy tanpa package tambahan.
String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
