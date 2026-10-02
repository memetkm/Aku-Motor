# Aku Motor

Aplikasi Flutter offline-first untuk mencatat motor dan menjadi fondasi pemantauan perawatan. Frontend React kosong sebelumnya telah diganti dengan Flutter; backend Express/Prisma tetap berada di `apps/api` untuk tahap sinkronisasi.

## Fitur selesai

- Dashboard reaktif dan Manajemen Motor dengan Riverpod.
- CRUD Motor serta persistence Android/Web memakai `shared_preferences`.
- Enam kondisi UI: initial loading, success, empty, error+retry, validasi form, dan submit loading.
- Pencegahan double tap saat submit.
- Widget test state utama dan repository test persistence.

## Menjalankan Flutter

Prasyarat: Flutter stable dan Chrome atau Android emulator.

```bash
cd apps/web
flutter pub get
flutter run -d chrome
```

Verifikasi:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web
```

Uji persistence manual: tambah motor, edit kilometernya, refresh browser atau buka ulang aplikasi, pastikan perubahan masih ada, lalu hapus dan refresh kembali.

## Struktur

- `apps/web`: Flutter Android/Web.
- `apps/api`: REST API Express/Prisma untuk sinkronisasi berikutnya.
- `packages/shared`: model TypeScript yang masih digunakan backend.
- `Architecture.md`: arsitektur, aliran state, persistence, dan test.
- `docs/AI_USAGE.md`: prompt AI dan catatan review manual.

Backend belum dipanggil otomatis oleh vertical feature lokal ini. Perintah backend lama tetap tersedia melalui root `package.json`.
