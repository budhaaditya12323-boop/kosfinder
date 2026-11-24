# Product Requirements Document (PRD) — KosFinder (v1)

## 1. Masalah & Tujuan yang Bisa Diukur
### 1.1 Masalah
Informasi kos saat ini tersebar tidak terstruktur di media sosial dan grup chat WhatsApp. Pencari kos kesulitan mencari dan menyaring kos berdasarkan kebutuhan dasar (tipe gender, lokasi/nama, harga), serta sering mendapati kamar ternyata sudah penuh. Pemilik kos kesulitan mempublikasikan serta memperbarui ketersediaan kamar secara cepat.

### 1.2 Tujuan Terukur (Metrics)
1. **Efisiensi Pencarian:** Pengguna guest dapat menemukan dan membuka detail kos dalam < 3 ketukan (tap) dari halaman utama.
2. **Kecepatan Update Ketersediaan:** Pemilik kos dapat memperbarui `sisa_kamar` dalam waktu < 30 detik setelah login.
3. **Konversi Kontak:** 100% tombol WhatsApp pada detail kos yang valid berhasil mengarahkan pengguna langsung ke aplikasi/web WhatsApp via tautan `https://wa.me/<nomor>`. Pada nomor pastikan formatnya menggunakan country code, contoh : 6281234567890

---

## 2. Pengguna (User Personas)
1. **Pencari Kos (Guest):** Mahasiswa/masyarakat umum. Dapat langsung mencari, menyaring, dan melihat detail kos tanpa registrasi/login.
2. **Pemilik Kos (Owner):** Pengguna terautentikasi (registrasi via email & password). Mengelola (buat, edit, soft-delete) listing kos miliknya sendiri.

---

## 3. Cakupan Versi 1 (Scope v1)
### 3.1 Fitur yang Masuk (In-Scope)
- **Tema & Desain:** UI berbasis tema warna hijau (kesan aman, asri, nyaman).
- **Pencari Kos (Guest):**
  - Melihat katalog daftar kos aktif (`is_active == true`).
  - Pencarian berdasarkan teks (nama kos atau area/lokasi).
  - Filter tipe gender kos (Putra, Putri, Campur).
  - Filter rentang harga (jika waktu memungkinkan/opsional).
  - Halaman detail kos (nama, harga, sisa kamar/status penuh, tipe gender, alamat bebas, gambar URL/placeholder).
  - Tombol aksi "Hubungi via WhatsApp" (`https://wa.me/<nomor>`). Pada nomor pastikan formatnya menggunakan country code, contoh : 6281234567890
- **Pemilik Kos (Owner):**
  - Registrasi & Login menggunakan Supabase Auth (Email & Password), tidak perlu konfirmasi email. Sekali registrasi valid, akun langsung aktif.
  - Logout.
  - Tambah data kos baru (nama, harga, tipe gender, alamat/area teks bebas, nomor WA/telepon, URL gambar eksternal, `sisa_kamar`).
  - Edit data kos milik sendiri (termasuk update cepat `sisa_kamar`).
  - Hapus kos milik sendiri menggunakan mekanisme *soft delete* (`is_active = false`).
  - Menampilkan daftar kos milik pemilik yang sedang login.

### 3.2 Fitur yang TIDAK Masuk (Out-of-Scope)
- Pembayaran online / payment gateway.
- Chat internal (in-app chat).
- Ulasan dan rating kos.
- Rekomendasi berbasis AI.
- Verifikasi identitas/legalitas pemilik kos.
- Upload berkas/foto asli ke storage server (hanya input teks link URL gambar eksternal).
- Peta interaktif / Google Maps integration.

---

## 4. Non-Functional Requirements (NFR)
Tiap NFR dirancang spesifik dan dapat diuji:
1. **Keamanan (Security):** Supabase Row Level Security (RLS) diaktifkan pada tabel kos. Mutasi data (`UPDATE`, `DELETE`/soft-delete) oleh user A terhadap data milik user B harus ditolak oleh RLS dengan kode error `403/Forbidden` atau 0 baris terpengaruh.
2. **Keandalan (Reliability):** Saat koneksi internet terputus atau API Supabase gagal diakses, aplikasi tidak crash dan menampilkan pesan kesalahan ramah (*friendly error state*) dengan tombol *Coba Lagi* (*retry*).
3. **Kemudahan Pakai (Usability):** Input nomor telepon/WhatsApp pada form pemilik secara otomatis dinormalisasi ke format internasional (misal: `0812...` menjadi `62812...`) sebelum disimpan atau dibuatkan link `wa.me`. Jika URL gambar eksternal kosong/rusak, UI wajib menampilkan aset placeholder default.
4. **Performa (Performance):** Waktu respon rendering daftar kos awal di jaringan 4G/WiFi stabil 2,5 detik (dengan paginasi/limit query).
5. **Privasi (Privacy):** Kredensial pemilik (password) dienkripsi penuh oleh Supabase Auth. Guest tidak dapat melihat email/identitas privat pemilik selain nomor kontak publik kos.

---

## 5. User Stories
- **US01:** Sebagai **Pencari Kos**, saya ingin **melihat katalog kos aktif beserta status ketersediaannya**, agar **saya mengetahui kos mana saja yang masih memiliki kamar kosong**.
- **US02:** Sebagai **Pencari Kos**, saya ingin **mencari kos berdasarkan nama/area dan menyaring berdasarkan tipe gender**, agar **saya cepat menemukan kos yang sesuai kriteria saya**.
- **US03:** Sebagai **Pencari Kos**, saya ingin **membuka tautan WhatsApp pemilik dari halaman detail kos**, agar **saya dapat langsung menanyakan ketersediaan kamar ke pemilik**.
- **US04:** Sebagai **Pemilik Kos**, saya ingin **mendaftar dan masuk menggunakan email dan kata sandi**, agar **saya dapat mengelola kos yang saya miliki**.
- **US05:** Sebagai **Pemilik Kos**, saya ingin **menambahkan listing kos baru beserta detail dan URL gambar**, agar **kos saya dapat dilihat oleh calon penyewa**.
- **US06:** Sebagai **Pemilik Kos**, saya ingin **mengubah data dan sisa kamar kos milik saya**, agar **informasi kamar yang ditampilkan selalu akurat**.
- **US07:** Sebagai **Pemilik Kos**, saya ingin **menghapus kos milik saya (soft delete)**, agar **kos yang sudah tidak beroperasi tidak lagi muncul di pencarian publik**.

---

## 6. Acceptance Criteria (Given / When / Then)

### US01 — Melihat Katalog Kos
- **US01-AC1 (Data Normal & Status Kamar):**
  - **Given** terdapat kos aktif dengan `sisa_kamar = 2` dan kos aktif lain dengan `sisa_kamar = 0`.
  - **When** Pencari Kos membuka halaman utama katalog.
  - **Then** kos pertama menampilkan label sisa 2 kamar, sedangkan kos kedua menampilkan badge/label "Penuh".
- **US01-AC2 (Kasus Data Kos Kosong):**
  - **Given** belum ada kos aktif (`is_active = true`) di database.
  - **When** Pencari Kos membuka halaman utama katalog.
  - **Then** sistem menampilkan ilustrasi/teks kosong: "Belum ada kos yang tersedia saat ini."
- **US01-AC3 (Kasus Koneksi Gagal):**
  - **Given** perangkat tidak memiliki koneksi internet.
  - **When** Pencari Kos membuka atau me-refresh katalog kos.
  - **Then** sistem menampilkan pesan kesalahan "Gagal memuat data. Periksa koneksi internet Anda" dan tombol "Coba Lagi".

### US02 — Pencarian & Filter Gender
- **US02-AC1 (Pencarian & Filter Berhasil):**
  - **Given** ada daftar kos dengan berbagai area dan tipe gender (Putra, Putri, Campur).
  - **When** Pencari Kos memilih filter gender "Putri" dan mengetikkan "Pogung".
  - **Then** daftar kos yang tampil hanya kos aktif tipe Putri yang nama atau areanya mengandung kata "Pogung".
- **US02-AC2 (Pencarian Tidak Ditemukan):**
  - **Given** Pencari Kos berada di halaman katalog.
  - **When** pengguna memasukkan kata kunci pencarian yang tidak cocok dengan data apa pun.
  - **Then** sistem menampilkan pesan "Tidak ada kos yang cocok dengan pencarian Anda."

### US03 — Menghubungi Pemilik via WhatsApp
- **US03-AC1 (Klik Tombol WhatsApp Berhasil):**
  - **Given** Pencari Kos membuka halaman detail kos dengan nomor kontak terdaftar `08123456789`.
  - **When** Pencari Kos menekan tombol "Hubungi via WhatsApp".
  - **Then** sistem membuka tautan browser/aplikasi ke `https://wa.me/628123456789`.
- **US03-AC2 (Fallback Gambar Placeholder):**
  - **Given** sebuah kos memiliki `image_url` kosong atau tidak valid.
  - **When** Pencari Kos membuka halaman detail kos tersebut.
  - **Then** sistem menampilkan gambar *placeholder* bawaan aplikasi bernuansa hijau secara utuh tanpa error.

### US04 — Registrasi & Autentikasi Pemilik
- **US04-AC1 (Registrasi Sukses):**
  - **Given** calon pemilik berada di halaman pendaftaran.
  - **When** menginputkan email valid yang belum terdaftar dan password $\ge 6$ karakter lalu menekan "Daftar".
  - **Then** akun berhasil dibuat di Supabase Auth dan pengguna langsung diarahkan ke dashboard pemilik.
- **US04-AC2 (Validasi Form & Email Duplikat):**
  - **Given** calon pemilik menginput email yang sudah terdaftar.
  - **When** menekan tombol "Daftar".
  - **Then** sistem menampilkan pesan kesalahan "Email sudah terdaftar. Silakan login."

### US05 — Tambah Kos Baru
- **US05-AC1 (Tambah Kos Berhasil):**
  - **Given** Pemilik Kos telah login dan berada di form "Tambah Kos".
  - **When** mengisi semua field wajib (nama, harga, tipe gender, alamat bebas, nomor WA, `sisa_kamar`) lalu menekan "Simpan".
  - **Then** data tersimpan di Supabase dengan `user_id` pemilik saat ini, `is_active = true`, dan muncul di daftar kos saya.
- **US05-AC2 (Validasi Sisa Kamar Negatif):**
  - **Given** Pemilik Kos mengisi form tambah kos.
  - **When** memasukkan nilai `sisa_kamar` < 0 (angka negatif).
  - **Then** form memvalidasi dengan pesan error "Sisa kamar tidak boleh negatif" dan tombol simpan ditahan.

### US06 — Edit Data Kos
- **US06-AC1 (Edit Kos Milik Sendiri Sukses):**
  - **Given** Pemilik Kos membuka form edit untuk kos miliknya sendiri.
  - **When** mengubah `sisa_kamar` menjadi 0 dan menekan "Simpan Perubahan".
  - **Then** data berhasil diperbarui di database dan status kos berubah menjadi "Penuh".
- **US06-AC2 (Proteksi: Pemilik Mencoba Mengubah Kos Milik Orang Lain):**
  - **Given** Pemilik A sedang login dan mencoba mengirim request mutasi/update pada ID kos milik Pemilik B (misal via rekayasa parameter/API call).
  - **When** request dikirim ke backend Supabase.
  - **Then** Supabase RLS menolak mutasi tersebut (0 baris terpengaruh / 403 Forbidden) dan data kos Pemilik B tidak berubah sama sekali.

### US07 — Hapus Kos (Soft Delete)
- **US07-AC1 (Soft Delete Berhasil):**
  - **Given** Pemilik Kos memilih aksi "Hapus" pada kos miliknya dan mengonfirmasi dialog peringatan.
  - **When** proses hapus dikonfirmasi.
  - **Then** kolom `is_active` berubah menjadi `false`, kos tidak lagi tampil di katalog Pencari Kos, namun baris data tetap ada di database Supabase.
- **US07-AC2 (Kasus Koneksi Gagal Saat Menghapus):**
  - **Given** Pemilik Kos melakukan aksi hapus saat jaringan internet terputus.
  - **When** konfirmasi hapus ditekan.
  - **Then** sistem menampilkan notifikasi "Gagal menghapus kos. Periksa koneksi internet Anda" dan status `is_active` tidak berubah.

---

## 7. Hal yang Masih Ambigu / Daftar Pertanyaan Lanjutan
1. **Verifikasi Email:** Apakah registrasi Supabase Auth mengharuskan konfirmasi email (*email confirmation link*) sebelum pemilik dapat login dan membuat kos, atau otomatis langsung terkonfirmasi/bisa langsung login?
2. **Format Periode Harga:** Apakah kolom harga diasumsikan otomatis "per bulan" (misal: Rp 800.000 / bulan), ataukah perlu opsi periode (per bulan / per tahun)?
3. **Batas Maksimal Listing per Pemilik:** Apakah satu akun pemilik dibatasi jumlah kos yang dapat diunggah di v1, atau tidak terbatas (*unlimited*)?
4. **Pengelolaan Kos Nonaktif bagi Pemilik:** Apakah kos yang sudah di-soft-delete (`is_active = false`) tetap dapat dilihat di dashboard pemilik (misal di tab "Arsip/Nonaktif") dan bisa diaktifkan kembali (*restore*), atau disembunyikan seluruhnya dari UI pemilik?

## 8. Daftar Keputusan Pertanyaan Ambigu
Berikut adalah jawaban untuk pertanyaan yang sebelumnya ambigu:
1. **Verifikasi Email:** Registrasi tidak memerlukan konfirmasi email link. Sekali registrasi valid, akun langsung aktif.
2. **Format Harga:** Kolom harga diasumsikan otomatis "per bulan" (misal: Rp 800.000 / bulan).
3. **Batas Listing:** Satu akun pemilik tidak dibatasi (unlimited) untuk mengunggah kos.
4. **Kos Nonaktif (Soft Delete):** Kos yang dihapus tetap dapat dilihat di dashboard pemilik (tab Arsip) dan bisa diaktifkan kembali (restore). Namun, kos yang sudah di-soft-delete tidak akan muncul di katalog publik (pencarian).