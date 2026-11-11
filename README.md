# MyPortfolio Mobile

MyPortfolio Mobile adalah aplikasi portofolio berbasis Flutter yang dibuat untuk
Tutorial 8 PBP. Proyek ini dikembangkan terpisah dari proyek portofolio Django.
Untuk saat ini, halaman utama masih menggunakan data statis dan belum terhubung
ke API.

## Identitas

- **Nama:** Rayna Kayla Rayvanka
- **NPM:** 2506657283
- **Kelas:** PBP F

## Fitur yang Sudah Tersedia

- Kartu informasi pemilik yang menampilkan nama, NPM, dan kelas.
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

Masuk ke folder proyek, ambil dependency, lalu jalankan aplikasi di Chrome:

```powershell
cd C:\myportofolio_mobile
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

Tes yang tersedia memastikan identitas pemilik dan ketiga tombol tampil,
memastikan setiap tombol menghasilkan SnackBar yang sesuai, serta memeriksa
bahwa layout selebar 320 px tidak memunculkan exception overflow. Pemeriksaan
visual di browser tetap perlu dilakukan secara manual saat meninjau tampilan.

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

## Penggunaan AI

ChatGPT membantu menyusun langkah pengerjaan dan penjelasan. Codex membantu
proses refactor, implementasi tampilan, serta pengujian. Penyesuaian desain
diarahkan melalui revisi pengguna. Saya sudah memahami dan memeriksa secara
manual seluruh kode yang digunakan dalam proyek ini.

## Referensi Flutter

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
