# KosFinder

Aplikasi mobile pencarian dan pemesanan kos berbasis Flutter dan Supabase.

---

## Cara Menjalankan

Aplikasi ini menggunakan konfigurasi `--dart-define` untuk menyuntikkan kredensial Supabase (`SUPABASE_URL` dan `SUPABASE_ANON_KEY`) saat proses *compilation*, sehingga kredensial aman dan tidak dituliskan langsung (*hardcoded*) di dalam kode sumber.

### 1. Menjalankan di Mode Debug / Pengembangan

Jalankan perintah berikut pada terminal di direktori proyek:

```bash
flutter run \
  --dart-define=SUPABASE_URL="https://contoh-proyek.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.contohAnonKeyPalsu"
```

> **Catatan:** Ganti nilai `"https://contoh-proyek.supabase.co"` dan `"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.contohAnonKeyPalsu"` dengan URL dan public `anon` key Supabase asli proyek Anda.

### 2. Menjalankan di Device Tertentu (contoh: Linux desktop)

```bash
flutter run -d linux \
  --dart-define=SUPABASE_URL="https://contoh-proyek.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.contohAnonKeyPalsu"
```

### 3. Build APK Rilis (Android)

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL="https://contoh-proyek.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.contohAnonKeyPalsu"
```
Output berkas APK rilis berada di: `build/app/outputs/flutter-apk/app-release.apk`.

---

## Menjalankan Pengujian & Analisis Kode

- Menjalankan analisis kode:
  ```bash
  flutter analyze
  ```
- Menjalankan seluruh test suite:
  ```bash
  flutter test
  ```
