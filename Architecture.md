# Arsitektur Aku Motor — Flutter

## Tujuan dan prototype

Aku Motor membantu pemilik sepeda motor mencatat kendaraan dan memantau perawatan. Frontend React/Vite dimigrasikan ke Flutter agar satu codebase berjalan di Android dan Web. Backend Express/Prisma tetap tersedia untuk sinkronisasi berikutnya, tetapi vertical feature saat ini berjalan offline-first dari UI hingga local storage.

Alur MVP: Dashboard menampilkan ringkasan → pengguna membuka **Motor saya** → halaman menampilkan loading/data/empty/error → pengguna melakukan CRUD melalui form tervalidasi → submit dikunci selama penyimpanan → perubahan tersimpan setelah restart atau refresh.

## Struktur proyek

```text
apps/web/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/theme/
│   ├── features/
│   │   ├── dashboard/{application,presentation}/
│   │   └── motors/{application,data,domain,presentation}/
│   └── shared/widgets/
├── test/{features,support}/
├── pubspec.yaml
└── analysis_options.yaml
```

Struktur berbasis feature membuat domain, state, persistence, dan UI sebuah fitur dapat dilacak secara vertikal.

## Aliran data vertical feature Motor

```text
MotorListScreen / MotorFormDialog
              │ watch / command
              ▼
       MotorListNotifier (Riverpod)
              │ CRUD
              ▼
       MotorRepository (kontrak)
              │ implementasi
              ▼
SharedPreferencesMotorRepository
              │ JSON
              ▼
 shared_preferences device/browser
```

- Presentation merender state, menerima input, dan menampilkan validasi.
- Application mengatur lifecycle async dan operasi CRUD.
- Domain mendefinisikan `Motor`, `MotorDraft`, dan kontrak repository.
- Data melakukan serialisasi JSON dan persistence.
- UI tidak mengetahui detail storage, sehingga repository dapat diganti SQLite/Isar/API.

## State management

Riverpod digunakan konsisten pada dua fitur.

### Feature 1 — Manajemen Motor

`motorListProvider` adalah `AsyncNotifierProvider<MotorListNotifier, List<Motor>>`.

| Kondisi | Representasi | UI |
|---|---|---|
| Initial loading | `AsyncLoading` | indikator loading |
| Berhasil, ada data | `AsyncData<List<Motor>>` | daftar card motor |
| Berhasil, kosong | `AsyncData([])` | empty state dan CTA |
| Error | `AsyncError` | pesan dan tombol **Coba lagi** |
| Form tidak valid | validator `Form` | pesan per field |
| Sedang submit | `_isSubmitting == true` | spinner dan tombol disabled |

Create, update, dan delete berada pada notifier. Guard `_isSubmitting` serta `onPressed: null` mencegah double tap.

### Feature 2 — Dashboard

`dashboardSummaryProvider` mengamati `motorListProvider` dan membentuk `DashboardSummary`. Perubahan CRUD otomatis merambat ke jumlah motor, total kilometer, dan kendaraan terbaru tanpa pemanggilan storage kedua.

## Local data dan persistence

Model lokal `Motor` berisi UUID, merek, model, tahun, kilometer, dan waktu dibuat. `SharedPreferencesMotorRepository` menyimpan JSON array dengan key berversi `aku_motor.motors.v1`.

- Create: membuat UUID dan menyimpan model baru.
- Read: membaca JSON dan mapping ke `Motor`.
- Update: mengganti data berdasarkan ID.
- Delete: menghapus data berdasarkan ID.
- Persistence: repository/session baru membaca key yang sama. Web memakai storage browser; Android memakai penyimpanan aplikasi native.

## Routing dan reusable widget

- `/` → `DashboardScreen`
- `/motors` → `MotorListScreen`
- `EmptyState` dipakai untuk kondisi data kosong.
- `ErrorState` memuat pesan dan callback retry.
- Tema terpusat pada `AppTheme`.

## Strategi test

- Widget test: loading, success, empty, error+retry, validasi, dan submit loading/no double tap.
- Widget test dashboard: ringkasan berasal dari state motor.
- Repository test: create, reopen/read, update, dan delete dengan mock storage.
- Repository di-inject melalui provider override agar test tidak bergantung pada platform.

Fitur Part, Riwayat Servis, Profil Penggunaan, dan Edukasi selanjutnya mengikuti pola vertikal yang sama. Saat sinkronisasi server dipakai, implementasi repository dapat menggabungkan database lokal dengan REST API yang sudah ada.
