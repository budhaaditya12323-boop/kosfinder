# Task Tracking — KosFinder

Dokumen pelacakan tugas pengerjaan proyek KosFinder disusun berdasarkan urutan *vertical slice*. Setiap slice menghasilkan aplikasi yang dapat dijalankan (*runnable*).

Format setiap task:
`ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status`

---

## Slice 1: Daftar dan Detail Kos (Guest & Katalog Publik)
*Goal: Aplikasi dapat dijalankan dan menampilkan katalog kos aktif, status kamar, ilustrasi kosong/error, detail kos lengkap dengan gambar fallback, halaman About pengembang, serta tombol WhatsApp.*

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T01** | Setup dependensi dasar (`supabase_flutter`, `provider`, `url_launcher`, `intl`), konfigurasi `AppConfig`, tema hijau aplikasi, dan kerangka routing | Arsitektur Sec 1, 4, 6 | `pubspec.yaml`, `lib/main.dart`, `lib/core/config/app_config.dart`, `lib/core/theme/app_theme.dart` | Jalankan `flutter pub get` dan `flutter run` memastikan app berjalan dengan tema hijau tanpa crash | Pending |
| **T02** | Buat model entitas `Kos` (parse JSON Supabase, format Rupiah, normalisasi nomor kontak) | US01, US03 | `lib/models/kos_model.dart`, `test/models/kos_model_test.dart` | Jalankan `flutter test test/models/kos_model_test.dart` untuk verifikasi mapping data JSON ke model | Pending |
| **T03** | Buat `KosRepository` dan implementasi query mengambil kos aktif (`is_active = true`) | US01 (AC1, AC2, AC3) | `lib/repositories/kos_repository.dart`, `test/repositories/kos_repository_test.dart` | Jalankan unit test dengan mock Supabase client atau panggil `fetchActiveKos()` | Pending |
| **T04** | Buat `KosProvider` untuk state management katalog (loading, data list, empty state, error state dengan tombol retry) | US01 (AC1, AC2, AC3) | `lib/providers/kos_provider.dart`, `test/providers/kos_provider_test.dart` | Jalankan unit test `KosProvider` menguji perubahan state saat loading, sukses, dan error | Pending |
| **T05** | Buat UI `CatalogScreen` untuk menampilkan daftar kartu kos aktif, status ketersediaan/badge "Penuh", penanganan empty state, dan tombol retry saat gagal koneksi | US01 (AC1, AC2, AC3) | `lib/screens/catalog_screen.dart`, `lib/widgets/kos_card.dart`, `test/screens/catalog_screen_test.dart` | Jalankan widget test dan jalankan di emulator untuk melihat kartu kos, label sisa kamar/badge penuh, serta state error | Pending |
| **T06** | Buat `AboutScreen` yang menampilkan identitas pengembang wajib (`2415051006 - I Putu Budha Aditya`) dan navigasi dari `CatalogScreen` | AGENTS.md Sec 7, Arsitektur Sec 2 | `lib/screens/about_screen.dart`, `lib/screens/catalog_screen.dart`, `test/screens/about_screen_test.dart` | Buka menu/tombol info di CatalogScreen, pastikan teks `2415051006 - I Putu Budha Aditya` muncul | Pending |
| **T07** | Buat `KosDetailScreen` lengkap dengan fallback gambar placeholder hijau dan integrasi tombol hubungi WhatsApp (`https://wa.me/<nomor>`) | US03 (AC1, AC2) | `lib/screens/kos_detail_screen.dart`, `lib/screens/catalog_screen.dart`, `test/screens/kos_detail_screen_test.dart` | Tap salah satu kos di CatalogScreen, verifikasi detail muncul, gambar placeholder jika URL kosong, dan klik tombol WA memanggil URL wa.me dengan kode negara 62 | Pending |

---

## Slice 2: Pencarian dan Filter (Guest/Katalog Publik)
*Goal: Pengguna dapat mencari kos berdasarkan nama/area serta menyaring kos berdasarkan tipe gender (Putra, Putri, Campur) dan filter harga.*

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T08** | Tambahkan logika pencarian kata kunci teks (nama/area) dan filter gender/harga pada `KosRepository` dan `KosProvider` | US02 (AC1, AC2) | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `test/providers/kos_provider_test.dart` | Jalankan unit test `KosProvider` dengan kata kunci dan filter gender untuk memastikan daftar terfilter akurat | Pending |
| **T09** | Tambahkan widget search bar dan filter chips gender (Semua, Putra, Putri, Campur) pada `CatalogScreen` beserta tampilan "Tidak ada kos yang cocok" jika hasil nihil | US02 (AC1, AC2) | `lib/screens/catalog_screen.dart`, `lib/widgets/filter_bar.dart`, `test/screens/catalog_screen_test.dart` | Ketikkan kata kunci area dan pilih chip gender di UI, verifikasi list berubah sesuai filter dan pesan kosong muncul bila pencarian tidak cocok | Pending |

---

## Slice 3: Login dan Autentikasi Pemilik
*Goal: Pemilik kos dapat mendaftar (registrasi tanpa konfirmasi email), login, logout, dan diarahkan ke Dashboard Pemilik atau kembali ke katalog publik.*

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T10** | Buat `AuthRepository` untuk register, login, logout, dan cek sesi menggunakan Supabase Auth | US04 (AC1, AC2) | `lib/repositories/auth_repository.dart`, `test/repositories/auth_repository_test.dart` | Jalankan unit test auth repository untuk skenario login/register berhasil dan penanganan email duplikat/invalid | Pending |
| **T11** | Buat `AuthProvider` untuk state management autentikasi pemilik (status login, user session, loading, pesan error) | US04 (AC1, AC2) | `lib/providers/auth_provider.dart`, `test/providers/auth_provider_test.dart` | Jalankan unit test `AuthProvider` untuk transisi state login, logout, dan error handling | Pending |
| **T12** | Buat `LoginScreen` dan `RegisterScreen` dengan validasi form (email valid, password minimal 6 karakter) serta navigasi ke dashboard pemilik | US04 (AC1, AC2) | `lib/screens/login_screen.dart`, `lib/screens/register_screen.dart`, `lib/screens/catalog_screen.dart`, `test/screens/auth_screens_test.dart` | Buka LoginScreen dari tombol di CatalogScreen, coba daftar akun baru dan login, pastikan berhasil masuk dan pesan error tampil saat kredensial salah/duplikat | Pending |
| **T13** | Buat `OwnerDashboardScreen` kerangka awal dengan info user, tombol logout, dan tombol kembali ke katalog publik | US04 (AC1) | `lib/screens/owner_dashboard_screen.dart`, `lib/main.dart`, `test/screens/owner_dashboard_screen_test.dart` | Login sebagai pemilik, verifikasi berhasil mendarat di Dashboard, lalu tekan tombol Logout untuk kembali ke status guest | Pending |

---

## Slice 4: Tambah, Ubah, dan Hapus Kos Milik Sendiri (CRUD Pemilik)
*Goal: Pemilik kos dapat melihat kos miliknya (aktif & arsip), menambah kos baru, mengedit data kos sendiri, serta melakukan soft-delete kos.*

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T14** | Tambahkan fungsi CRUD kos pemilik (`fetchOwnerKos`, `createKos`, `updateKos`, `softDeleteKos`) di `KosRepository` | US05 (AC1), US06 (AC1), US07 (AC1) | `lib/repositories/kos_repository.dart`, `test/repositories/kos_repository_test.dart` | Jalankan unit test repository untuk operasi insert, update, dan soft delete (`is_active = false`) | Pending |
| **T15** | Buat `OwnerKosProvider` untuk mengelola state kos pemilik (list aktif, list arsip/nonaktif, aksi create, update, soft-delete, dan restore) | US05, US06, US07 | `lib/providers/owner_kos_provider.dart`, `test/providers/owner_kos_provider_test.dart` | Jalankan unit test `OwnerKosProvider` untuk memverifikasi pembaruan state saat menambah, mengubah, dan menghapus kos | Pending |
| **T16** | Tampilkan daftar kos pemilik di `OwnerDashboardScreen` dengan pemisahan tab kos aktif dan arsip, serta tombol aksi edit dan hapus | US05 (AC1), US07 (AC1) | `lib/screens/owner_dashboard_screen.dart`, `lib/widgets/owner_kos_card.dart`, `test/screens/owner_dashboard_screen_test.dart` | Buka Dashboard Pemilik, pastikan list kos milik akun tersebut muncul di tab yang sesuai | Pending |
| **T17** | Buat `KosFormScreen` untuk mode Tambah Kos dengan validasi field wajib, normalisasi nomor HP ke `62...`, dan validasi `sisa_kamar >= 0` | US05 (AC1, AC2) | `lib/screens/kos_form_screen.dart`, `lib/screens/owner_dashboard_screen.dart`, `test/screens/kos_form_screen_test.dart` | Isi form Tambah Kos dengan nilai valid lalu simpan; coba input `sisa_kamar` negatif dan pastikan muncul error "Sisa kamar tidak boleh negatif" | Pending |
| **T18** | Tambahkan mode Edit Kos pada `KosFormScreen` untuk mengubah data kos yang sudah ada | US06 (AC1, AC2) | `lib/screens/kos_form_screen.dart`, `test/screens/kos_form_screen_test.dart` | Buka form edit dari kartu kos milik sendiri, ubah salah satu field (misal nama/harga), simpan dan verifikasi perubahan ter-update | Pending |
| **T19** | Implementasikan dialog konfirmasi dan aksi soft-delete kos (`is_active = false`) serta opsi restore kos dari tab arsip dengan penanganan error koneksi | US07 (AC1, AC2) | `lib/screens/owner_dashboard_screen.dart`, `lib/providers/owner_kos_provider.dart`, `test/screens/owner_dashboard_screen_test.dart` | Tekan Hapus pada kos aktif dan konfirmasi, pastikan kos berpindah ke tab arsip dan tidak lagi muncul di CatalogScreen publik; verifikasi notifikasi error saat koneksi terputus | Pending |

---

## Slice 5 (Bonus): Ketersediaan Kamar
*Goal: Pembaruan cepat ketersediaan kamar oleh pemilik dan pembaruan indikator visual status kamar di aplikasi secara instan.*

| ID | Tujuan | Story & AC Terkait | File yang Boleh Diubah | Cara Menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **T20** | Tambahkan fungsi mutasi cepat `updateRoomAvailable(kosId, newCount)` di `KosRepository` dan `OwnerKosProvider` | US06 (AC1), PRD Sec 1.2 | `lib/repositories/kos_repository.dart`, `lib/providers/owner_kos_provider.dart`, `test/providers/owner_kos_provider_test.dart` | Jalankan unit test mutasi `updateRoomAvailable` dengan nilai 0 dan nilai > 0 | Pending |
| **T21** | Tambahkan kontrol cepat (*quick stepper* / tombol + dan -) ketersediaan kamar langsung di kartu kos `OwnerDashboardScreen` (< 30 detik tanpa masuk form edit lengkap) | US06 (AC1), PRD Sec 1.2 | `lib/screens/owner_dashboard_screen.dart`, `lib/widgets/owner_kos_card.dart`, `test/screens/owner_dashboard_screen_test.dart` | Ubah sisa kamar langsung dari kartu di Dashboard, pastikan nilai tersimpan dan jika menjadi 0 otomatis berstatus "Penuh" | Pending |
| **T22** | Verifikasi sinkronisasi status kamar di `CatalogScreen` dan `KosDetailScreen` (badge dinamis sisa kamar vs "Penuh") | US01 (AC1), US06 (AC1) | `lib/widgets/kos_card.dart`, `lib/screens/kos_detail_screen.dart`, `test/widgets/kos_card_test.dart` | Jalankan widget test dan verifikasi tampilan badge berubah menjadi "Penuh" saat kamar = 0 dan "Sisa X Kamar" saat kamar > 0 | Pending |
