# AGENTS.md

Panduan dan aturan kerja untuk Agen AI dalam pengembangan proyek **KosFinder**.

---

## 1. Konteks Proyek & Dokumen Acuan

KosFinder adalah aplikasi mobile pencarian dan pemesanan kos berbasis Flutter dan Supabase. Semua pekerjaan harus selalu merujuk dan selaras dengan dokumen acuan berikut:

- [`docs/PRD.md`](file:///home/budha_aditya_/codes/mobile/flutter/kosfinder/docs/PRD.md) – *Product Requirements Document*: Berisi kebutuhan produk, fitur, user persona, serta alur bisnis aplikasi.
- [`docs/ARCHITECTURE.md`](file:///home/budha_aditya_/codes/mobile/flutter/kosfinder/docs/ARCHITECTURE.md) – *Architecture Design*: Struktur arsitektur aplikasi, tata letak folder, pola state management, dan integrasi backend.
- [`docs/TASKS.md`](file:///home/budha_aditya_/codes/mobile/flutter/kosfinder/docs/TASKS.md) – *Task Tracking / Breakdown*: Daftar task, backlog, pembagian kerja, serta status pengerjaan.

---

## 2. Cara Kerja Agen AI

- **Satu Task Per Permintaan:** Kerjakan hanya satu task spesifik pada setiap giliran kerja/permintaan (prompt). Hindari mengerjakan banyak task sekaligus di luar instruksi.
- **Batasan Perubahan (Scope):** Jangan mengubah atau menghapus file di luar cakupan task yang sedang dikerjakan.
- **Rencana Terlebih Dahulu (Planning):** Untuk perubahan berskala besar, refactoring arsitektur, atau modifikasi struktural, buat rencana kerja (plan) terlebih dahulu dan mintalah persetujuan sebelum mulai mengedit file.
- **KISS (Keep It Simple, Stupid):** Utamakan solusi paling sederhana, bersih, mudah dibaca, dan mudah dirawat. Hindari *over-engineering* atau abstraksi yang tidak perlu.
- **Manajemen Dependency/Package:** Jangan menambahkan package/library baru ke dalam `pubspec.yaml` tanpa persetujuan eksplisit dari user.

---

## 3. Teknologi & Stack

- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Backend / Database / Auth:** Supabase

---

## 4. Keamanan (Security)

- **Rahasia / Kredensial:** Dilarang keras menuliskan API key, token rahasia, connection string, atau password secara langsung (*hardcoded*) di dalam kode sumber.
- **Supabase Keys:**
  - Hanya gunakan `anon` key publik pada aplikasi klien Flutter.
  - `service_role` key **TIDAK PERNAH** boleh dipakai atau dimasukkan ke dalam aplikasi klien.
- **Otorisasi Data:** Penegakan hak akses data dan otorisasi wajib diterapkan di tingkat database menggunakan **Row Level Security (RLS)** pada Supabase.

---

## 5. Konvensi Git

- **Granularitas Commit:** Satu task per commit.
- **Format Pesan Commit:** Pesan commit harus selalu menyertakan ID task yang relevan (mengacu pada `docs/TASKS.md`), contoh:
  - `feat(TASK-01): implement splash screen and auth state listener`
  - `fix(TASK-05): fix price filter range slider logic`

---

## 6. Definition of Done (DoD)

Sebuah task hanya dinyatakan selesai jika memenuhi seluruh kriteria berikut:
1. `flutter analyze` berjalan bersih tanpa error maupun warning.
2. `flutter test` lulus seluruh test suite.
3. Aplikasi berhasil dijalankan dan diverifikasi di device/emulator.
4. **Laporan Pengujian:** Agen AI wajib melaporkan secara transparan apa saja hal atau skenario yang **belum diuji** secara manual maupun otomatis.

---

## 7. Informasi Pengembang (Halaman About)

Pada halaman **About** aplikasi, wajib menampilkan identitas pengembang:
- **NIM:** 2415051006
- **Nama:** I Putu Budha Aditya
- **Format Tampilan:** `2415051006 - I Putu Budha Aditya`
