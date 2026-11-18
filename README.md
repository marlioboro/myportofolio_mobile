# MyPortfolio Mobile

Aplikasi mobile Flutter untuk portofolio pribadi Muhammad Farel Ammar. Aplikasi ini jadi klien mobile dari website portofolio Django di repo [marlioboro/PBP](https://github.com/marlioboro/PBP), dan nantinya bakal disambungin ke API DRF `/api/v1/` yang udah dibikin di Tugas 6.

## Menjalankan Proyek

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Kalau mau dijalanin di HP Android, colok HP dengan USB debugging aktif (atau nyalain emulator dari Android Studio), terus jalanin `flutter run`.

## Progres Mingguan

| Minggu | Isi |
| --- | --- |
| Tutorial 08 | Setup Flutter, pisahin `menu.dart` dari `main.dart`, `MyHomePage` jadi stateless, bikin `InfoCard` dan `ItemCard` buat contoh Burhan. |
| Tugas 7 | Ganti data jadi punyaku sendiri, tombol aksi buat bagian Experience dengan warna beda-beda, layout yang aman di layar lebar, dan widget test. |
| Tutorial 09 | Drawer menu (Home dan Add Project), form tambah proyek dengan validasi dan dropdown kategori, dialog berisi data yang diisi, tombol Tambah Proyek yang membuka form lewat `Navigator.push`, serta refactor ke folder `screens/` dan `widgets/`. |

### Tugas 7

Yang aku kerjain di Tugas 7:

- `InfoCard` sekarang nampilin NPM, nama lengkap, dan kelas PBP-ku sendiri.
- Tombol aksi disesuaiin sama bagian Experience yang aku kerjain di Tugas 3–6: Lihat Experience (biru), Tambah Experience (hijau), dan Logout (merah). Warnanya disimpen di atribut `color` pada model `ItemHomepage`, jadi `ItemCard` tinggal pake `item.color` tanpa if-else.
- Tiap tombol munculin SnackBar "Kamu telah menekan tombol [Nama Tombol]!".
- Tambahan di luar checklist: halaman dibungkus `ConstrainedBox` + `ListView` biar tetep rapi dan bisa di-scroll di jendela Chrome yang lebar (sebelumnya kotak tombolnya jadi gede banget dan muncul pita "BOTTOM OVERFLOWED"). Lebar `InfoCard` sekarang diatur `Expanded`, bukan `MediaQuery`.
- Test counter bawaan Flutter aku ganti jadi widget test yang ngecek kartu profil, tombol aksi, dan pesan SnackBar tiap tombol (`flutter test`).

1. **Widget tree dan hubungan parent-child**

   Di Flutter, semua yang muncul di layar itu widget, dan widget-widget itu disusun bertingkat kayak pohon. Itu yang disebut widget tree. Di aplikasiku, akarnya `MyApp` yang ngebalikin `MaterialApp`, terus di bawahnya ada `MyHomePage` -> `Scaffold` -> `AppBar` dan `body`. Di dalam body ada `ListView` yang anaknya `Row` berisi tiga `InfoCard`, teks sambutan, sama `GridView` berisi tiga `ItemCard`.

   Hubungan parent-child-nya kerja kayak gini: parent yang nentuin anaknya boleh selebar dan setinggi apa (constraints), anak nentuin ukurannya sendiri di dalam batas itu, terus parent yang naruh anaknya di posisi tertentu. Contohnya, `ConstrainedBox` ngebatesin lebar maksimal 560, `Row` ngasih ruang ke tiga `Expanded`, dan `Expanded` bagi lebarnya sama rata buat tiap `InfoCard`. Data juga ngalir dari atas ke bawah: tema dari `MaterialApp` bisa dibaca widget di bawahnya lewat `Theme.of(context)`, dan objek `ItemHomepage` dioper dari `MyHomePage` ke `ItemCard` lewat konstruktor.

2. **Widget yang aku pake dan fungsinya**

   Widget buatan sendiri:
   - `MyApp`: root aplikasi, ngatur judul dan tema, terus nampilin `MyHomePage`.
   - `MyHomePage`: halaman utama yang nyusun semua komponen.
   - `InfoCard`: kartu kecil buat nampilin satu info profil (judul + isi).
   - `ItemCard`: kartu tombol aksi berikon yang munculin SnackBar pas ditekan.

   Widget bawaan Flutter:
   - `MaterialApp`: pembungkus aplikasi bergaya Material, nyediain tema, navigasi, dan pengaturan dasar lainnya.
   - `Scaffold`: kerangka halaman yang nyediain tempat buat `AppBar`, `body`, dan SnackBar.
   - `AppBar`: bar judul di bagian atas halaman.
   - `Text`: nampilin tulisan.
   - `Center`: naruh anaknya di tengah.
   - `ConstrainedBox`: ngebatesin ukuran anaknya, di sini lebar maksimal 560 piksel.
   - `ListView`: daftar yang bisa di-scroll, dipake sebagai wadah utama isi halaman.
   - `Row`: nyusun anak-anaknya secara horizontal (tiga `InfoCard`).
   - `Expanded`: bikin anak di dalam `Row` ngisi sisa ruang dengan pembagian yang sama.
   - `Card`: kotak bergaya Material dengan bayangan buat `InfoCard`.
   - `Padding`: ngasih jarak di sekeliling anaknya.
   - `Column`: nyusun anak-anaknya secara vertikal.
   - `SizedBox`: jarak kosong dengan ukuran tertentu.
   - `GridView`: nyusun `ItemCard` jadi kisi tiga kolom.
   - `Material`: permukaan berwarna dengan sudut melengkung buat latar `ItemCard`, sekaligus tempat efek ripple digambar.
   - `InkWell`: bikin area bisa ditekan dan ngasih efek ripple, di sini buat nangkep `onTap`.
   - `Container`: wadah serbaguna, dipake buat ngasih padding di dalam `ItemCard`.
   - `Icon`: nampilin ikon tombol.
   - `ScaffoldMessenger`: ngatur SnackBar yang tampil di `Scaffold`.
   - `SnackBar`: notifikasi singkat di bawah layar setelah tombol ditekan.

3. **Fungsi `MaterialApp` dan kenapa jadi root widget**

   `MaterialApp` itu pembungkus paling luar buat aplikasi yang pake gaya Material Design. Dia yang nyiapin hal-hal dasar yang dibutuhin widget lain: tema (`ThemeData` dan `ColorScheme`), navigasi antarhalaman (`Navigator` dan route), arah teks dan lokalisasi, judul aplikasi, sama `ScaffoldMessenger` buat SnackBar.

   Makanya dia biasanya jadi root widget. Banyak widget Material kayak `Scaffold`, `AppBar`, `Card`, dan `SnackBar` butuh hal-hal tadi ada di atasnya di widget tree. Kalau nggak ada `MaterialApp`, `Theme.of(context)` nggak nemu tema yang aku set, dan SnackBar nggak punya tempat buat ditampilin. Taruh di paling atas, semua halaman di bawahnya otomatis dapet tema dan fitur yang sama.

4. **StatelessWidget vs StatefulWidget**

   `StatelessWidget` itu widget yang tampilannya cuma bergantung sama data yang dioper lewat konstruktor dan nggak nyimpen data yang bisa berubah sendiri. Kalau mau tampilannya beda, parent-nya yang harus bikin ulang widget itu dengan data baru. `StatefulWidget` punya objek `State` terpisah yang nyimpen data yang bisa berubah, dan tiap kali `setState()` dipanggil, Flutter bakal jalanin `build()` lagi.

   Pilih `StatelessWidget` kalau tampilannya statis atau cuma nampilin data dari luar, kayak halaman menu ini: info profil dan tombolnya tetep, SnackBar-nya juga diurus `ScaffoldMessenger`, bukan disimpen di widget. Pilih `StatefulWidget` kalau widget itu sendiri harus inget sesuatu yang berubah selama dipake, misalnya angka counter di demo bawaan Flutter, isi form yang lagi diketik, checkbox, atau data yang lagi di-load dari API.

5. **`BuildContext`**

   `BuildContext` itu semacam alamat atau posisi sebuah widget di widget tree. Tiap method `build(BuildContext context)` dapet context-nya sendiri, dan lewat context itu widget bisa nyari hal-hal yang disediain sama widget di atasnya.

   Di proyekku contohnya ada tiga. `Theme.of(context).colorScheme.primary` dipake buat ngambil warna AppBar dari tema di `MaterialApp`. `ScaffoldMessenger.of(context)` dipake di `ItemCard` buat nemuin `ScaffoldMessenger` terdekat, terus nampilin SnackBar. Dulu di Tutorial 08 juga ada `MediaQuery.of(context).size` buat baca lebar layar. Pentingnya: context harus yang posisinya bener di tree. Kalau pake context dari widget yang letaknya di atas `MaterialApp`, pencariannya bakal gagal karena tema dan `ScaffoldMessenger`-nya belum ada di atas posisi itu.

6. **Hot reload vs hot restart**

   Hot reload (tekan `r` di terminal) nyuntikin kode yang baru diubah ke aplikasi yang lagi jalan, terus build ulang tampilannya tanpa ngereset state. Jadi kalau aku ganti warna tombol atau teks, hasilnya langsung keliatan dalam hitungan detik, dan data yang lagi ada di layar nggak hilang. Hot restart (tekan `R`) muat ulang semua kode Dart dan jalanin aplikasi dari `main()` lagi, jadi state-nya balik ke awal. Hot restart masih lebih cepet daripada full restart (stop terus `flutter run` lagi), yang juga ngompilasi ulang bagian native.

   Hot reload nggak cukup kalau perubahannya nyentuh hal yang cuma dijalanin sekali di awal atau nyimpen state lama. Contohnya: ngubah `main()` atau isi `initState()`, ngubah nilai awal field atau variabel global/static, ngubah `StatelessWidget` jadi `StatefulWidget` (atau sebaliknya), dan ngubah enum atau tipe generic. Buat kasus itu perlu hot restart. Kalau nambah package baru di `pubspec.yaml`, ngubah aset, atau ngubah kode native Android/iOS, harus full restart. Di Flutter web, hot reload juga pernah nggak tersedia di beberapa versi, jadi waktu jalanin di Chrome aku lebih sering pake hot restart.

#### Penggunaan AI

Aku pake Claude buat bantu Tugas 7. Strateginya: Claude baca checklist Tugas 7 dulu, terus ngecek kode Tutorial 08 di repo ini, baru ngerjain perubahan satu-satu dengan commit terpisah.

Bagian yang dibantu AI:
- nambahin atribut `color` di `ItemHomepage` dan nyesuaiin tombol ke bagian Experience;
- benerin layout biar nggak overflow di layar lebar;
- bikin widget test pengganti test counter bawaan;
- nyusun draf README dan jawaban reflektif.

Aku sendiri yang nentuin bagian Experience jadi isi tombol (nyambung sama Tugas 3–6), ngasih data NPM, nama, dan kelas, terus jalanin `flutter analyze`, `flutter test`, dan `flutter run -d chrome` di laptopku.

Catatan keterbatasan AI dan perbaikan manual:
- Claude nggak bisa jalanin Flutter di lingkungannya (download Dart SDK diblokir jaringan), jadi semua hasil analyze, test, dan tampilan aku cek sendiri di laptop.
- Waktu tes di Chrome, layout dari Tutorial 08 kegedean di jendela lebar dan muncul pita "BOTTOM OVERFLOWED". Dari situ aku minta layout-nya dibatasi lebarnya dan dibikin bisa di-scroll.
- Test bawaan Flutter masih ngecek counter yang udah nggak ada, jadi pasti gagal kalau dijalanin. Test itu aku ganti, bukan dibiarin.
