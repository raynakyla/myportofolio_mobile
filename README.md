# MyPortfolio Mobile

MyPortfolio Mobile adalah aplikasi portofolio Flutter yang dimulai pada Tutorial
8 PBP, Tugas 7, Tutorial 09, dan Tugas Individu 8 semester 2026/2027 di repositori
mobile yang sama. Proyek ini terpisah dari portofolio Django. Home memakai data
statis, sedangkan form Project dan Experience menyiapkan snapshot lokal dan
menampilkannya dalam dialog ringkasan. Daftar dan detail Project membaca API
Django pada Tutorial 10. Save belum menyimpan data ke Django dan belum ada
penyimpanan lintas sesi di aplikasi.

Mulai dari [panduan menjalankan aplikasi](#menjalankan-aplikasi), lihat
[struktur penting](#struktur-penting), atau baca [refleksi Tugas 8](#tugas-8).

## Identitas

- **Nama:** Rayna Kayla Rayvanka
- **NPM:** 2506657283
- **Kelas:** PBP F

## Fitur yang Sudah Tersedia

- Tiga kartu informasi terpisah untuk nama, NPM, dan kelas.
- Empat tombol menu: **Lihat Proyek**, **Tambah Experience**, **Tambah Project**,
  dan **Login/Logout**, mengikuti status sesi.
- Lihat Proyek membuka daftar/detail publik. Tambah Project meminta login;
  Tambah Experience tetap membuka preview lokal tanpa login.
- Drawer bersama berisi Home, Lihat Proyek, Tambah Experience, dan Tambah Project, dengan
  navigasi tanpa menumpuk salinan halaman.
- Form Experience dengan validasi, kategori sesuai model Django lokal, dan
  tanggal/waktu UTC. Dialog ringkasan memakai snapshot data valid dan tetap
  mempertahankan isian setelah ditutup.
- Form Project dengan judul, deskripsi, kategori, peran, dan keahlian yang
  wajib diisi. Kedua form menampilkan hasil valid dalam `AlertDialog` dengan
  tombol Tutup untuk kembali ke form.
- Layout responsif untuk layar lebar dan layar sempit.
- Tema pastel dengan gradient, panel kaca transparan, sudut membulat, dan
  bayangan lembut.
- Playfair Display untuk heading serta brand, dan DM Sans untuk teks antarmuka.
  Kedua font dibundel secara lokal sehingga dapat digunakan tanpa koneksi
  internet.

Login/logout memakai API Django dan sesi dalam memori. Save pada form
Project maupun Experience hanya memvalidasi dan menampilkan ringkasan lokal.

## Prasyarat

Sebelum menjalankan aplikasi, pastikan perangkat sudah memiliki:

- Flutter SDK channel stable dengan Dart yang memenuhi `sdk: ^3.13.7` pada
  `pubspec.yaml` (minimal Dart 3.13.7 dan di bawah 4.0.0). Perintah `flutter`
  harus tersedia di `PATH`;
- Git yang bisa dipanggil dari terminal; dan
- Google Chrome untuk target web.

Koneksi internet diperlukan untuk clone dan mengambil dependensi pertama kali.
Font sudah ada di aset lokal. Repositori atau server Django tidak diperlukan
untuk mencoba kedua form pada tahap preview ini.

Android SDK juga diperlukan untuk pengujian pada emulator atau perangkat Android.
Keberadaan folder `android/` belum berarti SDK di komputer pembaca sudah siap;
ikuti langkah Android opsional di bawah jika toolchain belum dikonfigurasi.

## Menjalankan Aplikasi

Buka **Command Prompt (CMD)** di Windows. Blok perintah pada bagian ini bisa
disalin ke CMD; contoh clone menggunakan folder pengguna agar tidak bergantung
pada lokasi proyek di komputer saya.

1. Pastikan Git dan Flutter dikenali, lalu baca hasil pemeriksaan toolchain.

   ```bat
   git --version
   flutter --version
   flutter doctor
   ```

2. Clone URL repositori yang tercatat pada remote `origin`, masuk ke direktori
   proyek, lalu pilih branch pengerjaan Tugas 8.

   ```bat
   cd /d "%USERPROFILE%"
   git clone https://github.com/raynakyla/myportofolio_mobile.git
   cd myportofolio_mobile
   git switch task/tugas-8
   ```

   Jika repositori sudah ada di lokasi kerja saya, cukup masuk dengan
   `cd /d C:\myportofolio_mobile`. Tidak perlu clone lagi ke folder yang sama.

3. Dari direktori yang berisi `pubspec.yaml`, ambil dependensi dan periksa
   perangkat yang tersedia.

   ```bat
   flutter pub get
   flutter devices
   ```

4. Pastikan Chrome tercantum pada daftar perangkat, lalu jalankan target web.
   Folder `web/` tersedia di repositori. Jika Chrome belum terdeteksi, periksa
   pemasangan Chrome dan hasil `flutter doctor` terlebih dahulu.

   ```bat
   flutter run -d chrome
   ```

   Setelah selesai mencoba aplikasi, tekan `q` di terminal untuk menghentikan
   proses sebelum menjalankan pemeriksaan berikutnya.

5. Jalankan analisis statis dan tes dari direktori proyek.

   ```bat
   flutter analyze --no-pub
   flutter test
   ```

   `flutter analyze` juga dapat dipakai; opsi `--no-pub` menggunakan dependensi
   yang sudah diambil pada langkah 3.

**Android (opsional).** Folder `android/` tersedia, tetapi panduan Chrome di atas
tidak memerlukan Android SDK. Untuk mencoba Android, pasang Android Studio
beserta Android SDK dan command-line tools, lalu siapkan emulator atau perangkat
dengan USB debugging. Jika SDK belum dikonfigurasi, selesaikan temuan bagian
Android toolchain pada `flutter doctor` sebelum melanjutkan.

```bat
flutter doctor --android-licenses
flutter doctor
flutter devices
flutter run
```

Pada pilihan perangkat yang muncul, pilih emulator/perangkat Android yang
terdeteksi. Bagian ini merupakan petunjuk menjalankan target yang tersedia;
pengujian langsung pada Android belum diverifikasi dalam tahap dokumentasi ini.

Dokumentasi resmi Flutter dapat dibaca di
[docs.flutter.dev](https://docs.flutter.dev/).

## Fondasi Tutorial 10: Dependensi, URL API, dan Model Project

Tahap ini menambahkan `http`, `provider`, dan `json_annotation`, serta dev
dependency `build_runner` dan `json_serializable`. Versi hasil resolusi disimpan
di `pubspec.lock`. GET daftar/detail dijelaskan pada bagian berikutnya.
Integrasi provider dan login dijelaskan pada bagian autentikasi. Penyimpanan
proyek ke backend belum diterapkan; Save tetap menampilkan preview lokal.

`lib/config/api_config.dart` membaca `API_BASE_URL` melalui deklarasi kompilasi
`--dart-define`. Nilai default adalah `http://10.0.2.2:8000`, yaitu alamat host
komputer dari emulator Android. Nilai ini berisi origin backend, tanpa
`/api/v1/`; `ApiConfig.projectsUri` membentuk `/api/v1/projects/`.

Contoh berikut menggunakan **PowerShell Windows** dari direktori repo Flutter:

```powershell
Set-Location C:\myportofolio_mobile
flutter pub get
# Pilih ID emulator dari flutter devices; emulator-5554 hanya contoh.
flutter devices
flutter run -d emulator-5554
# Untuk Chrome, gunakan localhost dan port web tetap sesuai CORS backend.
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8000
```

Hentikan proses `flutter run` sebelumnya dengan `q` sebelum memilih target lain.
Perubahan `--dart-define` memerlukan run/build ulang. Deklarasi ini mengikuti
[konfigurasi kompilasi Dart](https://dart.dev/libraries/core/environment-declarations).
Origin bukan kredensial; jangan menaruh token atau password di deklarasi ini.

Manifest Android debug sudah memiliki izin `INTERNET`; HTTP lokal diizinkan
melalui `usesCleartextTraffic` hanya pada manifest debug. Konfigurasi ini tidak
mengaktifkan HTTP pada manifest main/release. Backend hanya dibaca pada tahap
ini. Sebelum pengujian jaringan emulator pada tahap integrasi berikutnya,
konfigurasi development Django perlu mengizinkan host `10.0.2.2` melalui
`ALLOWED_HOSTS`; konfigurasi backend saat audit belum memuat host tersebut.
Backend tidak diperlukan untuk menjalankan form preview atau unit test model.

`lib/models/project.dart` mendefinisikan `Project` dengan `@JsonSerializable`.
Model membaca respons JSON datar dengan field `id`, `title`, `description`,
`category`, `role`, `skills`, `thumbnail`, `project_url`, `is_featured`,
`star_count`, `is_starred`, dan `starred_by_names`. `ProjectCategory` tetap
diimpor dari `project_data.dart`, dengan nilai `web`, `product`, dan `creative`.
`ProjectDraft`, form, dialog, dan navigasi tidak diganti oleh model API ini.

`Project.toJson()` hanya menghasilkan delapan field input serializer. `id`,
`star_count`, `is_starred`, dan `starred_by_names` dibaca dari respons tetapi
dikecualikan dari body POST melalui `JsonKey(includeToJson: false)`. URL kosong
atau null dinormalisasi menjadi string kosong karena backend menerima URL
kosong, bukan null. Field opsional yang hilang/null memakai default: URL dan
nama pemberi star `''`, flag `false`, jumlah star `0`, serta `id` nullable.
Field wajib dan kategori yang tidak valid tetap ditolak saat parsing. Pemetaan
ini mengikuti [dokumentasi JsonKey](https://pub.dev/documentation/json_annotation/latest/json_annotation/JsonKey-class.html).

File hasil generate `lib/models/project.g.dart` **ikut di-commit** dan tidak
diabaikan oleh Git. Setelah clone, `flutter pub get` cukup untuk menyiapkan
dependensi sebelum menjalankan aplikasi. Setelah mengubah model atau anotasi,
generate ulang lalu commit source dan hasil generate bersama:

```powershell
dart run build_runner build
dart format lib/config/api_config.dart lib/models/project.dart lib/models/project.g.dart test/project_model_test.dart
flutter analyze --no-pub
flutter test --no-pub
```

## Tutorial 10: GET Project

`lib/services/api_client.dart` menyediakan GET publik melalui
`ApiConfig.projectsUri`. `ApiClient(client: ...)` menerima `http.Client`,
termasuk `MockClient` untuk tes tanpa server. Respons harus berupa array JSON
datar yang seluruh elemennya cocok dengan model `Project`; daftar kosong tidak
diganti dengan data contoh. Timeout default adalah 15 detik.

`ApiException` membedakan kegagalan HTTP (dengan `statusCode`), respons/JSON
tidak sesuai, dan koneksi/timeout. Pesan publik tidak memuat body server,
HTML, atau detail exception internal. Pemilik client HTTP yang diinjeksi
bertanggung jawab menutupnya; `ApiClient.close()` menutup client bawaannya.

```powershell
flutter test --no-pub test/api_client_test.dart test/project_model_test.dart
```

## Daftar dan Detail Project

Daftar Project dibuka dari Home atau drawer. `ProjectListPage` menyimpan future
di state dan hanya mengambil ulang data saat retry/refresh atau client diganti.
`FutureBuilder` menampilkan loading, kosong, error ramah dengan Coba Lagi, dan
daftar sebenarnya. Pull-to-refresh tetap tersedia saat kosong/error melalui
`AlwaysScrollableScrollPhysics`; ikon Muat ulang proyek juga tersedia untuk
desktop. Kembali dari detail mempertahankan daftar dan posisi scroll.

Kartu memakai `PortfolioGlassPanel`, highlight atas, gradasi icy pink/lavender,
aksen kuning, serta feedback hover/focus/pressed tanpa blur per kartu. Detail
menampilkan deskripsi penuh, kategori, peran, keahlian, status pilihan,
apresiasi, pemberi bintang, dan tautan bila valid. Thumbnail kosong/gagal memakai
fallback. `url_launcher` membuka tautan HTTP/HTTPS; skema lain tidak dijalankan.
Detail memakai snapshot hasil GET daftar; buka ulang/refresh daftar untuk data
terbaru. Belum ada POST proyek atau tombol star jaringan. Autentikasi hanya
dipakai untuk sesi dan guard Tambah Project pada tahap ini.

Untuk mencoba backend lokal, jalankan Django pada terminal PowerShell terpisah:

```powershell
Set-Location C:\myportofolio
$env:PRODUCTION = 'False'
.\env\Scripts\python.exe manage.py runserver
```

Lalu jalankan Flutter dari repo mobile dengan origin CORS development yang cocok:

```powershell
Set-Location C:\myportofolio_mobile
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8000
```

Buka Lihat Proyek, pilih kartu, kembali, dan muat ulang. Jika backend kosong,
halaman menampilkan keadaan kosong tanpa data contoh. Tes otomatis dapat
dijalankan tanpa Django: `flutter test --no-pub`. Pada Windows, penggunaan
plugin native seperti `url_launcher` juga memerlukan dukungan symlink untuk
target desktop; pengujian runtime Chrome tidak membuktikan build Android atau
Windows desktop sudah diverifikasi.

Verifikasi tahap GET/layar: `flutter analyze --no-pub` bersih dan seluruh
73 tes lulus (termasuk 8 tes HTTP dan 13 tes layar baru). Uji Chrome dengan
Django lokal mengonfirmasi GET 200, Home → daftar → detail → Back, refresh,
fallback thumbnail, dan layout jendela sempit/lebar. Keadaan kosong,
error/retry, pull-to-refresh, teks 200%, serta kegagalan launcher diuji secara
otomatis. Tautan eksternal belum dibuka dalam uji manual, dan build Android
serta Windows desktop belum diuji.

## Autentikasi Tutorial 10

Fondasi sesi Tutorial 10 menyediakan `ApiClient.obtainToken(username, password)`
dan `logout(token)`, dengan JSON login, header Token untuk logout, serta validasi
respons/token DRF. Error yang ditampilkan tidak memuat password, token, body HTML,
atau detail server. `AuthState` adalah ChangeNotifier yang disediakan bersama
ApiClient melalui provider; injeksi `MyApp(apiClient: ...)` tetap didukung.
Token hanya disimpan dalam memori dan hilang saat aplikasi dimulai ulang.
Logout segera membersihkan state lokal walaupun pencabutan server gagal.
Pembatalan login mengabaikan respons yang datang belakangan.

`LoginPage` memvalidasi field wajib, menyembunyikan password, menonaktifkan
submit selama request, dan menampilkan indikator serta error ramah. Login yang
berhasil mengembalikan `true`; Batal/Back mengembalikan hasil gagal tanpa
membuka form tujuan. `ensureLoggedIn(context)` langsung berhasil untuk sesi
aktif, atau menunggu hasil layar Login. Semua akses Tambah Project dari Home
dan drawer menggunakan guard yang sama. Penutupan drawer memakai Scaffold,
bukan pop halaman. Home dan drawer menampilkan Login/Logout secara reaktif.
Logout kembali ke Home dan tetap membersihkan sesi lokal saat server gagal.

Layar Login memakai panel kaca, highlight tepi, font lokal, dan gradasi pastel
yang sama. Keyboard dan teks 200% dapat digulir agar field/tombol tetap terjangkau.
Tidak ada penyimpanan token ke disk, auto-login setelah restart, atau pencatatan
kredensial. Error hanya memakai pesan aman, tanpa body server. Login tidak
memberikan hak superuser: backend tetap menentukan izin pada tahap pengiriman
proyek kelak. Experience dan kedua form tetap preview lokal; tidak ada POST
Project dan tidak ada perubahan autentikasi backend Experience.

```powershell
flutter test --no-pub test/auth_api_test.dart test/auth_state_test.dart test/auth_widgets_test.dart
flutter analyze --no-pub
flutter test --no-pub
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8000
```

Untuk uji manual yang berhasil, isi kredensial sendiri di form Login menggunakan
akun Django lokal. Jangan memasukkan password/token ke chat, log, atau source.
Sesudah masuk, periksa perubahan aksi menjadi Logout dan akses preview Project;
logout lalu periksa bahwa akses tersebut meminta login lagi. Refresh penuh
browser/hot restart menghapus sesi dalam memori.

Verifikasi autentikasi: format dan analyzer bersih; seluruh 111 tes lulus,
termasuk 23 tes API/state dan 15 tes widget autentikasi baru. Login berhasil,
gagal, dibatalkan saat request berjalan, guard Home/drawer, perubahan aksi sesi,
logout gagal, serta layout 200% dengan ruang keyboard diuji otomatis. Django
lokal berhasil berjalan; peluncuran Flutter Chrome pada port 3000 dicoba,
tetapi koneksi web debug service berakhir dengan timeout. Login/logout manual
belum terverifikasi. Computer-use juga dihentikan otomatis karena URL browser
Windows tidak dapat dipastikan untuk pemeriksaan kebijakan. Tidak ada
kredensial nyata yang digunakan atau dicatat.

## Struktur Penting

| Lokasi | Fungsi |
| --- | --- |
| `lib/main.dart` | Entry point `runApp`, `MaterialApp`, tema/font utama, dan pendaftaran named routes kedua form. |
| `lib/screens/home_page.dart` | Halaman Home, identitas, hero, dan susunan empat kartu aksi. |
| `lib/screens/experience_form_page.dart` | Halaman Tambah Experience, state isian, validasi, dan aksi Save. |
| `lib/screens/project_form_page.dart` | Halaman Tambah Project dengan lima input wajib, validasi, dan preview lokal. |
| `lib/screens/project_list_page.dart` dan `project_detail_page.dart` | GET publik, status daftar, refresh, dan detail Project. |
| `lib/services/api_client.dart` | HTTP client yang dapat diinjeksi dan error publik terstruktur. |
| `lib/auth/auth_state.dart` dan `auth_navigation.dart` | State sesi dalam memori, guard, dan aksi logout. |
| `lib/screens/login_page.dart` | Form login dengan validasi, indikator, retry, dan pembatalan. |
| `lib/widgets/project_card.dart` dan `project_thumbnail.dart` | Kartu kaca, kategori/status pilihan, thumbnail dan fallback. |
| `lib/models/experience_data.dart` | `ExperienceDraft` dan `ExperienceCategory` untuk snapshot lokal serta kategori pengalaman. |
| `lib/models/project_data.dart` | `ProjectDraft` dan `ProjectCategory` untuk snapshot lokal serta kategori proyek. |
| `lib/models/project.dart` dan `project.g.dart` | Model JSON API Project; source anotasi dan hasil generator yang ikut Git. |
| `lib/config/api_config.dart` | Origin backend dari `API_BASE_URL` serta URI endpoint Project. |
| `lib/widgets/portfolio_action_card.dart` | `ItemCard` dan metadata `ItemHomepage`, termasuk callback navigasi atau SnackBar. |
| `lib/widgets/portfolio_drawer.dart` | Drawer bersama, daftar tujuan, dan helper navigasi tanpa duplikasi Home/form. |
| `lib/widgets/experience_summary_dialog.dart` | `AlertDialog` ringkasan Experience valid, dengan isi yang bisa digulir. |
| `lib/widgets/project_summary_dialog.dart` | `AlertDialog` ringkasan kelima nilai Project valid. |
| `lib/widgets/portfolio_glass_panel.dart` | Panel glass bersama untuk Home, form, drawer, dan dialog. |
| `lib/widgets/portfolio_glass_button.dart` | Tombol Save dan Tutup dengan state fokus, hover, dan tekan. |
| `lib/widgets/portfolio_background.dart` | Latar cream dengan orb pastel bersama untuk Home dan form. |
| `lib/theme/portfolio_colors.dart` | Palet warna bersama agar halaman dan widget tetap konsisten. |
| `assets/fonts/` | Menyimpan font Playfair Display dan DM Sans beserta lisensinya agar tipografi tersedia secara offline. |
| `test/widget_test.dart` | Tes Home, SnackBar, navigasi kartu/drawer, Back, dan layout responsif. |
| `test/experience_form_test.dart` | Tes validasi, snapshot ringkasan, retensi isian, scroll panjang, dan inset keyboard. |
| `test/project_form_test.dart` | Tes akses Project dari Home/drawer, validasi, dialog, kembali ke Home, dan layout. |
| `test/project_model_test.dart` | Tes kontrak respons/input API, kategori, default null, dan pengecualian field server dari POST. |
| `test/api_client_test.dart` dan `project_pages_test.dart` | Tes HTTP dengan MockClient, status layar, navigasi, refresh, link, dan aksesibilitas layout. |
| `test/auth_api_test.dart`, `auth_state_test.dart`, dan `auth_widgets_test.dart` | Tes kontrak token, siklus sesi, provider, login, guard, dan logout gagal. |
| `pubspec.yaml` | Mendefinisikan metadata proyek, dependency, dan registrasi aset font beserta weight yang digunakan. |

Di bawah `lib/`, `screens/` mengelompokkan halaman, `widgets/` menyimpan
komponen antarmuka bersama, `models/` menyimpan data tanpa dependensi widget
Flutter, dan `theme/` menyimpan palet. `test/` berisi widget test. Font TTF dan
`OFL.txt` berada di `assets/fonts/dm_sans/` serta
`assets/fonts/playfair_display/`. Tabel ini mencantumkan `project.g.dart` karena
hasil generator tersebut ikut di-commit; artefak build tidak dicantumkan.

Pada Tutorial 9 tahap 5, `menu.dart` dipindah menjadi `screens/home_page.dart`,
dan `portfolio_style.dart` dipisah menjadi palet warna serta widget panel glass.
Pada perbaikan Tugas 8, kartu aksi dan metadatanya diekstrak ke
`widgets/portfolio_action_card.dart` dengan perilaku yang tetap sama. Hero dan
`InfoCard` khusus Home masih berada di file Home.

## Pemeriksaan Kode

Gunakan perintah berikut untuk menjalankan analisis statis dan seluruh widget
test:

```bat
flutter analyze --no-pub
flutter test
```

Hasil terakhir pada tahap implementasi Tugas 8: `flutter analyze --no-pub`
tidak menemukan masalah dan `flutter test` melaporkan **36 tes lulus**. Angka ini
berasal dari pemeriksaan implementasi sebelum pembaruan README ini; tes Flutter
tidak dijalankan ulang hanya untuk perubahan dokumentasi.

Tes memeriksa Home, SnackBar, akses kedua form dari kartu/drawer, navigasi
berulang tanpa duplikasi route, Back, validasi form, isi `AlertDialog`, serta
retensi isian setelah dialog ditutup dan pembaruan error saat isian diperbaiki.
Pemeriksaan layout mencakup lebar 320, 390, dan 1280 px, deskripsi panjang,
teks diperbesar, serta inset keyboard. Pemeriksaan visual Chrome dan keyboard
perangkat nyata untuk build terbaru masih perlu dilakukan langsung.

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
polish tampilan, lalu pengujian dan dokumentasi. Data masih lokal di halaman;
tombol Save belum mengirim apa pun ke Django.

### Sumber instruksi dan penyesuaian proyek

Acuan yang saya baca adalah
[Tutorial 09: Flutter Navigation, Layouts, Forms, and Input Elements](https://pbp.cs.ui.ac.id/tutorial/tutorial-9.html)
pada situs resmi **PBP Gasal 2026/2027**.

Contoh Tutorial 9 memakai **Tambah Proyek**. Pada implementasi awal saya
menambahkan **Tambah Experience** untuk bagian Pengalaman pada portofolio.
Dalam pengerjaan Tugas 8, alur **Tambah Project** dipulihkan sebagai aksi dan
halaman tersendiri. Sekarang keduanya tersedia di Home dan drawer. Penjelasan
berikut mengikuti perilaku kode saat ini.

### Alur navigasi dan drawer

- Di Home, kartu **Tambah Experience** membuka `ExperienceFormPage`, sedangkan
  **Tambah Project** membuka `ProjectFormPage`. Callback `ItemCard` memanggil
  `openPortfolioDestination()`, yang memakai
  `Navigator.of(context).pushNamedAndRemoveUntil()` dengan predicate
  `(route) => route.isFirst`. Nama route `/experience/add` dan `/project/add`
  terdaftar di `MaterialApp.routes`; Home tetap berada di bawah satu form.
- Drawer yang sama berisi **Home**, **Tambah Experience**, dan **Tambah Project**
  pada ketiga halaman. Ikon menu ada di kiri Home;
  pada form, Back tetap di kiri dan ikon menu ada di kanan.
- Memilih halaman yang sedang aktif hanya menutup drawer melalui
  `Scaffold.of(context).closeDrawer()`.
- Dari form, pilihan Home memakai `popUntil((route) => route.isFirst)` untuk
  kembali ke Home yang sudah ada. Dengan begitu, bolak-balik lewat drawer
  tidak membuat banyak salinan halaman.
- Berpindah antarform membuang route form sebelumnya dan mempertahankan Home.
  Isian form yang ditinggalkan tidak disimpan sebagai draft permanen.
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
`FormState.validate()` menjalankan validator. Jika gagal, kode membaca
`hasError` dari `form.fields` untuk menemukan error pertama, lalu memakai
`Scrollable.ensureVisible()` agar field itu terjangkau, tanpa menjalankan
validasi kedua untuk mencarinya. Setelah percobaan Save, perubahan isian
memicu validasi kembali; rebuild biasa tidak memicu satu putaran tambahan.
Jika semuanya valid, teks
dirapikan di snapshot `ExperienceDraft` dan ringkasan dibuka. Controller form
tidak dikosongkan. Jika isian diedit lagi, snapshot lama ditandai tidak berlaku
dan Save berikutnya menyiapkan snapshot baru.

Form Project menggunakan field wajib `title`, `description`, `category`, `role`,
dan `skills`. Judul, peran, dan keahlian masing-masing dibatasi 255 karakter;
teks kosong atau hanya spasi ditolak. Pilihannya adalah Web Development (`web`),
Product & UX (`product`), dan Creative Work (`creative`). Project saat ini masih
memakai `validateGranularly()` untuk memvalidasi sekaligus menemukan field salah.
Field URL dan status featured Project belum ditampilkan pada form ini.

Label tetap terlihat saat field terisi. Field disusun satu kolom dalam panel
dengan lebar maksimum 720 px; `SingleChildScrollView` membuat bagian bawah
form dan Save tetap bisa dijangkau ketika ruang berkurang. Warna, font lokal,
panel glass, latar, dan tombol aksi dipakai bersama agar tampilannya konsisten.

### Dialog ringkasan

Setelah validasi berhasil, `showDialog()` membuka `ExperienceSummaryDialog`
yang membangun `AlertDialog` berjudul **Ringkasan Experience**.
Isinya berasal dari snapshot yang baru dibuat: judul, deskripsi, label kategori,
URL thumbnail, tanggal mulai, status berlangsung, dan tanggal akhir. Nilai
opsional kosong ditulis **Tidak diisi**, sedangkan tanggal akhir pengalaman
yang masih berlangsung ditulis **Belum berakhir — masih berlangsung**.
Tanggal yang terisi memakai format `YYYY-MM-DD HH:mm UTC`.

Dialog menggunakan panel glass yang cukup opak. Kontennya bisa digulir dan
tombol Tutup berada di luar area gulir. Setelah dialog ditutup, pengguna bisa
memeriksa atau mengoreksi isian yang sama. Tulisan preview lokal menjelaskan
bahwa data belum dikirim ke server; tidak ada klaim berhasil tersimpan di Django.

Form Project memakai `showDialog()` dengan `ProjectSummaryDialog`, juga berupa
`AlertDialog`, untuk menampilkan judul, deskripsi, kategori, peran, dan keahlian.
Tombol Tutup mengembalikan pengguna ke form Project dengan isian yang sama.
Kedua dialog adalah preview lokal.

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
9. Buka Tambah Project dari Home dan drawer. Coba Save kosong, lalu isi judul,
   deskripsi, kategori, peran, dan keahlian. Periksa kelima nilai di ringkasan,
   tutup dialog, lalu kembali ke Home atau pindah ke Experience lewat drawer.

Daftar ini adalah panduan mencoba aplikasi; belum semuanya merupakan catatan
pengujian manual yang sudah selesai.

### Pengujian dan batas implementasi

- Pada tahap sebelumnya terdapat 23 tes lulus; setelah pemulihan Project dan
  perbaikan rubrik Experience, hasil terakhir menjadi 36 tes lulus. Cakupannya
  termasuk lebar 320/390/1280 px,
  teks 200%, inset keyboard, fokus keyboard, input salah/valid, dialog panjang,
  serta retensi isian. Pemeriksaan tersebut bukan pengganti keyboard HP nyata.
- Pemeriksaan visual build terbaru di Chrome belum selesai karena kontrol
  komputer dihentikan dengan Escape. Hasil tes otomatis di atas tidak dianggap
  sebagai bukti pemeriksaan visual Chrome yang sudah selesai.
- Belum ada API, autentikasi, database, penyimpanan lintas sesi, atau daftar
  Project/Experience yang diperbarui setelah Save. Lihat Proyek dan Logout masih SnackBar.
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
- **Tutorial 09.** Navigasi Home ke form, drawer bersama, input/validator, dan
  dialog ringkasan ditambahkan bertahap. Implementasi awal berfokus pada
  Experience; alur Project kemudian dipulihkan saat pengerjaan Tugas 8.
- **Tugas 8 (2026/2027).** Form Experience dipertahankan sebagai halaman
  `StatefulWidget` tersendiri dengan `Form` dan `GlobalKey<FormState>`.
  Project dan Experience dapat dibuka dari kartu Home maupun drawer. Save
  Experience memakai `validate()` dan `AlertDialog`, kartu aksi dipisah ke
  `widgets/`, dan tes diperluas. Save kedua form masih berupa preview lokal;
  data belum disimpan ke Django. Hasil tes tidak membuktikan pemeriksaan
  browser/perangkat terbaru atau pengumpulan tugas sudah selesai.

Jawaban Tugas 7 berikut dipertahankan sebagai catatan tahap tersebut. Untuk
perubahan form, lokasi kartu aksi, dan navigasi yang sekarang dipakai, lihat
[Tugas 8](#tugas-8) serta bagian Tutorial 9 di atas.

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

Refleksi ini untuk Tugas Individu 8 PBP semester 2026/2027 dan mengikuti kode
yang sekarang ada di branch `task/tugas-8`.

1. **Apa perbedaan `Navigator.push()`, `Navigator.pushReplacement()`, dan
   `Navigator.pop()`, serta bagaimana saya memakainya untuk berpindah halaman?**

   Saya memahami navigasi sebagai tumpukan halaman. `Navigator.push()`
   menambahkan route baru di atas halaman sekarang, sehingga halaman sebelumnya
   masih bisa dituju dengan Back. `Navigator.pushReplacement()` mengganti route
   paling atas, jadi route yang diganti tidak lagi menjadi tujuan Back.
   `Navigator.pop()` melepas route teratas; route itu bisa berupa halaman atau
   dialog.

   Di aplikasi saya sekarang, kartu Tambah Experience dan Tambah Project
   memanggil `openPortfolioDestination()`. Helper ini memakai
   `Navigator.of(context).pushNamedAndRemoveUntil()` dengan predicate
   `(route) => route.isFirst`, sesuai route yang didaftarkan di `main.dart`.
   Jadi contoh konsep `push()` di atas bukan pemanggilan literal dari kartu
   pada versi sekarang: implementasinya menambahkan form tujuan sekaligus
   membuang form lama jika saya sedang berpindah antarform, sambil menjaga
   Home tetap ada di dasar tumpukan.

   Pilihan Home di drawer menutup drawer lalu memanggil
   `Navigator.of(context).popUntil((route) => route.isFirst)`. Home yang sudah
   ada dipakai lagi. Memilih tujuan yang sedang aktif cukup menutup drawer.
   Tombol Tutup pada dialog memakai `Navigator.of(context).pop()` sehingga
   saya kembali ke form dengan isian yang sama. `pushReplacement()` belum
   dipakai dalam alur ini. Sebagai contoh hipotetis, metode itu bisa mengganti
   halaman login setelah autentikasi berhasil; fitur login belum ada di proyek
   ini.

2. **Bagaimana `Scaffold`, `AppBar`, dan `Drawer` menjaga struktur halaman
   tetap konsisten?**

   Saya memakai `Scaffold` sebagai kerangka Home, form Project, dan form
   Experience. `AppBar` menyediakan judul serta tombol navigasi. Properti
   `drawer` pada ketiganya memasang `PortfolioDrawer` yang sama, dengan pilihan
   Home, Tambah Experience, dan Tambah Project. Di Home ikon drawer berada di
   kiri; di form ada Back di kiri dan ikon drawer di kanan. Susunan ini
   membantu saya tetap menyediakan jalan kembali tanpa membuat ulang menu
   pada setiap halaman.

   Salah satu warna yang benar-benar dipakai bersama adalah
   `PortfolioColors.cream`, yaitu `Color(0xFFFFF9F3)`. Warna ini menjadi latar
   Scaffold dan AppBar lewat tema di `main.dart`, serta latar drawer. Panel,
   tombol, dan latar juga memakai widget bersama supaya icy pink, soft yellow,
   lavender, Playfair Display, dan DM Sans terasa konsisten di seluruh alur.

3. **Mengapa saya memilih layout form ini, dan apa peran jarak serta widget
   scrolling ketika ruang layar terbatas?**

   Saya memilih `Column` satu kolom supaya urutan mengisi field mudah diikuti
   di HP. Pada layar lebar, `ConstrainedBox` membatasi panel form sampai 720 px
   agar kolom input tidak terlalu panjang. `Padding` memberi ruang dari tepi
   layar dan panel, sedangkan `SizedBox` memberi jarak antarjudul, field,
   kelompok waktu/status, dan Save. Dengan jarak itu, pesan error tetap punya
   tempat tanpa menempel pada input berikutnya.

   `Column` tidak menyediakan scrolling, jadi saya membungkus isi form dengan
   `SingleChildScrollView` di dalam `SafeArea`. Ketika keyboard mengurangi
   ruang yang tersedia pada Scaffold, bagian bawah form bisa digulir agar Save
   tetap terjangkau. Drag pada area gulir juga bisa menutup keyboard. Drawer
   memakai `ListView`, dan konten ringkasan di dalam `AlertDialog` memakai
   `SingleChildScrollView`. Tombol Tutup ada pada `actions`, di luar area gulir
   konten, sehingga deskripsi panjang tidak menyembunyikan tombol tersebut.
   Perilaku ruang keyboard diuji dengan inset pada widget test; saya masih
   perlu memeriksanya pada perangkat nyata.

4. **Apa fungsi `GlobalKey<FormState>`, `validator`, dan `validate()` saat
   Save, serta mengapa tipe input belum cukup untuk memastikan data valid?**

   `GlobalKey<FormState>` saya pahami sebagai pegangan ke state `Form`.
   Di `ExperienceFormPage`, key dibuat sekali sebagai field state halaman,
   sehingga tidak dibuat ulang setiap `build()`. Setiap `validator`
   mengembalikan pesan error jika input salah, atau `null` jika sudah benar.
   Saat Save ditekan, kode mengambil state lewat key lalu memanggil
   `form.validate()` untuk memeriksa seluruh field.

   Kalau hasilnya `false`, dialog tidak dibuka. Kode membaca `hasError` pada
   `form.fields`, lalu menggulir ke field salah pertama dengan
   `Scrollable.ensureVisible()`. Pencarian error memakai hasil pemeriksaan
   tadi, jadi tidak perlu memanggil `validateGranularly()` setelah `validate()`.
   Setelah percobaan Save, perubahan isian memicu validasi lagi agar error bisa
   diperbarui. Jika semua lolos, kode membuat `ExperienceDraft` dengan teks
   yang sudah di-`trim()`, lalu `showDialog()` menampilkan semua nilai dalam
   `AlertDialog`. Controller tetap menyimpan isian pengguna setelah dialog
   ditutup.

   Contoh input yang ditolak adalah judul berisi spasi saja, karena hasil
   `trim()` kosong. Tanggal `2026-02-30 10:00` juga ditolak karena 30 Februari
   tidak ada; judul di atas 255 karakter dan thumbnail `bukan-url` juga tidak
   lolos. `keyboardType` URL atau tanggal hanya membantu saya mengetik.
   Pengguna masih bisa menempelkan teks yang salah, sehingga keyboard dan tipe
   input tidak menggantikan validator. Pada form Project, API validasinya masih
   `validateGranularly()`; penjelasan pemanggilan literal `validate()` di atas
   merujuk pada Experience. Save keduanya tetap berupa preview lokal dan belum
   menyimpan data ke Django.

## Penggunaan AI

### Catatan Tutorial 8 dan Tugas 7

Catatan dan hasil pemeriksaan berikut berasal dari tahap Tutorial 8/Tugas 7.
Status build terbaru untuk Tugas 8 dijelaskan pada bagian tersendiri di bawah.

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
7. Periksa build terbaru di Chrome dan sumber resmi Tutorial 9, lalu
   dokumentasikan fitur, cara mencoba, serta batas implementasi yang sebenarnya.

Ini adalah ringkasan arahan dari percakapan pengerjaan, bukan tautan transkrip
chat lengkap yang sudah dipublikasikan. Atribusi Tutorial 8 dan Tugas 7 di atas
tetap dipertahankan.

Ada koreksi yang penting selama prosesnya. Prompt awal sempat menganggap
drawer dan form sudah ada, padahal baseline baru Home; asumsi itu dikoreksi
sebelum fitur dibuat. Pencarian sumber juga sempat menemukan arsip 2025/2026,
lalu sumber diganti ke situs resmi 2026/2027 setelah tautan yang benar diketahui.
Karena itu, sumber dan perilaku aplikasi tetap diperiksa sebelum penjelasan
Tutorial 9 dimasukkan ke README.

Validasi dan navigasi diperiksa dengan tes otomatis, tetapi tes tidak
membuktikan tampilan Chrome atau keyboard HP nyata sudah diperiksa. Pemeriksaan
visual tahap 6 terhenti ketika kontrol komputer dihentikan dengan Escape;
hasil itu tidak ditulis sebagai pemeriksaan visual yang selesai. Percobaan
berikutnya juga terhenti, sehingga pemeriksaan visual build terbaru tetap
dicatat belum selesai. Dokumentasi ini membedakan hasil tes otomatis, perilaku
yang terlihat dari kode, dan hal yang masih perlu dicoba langsung.

### Bantuan AI pada Tugas 8

Untuk Tugas 8, ChatGPT membantu saya memahami instruksi dan menyiapkan prompt
bertahap. Codex membaca kode Flutter serta model Django lokal, mengimplementasikan
dan mengaudit form Project/Experience, memperbaiki navigasi bersama, mencocokkan
detail dengan rubrik, serta menambahkan dan menjalankan tes. Saya meninjau
hasilnya, menentukan arah desain pastel glass, dan memberi arahan tentang
lingkup perubahan serta perilaku yang perlu dipertahankan. Pada tahap dokumentasi
ini, Codex juga membantu mencocokkan README dengan implementasi.

Strateginya saya bagi menjadi pemulihan fitur, audit rubrik, lalu dokumentasi.
Setiap prompt meminta pemeriksaan kode lebih dulu, batas perubahan yang jelas,
dan hasil yang bisa ditinjau. Pada tahap kode, README milik saya diminta tetap
utuh; pada tahap README ini, kode aplikasi diminta tidak diubah. API persistence,
staging, commit, dan push tidak termasuk pekerjaan yang saya minta pada tahap
tersebut.

**Ringkasan prompt Tugas 8 — bukan transkrip verbatim:**

1. Baca kode Flutter, tes, navigasi, tema, dan model Project Django yang nyata.
   Pulihkan Tambah Project di Home/drawer serta form terpisah dengan validasi
   dan dialog preview lokal, sambil menjaga Experience serta desain yang ada.
2. Audit Experience terhadap persyaratan Tugas 8: Save harus memanggil
   `FormState.validate()`, ringkasan memakai `AlertDialog`, error pertama tetap
   terjangkau, dan isian tidak hilang setelah dialog ditutup. Pindahkan kartu
   aksi ke `lib/widgets/`, tambah tes yang relevan, lalu jalankan analisis dan
   seluruh tes.
3. Baca dan pertahankan edit README yang sudah ada. Lengkapi struktur proyek,
   petunjuk clone/setup CMD, progres mingguan, empat refleksi Tugas 8, dan
   pengungkapan AI berdasarkan kode; jangan ubah aplikasi atau menjalankan
   ulang tes hanya untuk dokumentasi.

Ada dua koreksi yang konkret. Alur Tambah Project sempat tergantikan oleh
Experience, sehingga saya meminta Project dipulihkan sebagai tujuan terpisah.
Selain itu, ringkasan Experience awalnya memakai custom `Dialog` dan Save
memakai `validateGranularly()`. Audit kemudian menggantinya dengan
`AlertDialog` serta pemanggilan `validate()` agar sesuai dengan persyaratan
literal, sambil tetap memakai hasil error untuk menjangkau field pertama.
Koreksi ini mengingatkan saya bahwa tampilan dan alur yang tampak berjalan
masih perlu diperiksa terhadap detail instruksi.

Hasil implementasi terakhir adalah analisis tanpa temuan dan 36 tes lulus,
seperti dicatat pada [Pemeriksaan Kode](#pemeriksaan-kode). Tes otomatis tidak
membuktikan pemeriksaan visual browser, keyboard HP nyata, atau pengumpulan
tugas sudah selesai. Ringkasan prompt di atas merangkum arahan pengerjaan;
pemeriksaan manual terbaru dan status pengumpulan tetap perlu saya verifikasi
sendiri.

## Referensi Flutter

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
