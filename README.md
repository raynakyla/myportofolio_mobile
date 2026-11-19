# MyPortfolio Mobile

MyPortfolio Mobile adalah aplikasi portofolio Flutter yang dimulai pada Tutorial
8 PBP, Tugas 7, dan Tutorial 9 di repositori mobile yang sama. Proyek ini
terpisah dari portofolio Django. Home memakai data statis, sedangkan form
Experience menyiapkan snapshot lokal dan menampilkannya dalam dialog ringkasan.
Belum ada koneksi API atau pengiriman data ke Django.

## Identitas

- **Nama:** Rayna Kayla Rayvanka
- **NPM:** 2506657283
- **Kelas:** PBP F

## Fitur yang Sudah Tersedia

- Tiga kartu informasi terpisah untuk nama, NPM, dan kelas.
- Tiga tombol menu: **Lihat Proyek**, **Tambah Experience**, dan **Logout**.
- SnackBar untuk Lihat Proyek dan Logout; Tambah Experience membuka form.
- Drawer Home dan form dengan navigasi tanpa menumpuk salinan halaman.
- Form Experience dengan validasi, kategori sesuai model Django lokal, dan
  tanggal/waktu UTC. Dialog ringkasan memakai snapshot data valid dan tetap
  mempertahankan isian setelah ditutup.
- Layout responsif untuk layar lebar dan layar sempit.
- Tema pastel dengan gradient, panel kaca transparan, sudut membulat, dan
  bayangan lembut.
- Playfair Display untuk heading serta brand, dan DM Sans untuk teks antarmuka.
  Kedua font dibundel secara lokal sehingga dapat digunakan tanpa koneksi
  internet.

Daftar proyek dan logout sungguhan belum diimplementasikan. Save pada form
Experience hanya memvalidasi dan menampilkan ringkasan lokal.

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
| `lib/main.dart` | Entry point, `MaterialApp`, dan konfigurasi tema serta font utama. |
| `lib/screens/home_page.dart` | Halaman Home beserta widget dan metadata kartu yang hanya dipakai Home. |
| `lib/screens/experience_form_page.dart` | Halaman Tambah Experience, state isian, validasi, dan aksi Save. |
| `lib/widgets/portfolio_drawer.dart` | Drawer dan pilihan navigasi yang dipakai kedua halaman. |
| `lib/widgets/experience_summary_dialog.dart` | Dialog ringkasan dari snapshot Experience yang sudah valid. |
| `lib/widgets/portfolio_glass_panel.dart` | Panel glass bersama untuk Home, form, drawer, dan dialog. |
| `lib/widgets/portfolio_glass_button.dart` | Tombol Save dan Tutup dengan state fokus, hover, dan tekan. |
| `lib/widgets/portfolio_background.dart` | Latar cream dengan orb pastel bersama untuk Home dan form. |
| `lib/models/experience_data.dart` | `ExperienceDraft` dan `ExperienceCategory`, tanpa dependensi widget Flutter. |
| `lib/theme/portfolio_colors.dart` | Palet warna bersama agar halaman dan widget tetap konsisten. |
| `assets/fonts/` | Menyimpan font Playfair Display dan DM Sans beserta lisensinya agar tipografi tersedia secara offline. |
| `test/widget_test.dart` | Tes Home, SnackBar, navigasi kartu/drawer, Back, dan layout responsif. |
| `test/experience_form_test.dart` | Tes validasi, snapshot ringkasan, retensi isian, scroll panjang, dan inset keyboard. |
| `pubspec.yaml` | Mendefinisikan metadata proyek, dependency, dan registrasi aset font beserta weight yang digunakan. |

`screens/` mengelompokkan halaman yang dibuka lewat Navigator; `widgets/`
menyimpan komponen antarmuka yang dipakai halaman; `models/` menyimpan data;
dan `theme/` menyimpan palet. Widget khusus Home tetap berada di file Home
karena belum dipakai halaman lain. Pada Tutorial 9 tahap 5, `menu.dart` dipindah
menjadi `screens/home_page.dart`, dan `portfolio_style.dart` dipisah menjadi
palet warna serta widget panel glass. Pemindahan ini tidak mengubah tampilan,
validasi, atau alur Navigator.

## Pemeriksaan Kode

Gunakan perintah berikut untuk menjalankan analisis statis dan seluruh widget
test:

```powershell
flutter analyze
flutter test
```

Seluruh 23 tes memeriksa Home, SnackBar, navigasi berulang lewat drawer,
Back, validasi form, isi ringkasan, dan retensi isian setelah dialog ditutup.
Pemeriksaan layout mencakup lebar 320, 390, dan 1280 px, deskripsi panjang,
teks diperbesar, serta inset keyboard. Preview Chrome melengkapi tes untuk
memeriksa tampilan dan interaksi langsung.

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

## Tutorial 9

Pada tahap ini saya melanjutkan Home dari Tugas 7 menjadi aplikasi yang bisa
berpindah halaman dan menerima isian Experience. Pengerjaannya bertahap:
halaman awal form, drawer, input dan validasi, ringkasan, perapian folder,
polish tampilan, lalu audit dan dokumentasi. Data masih lokal di halaman;
tombol Save belum mengirim apa pun ke Django.

### Sumber instruksi dan penyesuaian proyek

Saya memakai instruksi resmi **PBP Gasal 2026/2027**:

- [Tutorial 09: Flutter Navigation, Layouts, Forms, and Input Elements](https://pbp.cs.ui.ac.id/tutorial/tutorial-9.html).
- [Individual Assignment 8](https://pbp.cs.ui.ac.id/assignments/individual/tugas-8.html).

Keduanya sudah dibaca dari situs kampus. Halaman arsip `ganjil-2026` di GitHub
Pages adalah semester 2025/2026 dengan penomoran dan konteks tugas berbeda,
jadi bukan acuan untuk checklist di bawah ini.

Contoh Tutorial 9 memakai **Tambah Proyek**, sedangkan implementasi saya saat
ini memilih **Tambah Experience**. Ini sesuai topik Pengalaman yang dipilih
untuk form portofolio, tetapi belum berarti semua ketentuan tutorial dan
Tugas 8 sudah lengkap. Khususnya, Tugas 8 meminta opsi Home dan Add Project
dari tutorial tetap dipertahankan saat opsi form baru ditambahkan.

### Alur navigasi dan drawer

- Di Home, kartu **Tambah Experience** membuka `ExperienceFormPage` melalui
  `Navigator.push()` dan `MaterialPageRoute`. Home tetap berada di bawahnya.
- Drawer yang sama tersedia pada Home dan form. Ikon menu ada di kiri Home;
  pada form, Back tetap di kiri dan ikon menu ada di kanan.
- Memilih halaman yang sedang aktif hanya menutup drawer melalui
  `Scaffold.of(context).closeDrawer()`.
- Dari form, pilihan Home memakai `popUntil((route) => route.isFirst)` untuk
  kembali ke Home yang sudah ada. Dengan begitu, bolak-balik lewat drawer
  tidak membuat banyak salinan halaman.
- Back saat drawer terbuka menutup drawer terlebih dahulu. Back dari form
  kembali ke Home. `Navigator.pop()` pada dialog hanya menutup dialog.

Isian tetap ada ketika drawer ditutup atau dialog ditutup. Jika pengguna
keluar dari form ke Home lalu membuka form lagi, halaman dan state form baru
dibuat; isian lama tidak disimpan sebagai draft permanen.

### Input dan validasi

Field mengikuti model `Experience` pada proyek Django lokal
`C:\myportofolio\main\models.py` yang diperiksa saat implementasi:

| Input | Aturan saat ini |
| --- | --- |
| Judul | Wajib setelah `trim()`, maksimal 255 karakter. |
| Deskripsi | Wajib setelah `trim()`; boleh beberapa baris. |
| Kategori | Wajib memilih Career, Organizations, Community, Competition, Personal Project, atau Certification. |
| URL thumbnail | Opsional; jika diisi harus URL HTTP/HTTPS yang valid, maksimal 200 karakter. |
| Tanggal mulai | Opsional, dengan format `YYYY-MM-DD HH:mm` dalam UTC. Tersedia pemilih tanggal dan waktu. |
| Masih berlangsung | Aktif secara default. Mengaktifkannya mengosongkan dan menonaktifkan tanggal akhir. |
| Tanggal akhir | Diperlukan jika status masih berlangsung dimatikan. Harus tanggal/waktu valid dan tidak boleh sebelum tanggal mulai jika tanggal mulai diisi. |

Di model Django, nama field URL adalah `thumbnail`, bukan `thumbnail_url`.
`started_at` pada versi model yang diperiksa sudah opsional, bukan lagi
`auto_now_add`. `is_ongoing` merupakan properti yang dihitung dari kosongnya
`ended_at`, sehingga snapshot Flutter juga menghitungnya dengan cara itu.

`GlobalKey<FormState>` dibuat sekali di state halaman. Saat Save ditekan,
`validateGranularly()` menjalankan validator dan mengembalikan field yang
bermasalah. Halaman digulir ke error pertama. Jika semuanya valid, teks
dirapikan di snapshot `ExperienceDraft` dan ringkasan dibuka. Controller form
tidak dikosongkan. Jika isian diedit lagi, snapshot lama ditandai tidak berlaku
dan Save berikutnya menyiapkan snapshot baru.

Label tetap terlihat saat field terisi. Field disusun satu kolom dalam panel
dengan lebar maksimum 720 px; `SingleChildScrollView` membuat bagian bawah
form dan Save tetap bisa dijangkau ketika ruang berkurang. Warna, font lokal,
panel glass, latar, dan tombol aksi dipakai bersama agar tampilannya konsisten.

### Dialog ringkasan

Setelah validasi berhasil, `showDialog()` membuka **Ringkasan Experience**.
Isinya berasal dari snapshot yang baru dibuat: judul, deskripsi, label kategori,
URL thumbnail, tanggal mulai, status berlangsung, dan tanggal akhir. Nilai
opsional kosong ditulis **Tidak diisi**, sedangkan tanggal akhir pengalaman
yang masih berlangsung ditulis **Belum berakhir — masih berlangsung**.
Tanggal yang terisi memakai format `YYYY-MM-DD HH:mm UTC`.

Dialog menggunakan panel glass yang cukup opak. Kontennya bisa digulir dan
tombol Tutup berada di luar area gulir. Setelah dialog ditutup, pengguna bisa
memeriksa atau mengoreksi isian yang sama. Tulisan preview lokal menjelaskan
bahwa data belum dikirim ke server; tidak ada klaim berhasil tersimpan di Django.

### Cara mencoba

1. Jalankan `flutter pub get`, lalu `flutter run -d chrome` dari folder proyek.
2. Dari Home, buka kartu Tambah Experience. Coba Back, lalu buka form dari
   drawer. Ulangi perpindahan Home dan form beberapa kali.
3. Tekan Save tanpa mengisi apa pun. Error judul, deskripsi, dan kategori
   harus muncul, tanpa dialog.
4. Coba judul berisi spasi saja, URL `bukan-url`, tanggal `2026-02-30 10:00`,
   atau tanggal akhir sebelum tanggal mulai. Periksa error di field terkait.
5. Isi judul dan deskripsi, pilih kategori, lalu biarkan pilihan opsional kosong
   dengan status Masih berlangsung aktif. Save harus menampilkan ringkasan.
6. Tutup dialog dan pastikan isian masih sama. Coba matikan Masih berlangsung,
   isi tanggal mulai/akhir UTC yang valid, lalu Save lagi.
7. Masukkan deskripsi beberapa paragraf. Coba pada lebar 390 px dan 1280 px,
   gulir isi dialog sampai bawah, dan pastikan Tutup tetap terjangkau.
8. Gunakan Tab/Shift+Tab dan Enter untuk memeriksa fokus keyboard. Di desktop,
   coba hover dan klik Save; di HP, periksa form saat keyboard nyata tampil.

### Audit terhadap instruksi semester ini

| Butir | Hasil pemeriksaan kode |
| --- | --- |
| Halaman baru di `screens/`, memakai StatefulWidget, Form, dan GlobalKey | Sudah ada pada ExperienceFormPage. |
| Minimal tiga input sesuai model dengan validasi | Sudah ada, termasuk penolakan spasi, batas judul/URL, dan hubungan tanggal/status. |
| Kartu Home membuka form memakai `Navigator.push()` | Sudah ada untuk Tambah Experience. |
| Drawer bersama, opsi aktif, Home, dan akses form | Sudah ada untuk Home dan Tambah Experience; navigasi berulang diuji. |
| Form/opsi Add Project dari Tutorial 9 tetap ada saat Experience ditambahkan | **Belum terpenuhi.** Kartu Tambah Proyek diganti menjadi Tambah Experience pada tahap 1, dan form Project belum dibuat. |
| Kartu aksi dipisah ke `widgets/` sesuai bagian refactor/rubrik | **Belum terpenuhi secara literal.** ItemCard dan metadata kartu masih bersama Home karena belum dipakai halaman lain. |
| Save memvalidasi sebelum menampilkan semua data | Sudah berjalan. Kode memakai `validateGranularly()`, bukan pemanggilan literal `validate()`, untuk sekaligus menemukan error pertama. |
| Ringkasan melalui `showDialog()` dan tombol penutup | Sudah berjalan, tetapi widget yang dipakai adalah Dialog khusus, bukan AlertDialog yang disebut instruksi. Ini perlu diperhatikan bila penilaian mensyaratkan widget literal. |
| Reset setelah dialog pada contoh tutorial | Penyesuaian UX: form sengaja dipertahankan sesuai arahan proyek ini. |
| Tidak ada TODO pada kode aplikasi | Sudah diperiksa pada `lib/`; tidak ada TODO implementasi yang tersisa. |
| Analisis, pengujian, dokumentasi, dan pengungkapan AI | Hasil pemeriksaan dicatat di bawah; refleksi Tugas 8 dan pengungkapan Tutorial 9 ditambahkan tanpa menghapus bagian lama. |
| Commit/push publik dan tautan commit di SCELE sesuai tenggat | **Belum diverifikasi.** Audit lokal tidak membuktikan status pengumpulan, waktu push, atau akses publik repositori. Commit/push tahap ini dilakukan sendiri oleh pemilik proyek. |

Tutorial 9 merupakan prasyarat Tugas 8. Instruksi resminya mencantumkan tenggat
Tutorial 9 pada 18 November 2026 pukul 23.59 WIB dan Tugas 8 pada 23 November
2026 pukul 23.59 WIB. Status pengumpulan tidak disimpulkan dari hasil tes lokal.
Bagian yang belum terpenuhi di atas dicatat, bukan diam-diam dianggap selesai
atau diubah menjadi fitur baru di luar audit tahap ini.

### Hasil pengecekan dan batas implementasi

Polish tahap 6 sudah tersimpan dalam commit
`30a0ac2` (`style: unify pastel glass portfolio UI and interactions`). Pada awal
audit tahap 7, branch aktif `task/tutorial-9` dan working tree bersih.

- Tes otomatis sebelumnya: 23 tes lulus, termasuk lebar 320/390/1280 px,
  teks 200%, inset keyboard, fokus keyboard, input salah/valid, dialog panjang,
  serta retensi isian. Pemeriksaan tersebut bukan pengganti keyboard HP nyata.
- Audit visual Chrome tahap 7: hasil akhirnya akan dicatat setelah pemeriksaan
  langsung build terbaru selesai; hasil tahap 6 yang terhenti tidak dianggap
  sebagai bukti pemeriksaan visual build terbaru.
- Belum ada API, autentikasi, database, penyimpanan lintas sesi, atau daftar
  Experience yang diperbarui setelah Save. Lihat Proyek dan Logout masih SnackBar.
- Keyboard mobile nyata dan perilaku Back sistem Android/iOS tetap memerlukan
  pengujian pada perangkat atau emulator yang sesuai.

## Riwayat dan Refleksi

- **Tutorial 8.** Proyek Flutter dibuat di repositori mobile ini. Halaman utama
  dipisahkan ke `menu.dart` (sekarang `lib/screens/home_page.dart`), lalu diisi
  identitas, tiga aksi dengan SnackBar, dan font lokal.
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
   `lib/screens/home_page.dart`. Keduanya memakai `package:flutter/material.dart`,
   dan `main.dart` juga mengimpor `screens/home_page.dart`.

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
     untuk mencoba perubahan padding atau warna kartu di `screens/home_page.dart` saat
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

### Tugas 8

Jawaban ini mengikuti empat pertanyaan refleksi pada
[instruksi Tugas 8 Gasal 2026/2027](https://pbp.cs.ui.ac.id/assignments/individual/tugas-8.html),
bukan daftar pertanyaan dari arsip semester sebelumnya.

1. **Bagaimana perpindahan halaman bekerja di aplikasi saya?**

   `Navigator.push()` menambahkan halaman di atas tumpukan yang sudah ada.
   Saya memakainya ketika kartu Tambah Experience membuka form, sehingga Home
   masih ada di bawahnya dan bisa dituju lagi dengan Back. `pushReplacement()`
   mengganti halaman teratas; metode ini tidak dipakai dalam alur aplikasi saya
   saat ini. Contoh kegunaannya nanti adalah mengganti halaman login setelah
   login selesai, tetapi login tersebut belum diimplementasikan.

   `pop()` melepas halaman atau dialog teratas. Pada Ringkasan Experience,
   `pop()` hanya menutup dialog, jadi pengguna kembali ke form dengan isian yang
   sama. Pilihan Home di drawer memakai `popUntil((route) => route.isFirst)`,
   bukan membuat Home baru. Drawer ditutup terlebih dahulu; jika pengguna
   memilih halaman yang sudah aktif, cukup drawer-nya yang ditutup.

2. **Apa yang membuat kerangka dan tema halaman tetap konsisten?**

   Home dan form sama-sama memakai `Scaffold` sebagai kerangka. `AppBar`
   menyediakan judul dan tombol navigasi, sedangkan properti `drawer` memasang
   `PortfolioDrawer` yang sama di kedua halaman. Form tetap memiliki Back di
   kiri dan tombol drawer di kanan. Dengan susunan ini, pengguna tetap tahu
   sedang berada di halaman mana dan bagaimana kembali.

   Sebagai contoh, `PortfolioColors.cream` dipakai untuk latar dan AppBar,
   sedangkan icy pink dipakai pada panel serta aksi utama di beberapa halaman.
   `PortfolioBackground`, `PortfolioGlassPanel`, dan `PortfolioGlassButton`
   menghindarkan tiap halaman dari membuat gaya sendiri-sendiri. Heading
   memakai Playfair Display dan antarmuka memakai DM Sans dari aset lokal.

3. **Mengapa formulir disusun satu kolom dan bisa digulir?**

   Saya memilih satu kolom supaya urutan pengisian jelas di HP. Di desktop,
   lebarnya dibatasi 720 px agar field tidak terlalu melebar. `Padding` memberi
   ruang dari tepi layar dan panel, sedangkan `SizedBox` memisahkan judul,
   field, kelompok waktu/status, dan tombol Save.

   `Column` sendiri tidak bisa digulir, jadi form dibungkus
   `SingleChildScrollView`. Ketika ruang berkurang karena keyboard, bagian bawah
   tetap bisa dijangkau; drag juga bisa menutup keyboard. Drawer memakai
   `ListView` agar pilihan navigasi bisa digulir jika ruangnya sempit. Dialog
   memakai `Flexible` dan `SingleChildScrollView` untuk kontennya, sementara
   tombol Tutup diletakkan di luar area gulir agar tidak ikut tersembunyi di
   bawah deskripsi panjang.

4. **Bagaimana key form dan validator bekerja saat Save ditekan?**

   `GlobalKey<FormState>` menjadi pegangan ke state satu form dan dibuat sebagai
   field state halaman, bukan dibuat ulang setiap `build()`. Tiap `validator`
   mengembalikan pesan ketika nilai salah atau `null` jika lolos. Pemanggilan
   `validate()` pada instruksi bertujuan menjalankan pemeriksaan semua field.
   Implementasi saya menggunakan `validateGranularly()`, yang juga menjalankan
   validator tetapi sekaligus mengembalikan kumpulan field yang bermasalah,
   sehingga error pertama bisa dibawa ke layar.

   Contohnya, judul berisi spasi saja ditolak karena setelah `trim()` nilainya
   kosong. `2026-02-30 10:00` juga ditolak walaupun format tulisannya terlihat
   seperti tanggal. Memilih keyboard URL atau tanggal hanya membantu cara
   mengetik; pengguna tetap bisa menempelkan nilai yang salah, sehingga tipe
   keyboard tidak menggantikan validasi. Jika masih ada error, dialog tidak
   dibuka. Jika semua valid, Save membuat `ExperienceDraft` dari nilai yang
   dirapikan lalu membuka ringkasan lokal. Itu belum berarti data tersimpan di
   Django.

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

### Bantuan AI pada Tutorial 9

Untuk Tutorial 9 saya memakai ChatGPT untuk membantu menyiapkan arahan dan
Codex untuk mengerjakan perubahan langsung pada repositori. Saya menentukan
urutan tahap, arah desain, batas perubahan, serta keputusan untuk melakukan
commit/push sendiri. Codex membantu membaca kode, membuat halaman dan drawer,
menulis input/validator serta dialog, merapikan folder/import, memoles widget
dan tema, menambahkan tes, lalu menyusun dokumentasi berdasarkan kode dan
instruksi resmi yang bisa diakses.

Ringkasan log prompt yang dipakai:

1. Koreksi baseline: hasil Tugas 7 baru memiliki Home; buat navigasi ke halaman
   awal Tambah Experience dan Back.
2. Tambahkan drawer bersama tanpa menumpuk salinan Home atau form.
3. Periksa model Django lokal, lalu buat field dan validasi yang sesuai;
   siapkan data valid di state tanpa mengirim ke server.
4. Tampilkan snapshot valid dalam dialog ringkasan dan pertahankan isian
   setelah dialog ditutup.
5. Kelompokkan halaman, widget, data, dan tema; perbarui import tanpa mengubah
   perilaku.
6. Samakan UI pastel glass, font lokal, aksesibilitas, dan state interaksi;
   periksa dengan analisis serta tes.
7. Audit build terbaru di Chrome, baca sumber resmi semester ini, cocokkan
   checklist, lalu perbarui README dan refleksi dengan batas yang jujur.

Ini adalah ringkasan arahan dari percakapan pengerjaan, bukan tautan transkrip
chat lengkap yang sudah dipublikasikan. Atribusi Tutorial 8 dan Tugas 7 di atas
tetap dipertahankan.

Ada koreksi yang penting selama prosesnya. Prompt awal sempat menganggap
drawer dan form sudah ada, padahal baseline baru Home; asumsi itu dikoreksi
sebelum fitur dibuat. Pencarian sumber juga sempat menemukan arsip 2025/2026,
lalu sumber diganti ke situs resmi 2026/2027 setelah tautan yang benar diketahui.
Karena itu, hasil AI tidak langsung dianggap sebagai bukti bahwa seluruh
checklist tugas sudah terpenuhi.

Validasi dan navigasi diperiksa dengan tes otomatis, tetapi tes tidak
membuktikan tampilan Chrome atau keyboard HP nyata sudah diperiksa. Pemeriksaan
visual tahap 6 terhenti ketika kontrol komputer dihentikan dengan Escape;
hasil itu tidak ditulis sebagai pemeriksaan visual yang selesai. Audit tahap 7
dicatat terpisah sesuai hasil yang benar-benar diamati. Selisih terhadap contoh
Project, struktur kartu aksi, dan widget/API literal juga dicatat pada checklist,
bukan ditutupi dengan klaim bahwa semua syarat sudah selesai.

## Referensi Flutter

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
