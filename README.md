# MyPortfolio Mobile

Aplikasi mobile Flutter untuk portofolio pribadi Muhammad Farel Ammar. Aplikasi ini jadi klien mobile dari website portofolio Django di repo [marlioboro/PBP](https://github.com/marlioboro/PBP), dan nantinya bakal disambungin ke API DRF `/api/v1/` yang udah dibikin di Tugas 6.

## Menjalankan Proyek

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

Kalau mau dijalanin di HP Android, colok HP dengan USB debugging aktif (atau nyalain emulator dari Android Studio), terus jalanin `flutter run`.

## Progres Mingguan

| Minggu | Isi |
| --- | --- |
| Tutorial 08 | Setup Flutter, pisahin `menu.dart` dari `main.dart`, `MyHomePage` jadi stateless, bikin `InfoCard` dan `ItemCard` buat contoh Burhan. |
| Tugas 7 | Ganti data jadi punyaku sendiri, tombol aksi buat bagian Experience dengan warna beda-beda, layout yang aman di layar lebar, dan widget test. |
| Tutorial 09 | Drawer menu (Home dan Add Project), form tambah proyek dengan validasi dan dropdown kategori, dialog berisi data yang diisi, tombol Tambah Proyek yang membuka form lewat `Navigator.push`, serta refactor ke folder `screens/` dan `widgets/`. |
| Tugas 8 | Form tambah Experience sesuai model Django (judul, deskripsi, kategori, URL thumbnail, tanggal selesai), validator terpisah di `lib/utils/`, kartu dan opsi drawer buat buka form, dialog ringkasan, dan test. |
| Tutorial 10 | Login token ke Django (`/api/v1/auth/token/` dan `/api/v1/auth/logout/`), `ApiClient` + model `Project` hasil `json_serializable`, daftar dan detail proyek dari API pakai `FutureBuilder`, form proyek yang POST pakai token, route guard `ensureLoggedIn`, dan CI GitHub Actions. |

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

### Tugas 8

Yang aku kerjain di Tugas 8:

- Halaman baru `lib/screens/experience_form.dart` buat nambah Experience. Field-nya ngikutin model `Experience` di Django: judul (maks 255 karakter), deskripsi, kategori (pilihannya sama persis kayak `EXPERIENCE_CHOICES`), URL thumbnail opsional, dan tanggal selesai lewat `showDatePicker()` yang cuma muncul kalau saklar "Masih berlangsung" dimatiin.
- Aturan validasinya aku pisahin ke `lib/utils/experience_validators.dart`, jadi gampang dibaca dan bisa dites tanpa UI. Isian kosong, cuma spasi, atau cuma tag HTML ditolak (kayak `strip_tags` di Django), URL harus `http://` atau `https://`, dan tanggal selesai wajib dipilih kalau experience udah selesai serta nggak boleh lewat hari ini.
- Kartu "Tambah Experience" di halaman utama sekarang buka form pake `Navigator.push()`. Drawer dapet opsi "Add Experience" di samping Home dan Add Project, dan drawer yang sama dipake di halaman utama, form proyek, dan form experience.
- Setelah tombol Simpan ditekan dan semua input lolos, ringkasan isian muncul di `AlertDialog` dengan tombol Tutup buat balik ke form.
- Tambahan di luar checklist: saklar "Masih berlangsung" yang nyembunyiin/nampilin field tanggal, ikon di tiap input, penghitung karakter judul, keyboard URL buat thumbnail, dan layout yang dibatasi lebarnya biar rapi di Chrome.
- Test: `test/experience_form_test.dart` ngecek buka form dari kartu dan drawer, balik lewat Back dan Home, input kosong/spasi/tag/URL salah/tanggal kosong, sama isi dialog. `test/experience_validators_test.dart` ngetes tiap validator.

1. **Bedanya `push()`, `pushReplacement()`, `pop()`, dan gimana Home balik ke halaman utama**

   Awalnya aku kira tiga-tiganya sama aja, sama-sama buat pindah halaman. Ternyata `Navigator` itu nyimpen halaman kayak tumpukan. `push()` naruh halaman baru di atas tumpukan, jadi halaman lama masih ada di bawahnya. `pushReplacement()` ngeganti halaman paling atas sama halaman baru, jadi yang lama dibuang. Kalau `pop()`, halaman paling atas dibuang dan kita balik ke halaman di bawahnya.

   Buat kartu "Tambah Experience" aku pake `push()`, soalnya pas lagi ngisi form, user pasti pengen bisa balik ke menu pake tombol Back di HP atau browser. Opsi Home di drawer pake `pushReplacement()` ke `MyHomePage`, jadi halaman form yang lagi kebuka langsung diganti sama halaman utama. Pas aku cek lagi, ternyata ada efek sampingnya: kalau form dibuka dari kartu, tumpukannya jadi menu lama -> menu baru. Tampilannya tetep halaman utama, cuma ada satu menu lama nyangkut di bawah. Kalau form dibuka dari drawer, tumpukannya bersih karena dua-duanya pake `pushReplacement()`. Kalau nanti pengen bener-bener bersih dari mana pun, bisa ganti pake `Navigator.pushAndRemoveUntil()`.

2. **Gimana `Scaffold`, `AppBar`, dan `Drawer` bikin halaman konsisten**

   `Scaffold` itu kayak cetakan halaman. Udah ada tempat buat `AppBar` di atas, drawer di kiri, dan isi halaman di tengah. Karena halaman utama, form proyek, dan form experience sama-sama pake cetakan ini plus `LeftDrawer` yang sama, judul halaman sama tombol menu selalu ada di posisi yang sama. Enaknya lagi, waktu aku nambahin opsi "Add Experience", aku cukup ubah `LeftDrawer` sekali dan semua halaman langsung kebagian.

   Contoh warna tema yang aku pake di lebih dari satu halaman itu `colorScheme.primary`, yang asalnya dari seed color indigo di `main.dart`. Warna ini dipake buat `AppBar` di halaman utama, `AppBar` di form experience, sama tombol Simpan. Jadi kalau suatu saat aku ganti seed color-nya, semua bagian itu ikut berubah bareng tanpa harus diubah satu-satu.

3. **Kenapa layout form-nya kayak gitu**

   Form aku susun dari atas ke bawah pake `Column`, satu input per baris, biar urutannya enak dibaca kayak ngisi formulir biasa. Semua input sama tombol Simpan dibikin selebar form, tapi lebarnya aku batasin maksimal 560 biar nggak melar kebangetan pas dibuka di Chrome.

   Yang paling kerasa pas nyoba di layar ukuran HP: begitu keyboard muncul, ruang buat form jadi sempit banget. Kalau pake `Column` doang, bakal muncul error overflow dan tombol Simpan ketutup keyboard. Solusinya aku bungkus pake `SingleChildScrollView`, jadi form bisa di-scroll dan tombol Simpan tetep bisa dijangkau. Keyboard-nya juga otomatis nutup pas form di-scroll. Buat jarak, aku pake `SizedBox` di antara input dan `padding` di pinggir, biar pesan error di bawah satu kolom nggak nempel sama kolom berikutnya. `SafeArea` aku tambahin biar isi form nggak ketutup notch atau status bar HP.

4. **Peran `GlobalKey<FormState>`, `validator`, dan `validate()`**

   `GlobalKey<FormState>` itu pegangan buat widget `Form`, jadi dari tombol Simpan aku bisa ngakses form-nya. Tiap input punya `validator`, isinya aturan buat ngecek isian itu. Kalau aman, `validator` ngebalikin `null`. Kalau nggak, dia ngebalikin pesan error. Pas tombol Simpan ditekan, `validate()` jalanin semua `validator` sekaligus, nampilin pesan error di kolom yang salah, dan cuma ngebalikin `true` kalau semuanya lolos. Dialog ringkasan baru aku munculin kalau hasilnya `true`.

   Contoh isian yang ditolak itu URL thumbnail `bukan-url`. Kolom itu udah aku set pake keyboard URL, tapi itu cuma ngatur keyboard yang muncul di HP biar ada tombol `/` sama `.com`. User tetep bisa ngetik atau paste apa aja, dan di Chrome malah nggak ada keyboard khusus sama sekali. Makanya formatnya tetep harus dicek di `validator`. Hal yang sama berlaku buat judul yang isinya cuma spasi atau cuma tag kayak `<b></b>`. Kolom teks nerima input itu, tapi kalau spasi dan tag-nya dibuang, isinya kosong, jadi tetep ditolak.

#### Penggunaan AI

Aku pake Claude buat bantu Tugas 8. Strateginya sama kayak sebelumnya: Claude baca checklist Tugas 8 dan model `Experience` di proyek Django dulu, terus ngerjain perubahannya satu per satu dengan commit terpisah (form, navigasi, test, docs).

Bagian yang dibantu AI:
- nyusun `ExperienceFormPage` dan nyamain field serta kategorinya sama model Django;
- misahin validator ke `lib/utils/` dan nulis unit test-nya;
- nambahin kartu dan opsi drawer, serta widget test buat alur navigasinya;
- nyusun draf jawaban reflektif di atas.

Aku sendiri yang milih Experience sebagai bagian yang dibikin form-nya (nyambung sama Tugas 3–7), terus jalanin `flutter analyze`, `flutter test`, dan nyoba alur form di Chrome dengan ukuran layar HP.

Catatan keterbatasan AI dan perbaikan manual:
- Claude tetep nggak bisa jalanin Flutter di lingkungannya, jadi hasil analyze, test, dan tampilan dicek di laptopku.
- Waktu nulis test dialog, versi awal nyari teks ringkasan di seluruh layar. Itu bakal salah karena teks yang sama juga ada di TextFormField di belakang dialog. Test-nya dibenerin biar cuma nyari di dalam `AlertDialog`.
- Waktu nyusun jawaban nomor 1, Claude nunjukin kalau opsi Home pake `pushReplacement()` ninggalin satu halaman menu lama di stack kalau form dibuka dari kartu. Aku cek alurnya, terus aku tulis apa adanya di jawaban, bukan diklaim stack-nya selalu bersih.
