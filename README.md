# MyPortfolio Mobile

MyPortfolio Mobile adalah aplikasi portofolio Flutter yang dimulai pada Tutorial
8 PBP dan dilanjutkan pada Tugas 7 di repositori mobile yang sama. Proyek ini
terpisah dari portofolio Django. Halaman utamanya memakai data statis tanpa
koneksi API dan berisi tiga kartu identitas serta tiga kartu aksi yang
menampilkan SnackBar.

## Identitas

- **Nama:** Rayna Kayla Rayvanka
- **NPM:** 2506657283
- **Kelas:** PBP F

## Fitur yang Sudah Tersedia

- Tiga kartu informasi terpisah untuk nama, NPM, dan kelas.
- Tiga tombol menu: **Lihat Proyek**, **Tambah Proyek**, dan **Logout**.
- SnackBar dengan pesan yang menyesuaikan tombol yang ditekan.
- Layout responsif untuk layar lebar dan layar sempit.
- Tema pastel dengan gradient, panel kaca transparan, sudut membulat, dan
  bayangan lembut.
- Playfair Display untuk heading serta brand, dan DM Sans untuk teks antarmuka.
  Kedua font dibundel secara lokal sehingga dapat digunakan tanpa koneksi
  internet.

Ketiga tombol menu saat ini baru menampilkan SnackBar. Navigasi ke daftar
proyek, proses menambahkan proyek, dan logout sungguhan belum diimplementasikan.

## Prasyarat

Sebelum menjalankan aplikasi, pastikan perangkat sudah memiliki:

- Flutter SDK channel stable;
- Git; dan
- Google Chrome untuk target web.

Android SDK juga diperlukan jika aplikasi ingin dijalankan pada emulator atau
perangkat Android.

## Menjalankan Aplikasi

Buka PowerShell di Windows. Pastikan perintah `flutter` dikenali, masuk ke folder
yang berisi `pubspec.yaml`, lalu ambil dependensi dan jalankan aplikasi di Chrome.

```powershell
Set-Location C:\myportofolio_mobile
flutter --version
flutter pub get
flutter run -d chrome
```

Dokumentasi resmi Flutter dapat dibaca di
[docs.flutter.dev](https://docs.flutter.dev/).

## Struktur Penting

| Lokasi | Fungsi |
| --- | --- |
| `lib/main.dart` | Entry point aplikasi serta tempat konfigurasi `MaterialApp`, Material 3, warna, dan font utama. |
| `lib/menu.dart` | Berisi halaman utama, model `ItemHomepage`, `InfoCard`, `ItemCard`, layout responsif, dan logika SnackBar. |
| `assets/fonts/` | Menyimpan font Playfair Display dan DM Sans beserta lisensinya agar tipografi tersedia secara offline. |
| `test/widget_test.dart` | Widget test untuk identitas pemilik, ketiga tombol menu, SnackBar, dan layout pada viewport selebar 320 px. |
| `pubspec.yaml` | Mendefinisikan metadata proyek, dependency, dan registrasi aset font beserta weight yang digunakan. |

## Pemeriksaan Kode

Gunakan perintah berikut untuk menjalankan analisis statis dan seluruh widget
test:

```powershell
flutter analyze
flutter test
```

Tes yang tersedia memeriksa identitas pemilik, ketiga tombol, pesan SnackBar
untuk tiap aksi, dan layout selebar 320 px. Preview Chrome melengkapi tes
untuk memeriksa tampilan dan interaksi langsung.

## Font dan Lisensi

Tipografi aplikasi mobile menggunakan font open source dari repositori resmi
Google Fonts. Pilihan ini merupakan penyesuaian visual baru untuk aplikasi
mobile dan bukan font asli yang digunakan oleh situs Django.

- [Playfair Display](https://github.com/google/fonts/tree/main/ofl/playfairdisplay)
  dipakai untuk hero heading, judul bagian, dan brand. Lisensi lengkapnya ada
  di [assets/fonts/playfair_display/OFL.txt](assets/fonts/playfair_display/OFL.txt).
- [DM Sans](https://github.com/google/fonts/tree/main/ofl/dmsans) dipakai untuk
  body, informasi, tombol, label, dan SnackBar. Lisensi lengkapnya ada di
  [assets/fonts/dm_sans/OFL.txt](assets/fonts/dm_sans/OFL.txt).

Kedua font menggunakan SIL Open Font License 1.1. Catatan detail aset dan weight
yang digunakan tersedia di [assets/fonts/README.md](assets/fonts/README.md).

## Riwayat dan Refleksi

- **Tutorial 8.** Proyek Flutter dibuat di repositori mobile ini. Halaman utama
  dipisahkan ke `lib/menu.dart`, lalu diisi identitas, tiga aksi dengan SnackBar,
  dan font lokal.
- **Tugas 7.** Layout ponsel dirapatkan supaya aksi pertama lebih mudah terlihat.
  Di desktop, tepi AppBar, hero, dan grid disejajarkan. Kartu aksi bisa bertambah
  tinggi saat teks membungkus. Tema kaca pastel diperhalus dengan permukaan icy
  pink, butter yellow, dan lavender serta umpan balik hover, tekan, dan fokus
  keyboard.

### Tugas 7

1. **Apa itu widget tree dan bagaimana hubungan parent–child bekerja?**

   Widget tree adalah susunan widget yang menjelaskan bagaimana antarmuka
   dibentuk. Saya membacanya mulai dari `runApp(const MyApp())`. `MyApp`
   membangun `MaterialApp`, yang memakai `MyHomePage` sebagai `home`.
   `MyHomePage` lalu membangun `Scaffold` dengan `AppBar` di atas dan
   `Stack` sebagai isi halaman.

   Parent menyusun dan memberi batas ruang ke child. Misalnya, di dalam
   `ItemCard`, `Row` menyusun kotak ikon, label, dan panah secara mendatar.
   `Expanded` memberi label sisa lebar yang tersedia sehingga teks bisa
   membungkus saat ukuran font diperbesar. Widget seperti `Padding` menerima
   satu `child`, sedangkan `Row` dan `Column` menerima daftar `children`.
   [Panduan antarmuka Flutter](https://docs.flutter.dev/ui)

2. **Widget apa saja yang dipakai di aplikasi ini?**

   Daftar ini mengikuti konstruktor widget di `lib/main.dart` dan
   `lib/menu.dart`. Keduanya memakai `package:flutter/material.dart`, dan
   `main.dart` juga mengimpor `menu.dart`.

   **Widget buatan proyek**

   - `MyApp` membangun aplikasi dan mengatur tema serta halaman awal.
   - `MyHomePage` menyusun AppBar, latar, hero, dan menu aksi.
   - `_HeroCard` membungkus sapaan, bio, dan bagian identitas.
   - `_PastelOrb` menggambar aksen gradasi bulat di latar.
   - `InfoCard` menampilkan satu pasangan label dan nilai, misalnya NPM.
   - `ItemCard` membangun satu kartu aksi dari data `ItemHomepage`.

   **Widget Flutter untuk tampilan dan interaksi**

   - `MaterialApp` menyiapkan aplikasi Material, tema, dan halaman awal.
   - `Scaffold` menyediakan kerangka halaman dengan slot `appBar` dan `body`.
   - `AppBar` menampilkan tulisan “Rayna.” dan “MYPORTFOLIO” di bagian atas.
   - `Text` menampilkan judul, bio, identitas, label menu, dan pesan.
   - `Icon` menampilkan ikon aksi dan panah pada kartu.
   - `OutlinedButton` menangani aktivasi kartu dan memberi umpan balik saat
     diarahkan, ditekan, atau mendapat fokus keyboard.
   - `SnackBar` menampilkan pesan singkat yang mengambang ketika aksi dipilih.

   **Widget Flutter untuk layout dan dekorasi**

   - `Stack` menumpuk gradasi latar, ornamen, dan konten halaman.
   - `Positioned` menempatkan ornamen di dalam `Stack`, sedangkan
     `Positioned.fill` membuat latar gradasi mengisi area `Stack`.
   - `DecoratedBox` melukis gradasi dan bayangan, misalnya pada hero dan kartu
     aksi.
   - `Container` menggabungkan ukuran, padding, dan dekorasi, misalnya pada
     AppBar dan kartu identitas.
   - `IgnorePointer` membuat ornamen latar mengabaikan input pointer.
   - `SafeArea` memberi jarak aman dari area sistem, seperti indikator navigasi.
   - `SingleChildScrollView` membuat isi halaman bisa digulir secara vertikal
     saat ruangnya kurang.
   - `Padding` memberi jarak di sekeliling konten utama.
   - `Center` memusatkan isi AppBar dan blok konten secara horizontal.
   - `ConstrainedBox` membatasi ukuran, misalnya lebar maksimum konten dan
     tinggi minimum kartu aksi.
   - `Column` menyusun isi halaman atau isi kartu identitas secara vertikal.
   - `Row` menyusun elemen secara horizontal, misalnya ikon, label, dan panah.
   - `SizedBox` memberi jarak antarelemen atau menentukan ukuran tertentu.
   - `Expanded` membagi sisa ruang di dalam `Row`, misalnya untuk label aksi.
   - `LayoutBuilder` membaca batas ukuran dari parent untuk menentukan susunan
     kartu identitas dan jumlah kolom menu.
   - `Wrap` menata kartu dalam beberapa baris sesuai lebar yang tersedia.

   `ItemHomepage` adalah model data untuk nama, ikon, dan warna kartu.
   `ThemeData` dan `BoxDecoration` adalah konfigurasi tampilan. Kode mengakses
   `MediaQuery` dan `ScaffoldMessenger` melalui metode yang menerima
   `context`. Pembahasan cara memakainya ada di jawaban nomor 5.

3. **Apa fungsi `MaterialApp` dan mengapa sering dipakai di akar aplikasi?**

   `MaterialApp` menyiapkan hal-hal yang dipakai bersama oleh halaman Material,
   seperti tema, navigasi dasar, dan `ScaffoldMessenger` untuk SnackBar.
   Karena pengaturan ini dipakai oleh widget di bawahnya, masuk akal untuk
   menaruhnya dekat akar aplikasi. Di proyek ini, `MyApp` adalah widget yang
   diberikan ke `runApp()`, dan hasil `build()`-nya adalah `MaterialApp`.

   Di `main.dart`, `useMaterial3: true` mengaktifkan Material 3. Skema warna
   pastel dan font utama DM Sans ditetapkan di `ThemeData`, lalu `home`
   memilih `MyHomePage` sebagai halaman awal. Widget seperti
   `Scaffold` dan `OutlinedButton` mendapat pengaturan Material dari sana.
   Judul tertentu memilih Playfair Display lewat `TextStyle` di halaman.
   [Dokumentasi MaterialApp](https://api.flutter.dev/flutter/material/MaterialApp-class.html)

4. **Kapan memakai `StatelessWidget` dan `StatefulWidget`?**

   Saya memakai `StatelessWidget` jika tampilan bisa dibangun dari data yang
   diterima dan kondisi di sekitarnya. Contohnya, `InfoCard` menerima label
   dan nilai, lalu menyesuaikan padding dengan lebar layar. Widget stateless
   bisa dibangun ulang saat konfigurasinya atau data yang dibacanya dari
   `context` berubah.

   `StatefulWidget` cocok jika tampilan perlu menyimpan data yang berubah
   selama widget masih aktif. Misalnya, jika nanti ada formulir proyek dengan
   isian yang berubah, nilai lokalnya bisa disimpan di objek `State` terpisah.
   `setState()` memberi tahu Flutter untuk membangun ulang bagian tersebut
   setelah state berubah.

   `MyHomePage` tetap stateless karena identitas dan daftar menunya tetap.
   Ketika kartu ditekan, callback `onPressed` pada `ItemCard` meminta
   `ScaffoldMessenger` menampilkan SnackBar. Pengelolaan pesan dilakukan oleh
   `ScaffoldMessenger`, dan umpan balik tekan serta fokus ditangani oleh
   `OutlinedButton`. Halaman bisa merespons pengguna tanpa menyimpan state
   lokal sendiri. [StatelessWidget](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html)
   · [StatefulWidget](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html)

5. **Apa itu `BuildContext` dan bagaimana dipakai di `build()`?**

   `BuildContext` adalah pegangan ke posisi widget di dalam widget tree.
   Posisi ini penting karena Flutter bisa mencari informasi atau layanan dari
   ancestor widget tersebut. Parameter `context` pada `build()` menunjuk ke
   widget yang sedang membangun bagian antarmukanya.

   Di `MyHomePage.build()`, `MediaQuery.sizeOf(context).width` dipakai untuk
   memilih padding dan tinggi AppBar saat lebar layar di bawah 600 piksel logis.
   Di `_HeroCard`, `MediaQuery.textScalerOf(context)` membantu menentukan
   apakah NPM dan kelas masih muat berdampingan. Saat tombol ditekan,
   `ScaffoldMessenger.of(context)` memakai context dari `ItemCard.build()`
   untuk menemukan messenger di atasnya. Callback kemudian menghapus
   SnackBar aktif dan menampilkan pesan yang baru.
   [Dokumentasi BuildContext](https://api.flutter.dev/flutter/widgets/BuildContext-class.html)

6. **Apa bedanya hot reload, hot restart, dan full restart?**

   - **Hot reload** memuat perubahan kode Dart dan membangun ulang widget
     sambil mempertahankan state yang sedang berjalan. `main()` dan
     `initState()` pada state yang sudah ada tidak dipanggil ulang. Ini cocok
     untuk mencoba perubahan padding atau warna kartu di `menu.dart` saat
     aplikasi sedang berjalan dalam mode debug.
   - **Hot restart** memulai ulang aplikasi Flutter dari `main()` dan
     menghapus state di memori. Saat objek `State` baru dibuat dan dipasang,
     `initState()`-nya dijalankan. Kode aplikasi di `lib/` belum punya
     implementasi `initState()`. Contoh yang relevan untuk proyek ini adalah
     mengganti widget yang diberikan ke `runApp()` di `main()`.
   - **Full restart** berarti menghentikan aplikasi lalu menjalankan
     `flutter run` lagi. Ini diperlukan, misalnya, untuk melihat perubahan
     kode Kotlin di `MainActivity.kt` saat menjalankan target Android.
     [Dokumentasi hot reload Flutter](https://docs.flutter.dev/tools/hot-reload)

## Penggunaan AI

ChatGPT membantu menjelaskan tugas dan konsep Flutter serta menyiapkan prompt
pengerjaan bertahap. Pada Tutorial 8, Codex ikut mengerjakan refactor,
implementasi tampilan, dan pengujian. Pada Tugas 7, Codex memeriksa repositori,
menyiapkan branch, mengedit kode layout responsif dan tampilan kaca sesuai
arahan desain saya, mengaudit hasil terhadap checklist, dan membantu menyusun
refleksi README berdasarkan kode serta dokumentasi Flutter.

Hasilnya diperiksa dengan `flutter analyze --no-pub` tanpa temuan dan
`flutter test --no-pub` dengan tiga tes lulus, termasuk tes pesan setiap aksi.
Preview Chrome diperiksa pada 320 × 640, 1440 × 900, dan skala teks 200% di
layar sempit. Preview juga dipakai untuk mengecek warna kartu, fokus keyboard,
dan ketiga pesan SnackBar.

**Ringkasan prompt untuk Codex**

- Audit baseline Tutorial 8 dan siapkan branch Tugas 7.
- Rapikan layout di layar sempit dan desktop, lalu perhalus tampilan kaca
  pastel serta umpan balik interaksi kartu.
- Cocokkan implementasi dengan checklist Tugas 7, lalu susun jawaban refleksi
  dengan contoh dari kode yang benar-benar dipakai.

## Referensi Flutter

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
