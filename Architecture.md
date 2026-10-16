# Arsitektur Aku Motor — Flutter

## Tujuan dan prototype

Aku Motor dirancang untuk membantu pemilik sepeda motor:
1. **Mencatat motor yang dimiliki** beserta jarak tempuh (kilometer) saat ini.
2. **Mencatat kapan terakhir servis atau ganti komponen** (oli mesin, oli gardan, ban, kampas rem, v-belt, roller CVT, aki, filter udara).
3. **Membuat pengingat (reminder) otomatis** ke depannya berdasarkan interval kilometer dan waktu pemakaian.
4. **Mengedukasi pengguna tentang komponen yang rawan rusak** dan butuh perhatian lebih.
5. **Mengedukasi akibat keterlambatan servis ("Part ini kalo gak diganti bakal apa?")**:
   - Menampilkan 3 tingkatan akibat nyata (Ringan, Sedang, Fatal).
   - Menampilkan perbandingan biaya nyata: biaya ganti sekarang vs biaya turun mesin/perbaikan jika merembet.
   - **Tanpa fitur gejala / tanpa diagnosa teknis**: Aplikasi berfokus memberi tahu *akibat* dan konsekuensi kelalaian, bukan mendiagnosa penyebab atau gejala.

## Struktur proyek

```text
apps/web/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/theme/
│   ├── features/
│   │   ├── dashboard/{application,presentation}/
│   │   ├── maintenance/{application,data,domain,presentation}/
│   │   ├── motors/{application,data,domain,presentation}/
│   │   └── bookings/{application,data,domain,presentation}/
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

Riverpod digunakan secara konsisten pada seluruh fitur aplikasi dengan pola `AsyncNotifier` dan `Provider`.

### Feature 1 — Manajemen Motor

`motorListProvider` adalah `AsyncNotifierProvider<MotorListNotifier, List<Motor>>`.

| Kondisi | Representasi | UI |
|---|---|---|
| Initial loading | `AsyncLoading` | Indikator loading (`initialLoading`) |
| Berhasil, ada data | `AsyncData<List<Motor>>` | Daftar card motor (`motorList`) |
| Berhasil, kosong | `AsyncData([])` | Empty state dan tombol CTA |
| Error | `AsyncError` | Pesan dan tombol **Coba lagi** |
| Form tidak valid | validator `Form` | Pesan validasi per field |
| Sedang submit | `_isSubmitting == true` | Spinner dan tombol disabled (anti double tap) |

Create, update, dan delete berada pada notifier. Guard `_isSubmitting` serta `onPressed: null` mencegah double tap.

### Feature 2 — Pengingat Servis & Edukasi Akibat Komponen

`maintenanceListProvider` adalah `AsyncNotifierProvider<MaintenanceListNotifier, List<MaintenanceRecord>>`.

Fitur ini menjawab tujuan inti Aku Motor: mencatat kapan terakhir ganti oli, ban, rem, v-belt, dll., menghitung sisa jarak tempuh dan estimasi hari untuk pengingat masa depan, serta memberikan edukasi **akibat jika tidak diganti** (tanpa fitur diagnosa gejala teknis).

| Kondisi | Representasi | UI |
|---|---|---|
| Initial loading | `AsyncLoading` | Indikator loading (`initialLoading`) |
| Berhasil, ada data | `AsyncData<List<MaintenanceRecord>>` | Daftar kartu status part dengan badge Aman/Perhatian/Ganti Segera, sisa km, sisa hari, dan tombol edukasi akibat |
| Berhasil, kosong | `AsyncData([])` | Empty state panduan dan CTA catat servis pertama |
| Error | `AsyncError` | Pesan error dan tombol **Coba lagi** (retry) |
| Form tidak valid | validator `Form` | Validasi input kilometer angka valid dan tanggal ganti |
| Sedang submit | `_isSubmitting == true` | Tombol submit dinonaktifkan dan spinner aktif (anti double tap) |

Dialog **Edukasi Akibat ("Kalo gak diganti bakal apa?")** menampilkan:
1. Alasan komponen tersebut rawan aus.
2. 3 Level akibat nyata: Ringan, Sedang, Fatal.
3. Perbandingan biaya: Ganti tepat waktu vs Biaya turun mesin/perbaikan fatal.

### Feature 3 — Dashboard & Navigasi

`dashboardSummaryProvider` mengamati data motor dan mengintegrasikan aksi cepat ke **Pengingat servis**, **Kelola motor**, dan **Booking servis**.

## Local data dan persistence

Aplikasi mengimplementasikan penyimpanan lokal offline-first menggunakan `shared_preferences` yang berjalan di Android (native SharedPreferences) maupun Web (browser localStorage).

### 1. Data Model & Serialisasi
Data disimpan dalam bentuk JSON array berversi untuk memastikan integritas skema data:
- `aku_motor.motors.v1`: untuk data entitas `Motor` (`id`, `brand`, `model`, `year`, `currentKilometer`, `createdAt`).
- `aku_motor.maintenance.v1`: untuk catatan entitas `MaintenanceRecord` (`id`, `motorId`, `partType`, `lastReplacedAt`, `lastReplacedKilometer`, `notes`, `createdAt`).
- `aku_motor.bookings.v1`: untuk entitas `Booking`.

Setiap model memiliki metode:
- `toJson()`: Serialisasi objek Dart menjadi format `Map<String, dynamic>` sebelum dienkode ke JSON string.
- `fromJson()`: Deserialisasi string JSON kembali menjadi objek Dart yang *type-safe* dan *immutable*.

### 2. Implementasi CRUD Vertikal (FE ➔ State Notifier ➔ Repository ➔ Local Storage)

| Operasi | Alur UI / Notifier | Mekanisme di Repository | Penyimpanan Lokal (`shared_preferences`) |
|---|---|---|---|
| **Create** | Form modal input data ➔ `notifier.create(draft)` | `_uuid.v4()` digenerate, data baru ditambahkan ke list | List dienkode ke JSON dan disimpan via `_preferences.setString(key, encoded)` |
| **Read** | `ref.watch(provider)` saat layar dibuka | `getAll()` membaca string dari storage dan mendeserialisasi | `_preferences.getString(key)` dibaca langsung dari storage lokal |
| **Update** | Form edit data ➔ `notifier.update(id, draft)` | Mencari elemen berdasarkan ID, memperbarui field (`copyWith`) | Array yang diperbarui disimpan ulang ke storage lokal |
| **Delete** | Dialog konfirmasi hapus ➔ `notifier.delete(id)` | Menghapus elemen bersangkutan dari list (`removeWhere`) | Array tanpa item tersebut disimpan ulang ke storage lokal |

### 3. Pengujian Persistence (Persistence Test)

Dua level pengujian persistensi telah diimplementasikan:
1. **Repository-Level Persistence Test** ([`shared_preferences_motor_repository_test.dart`](test/features/motors/data/shared_preferences_motor_repository_test.dart)):
   - Menjalankan sesi repository pertama untuk membuat data.
   - Menginisialisasi sesi baru (`reopenedSession`) dan memverifikasi data yang sama langsung terbaca dari storage.
   - Melakukan update dan delete, lalu memverifikasi session baru membaca perubahan yang persisten.
2. **End-to-End Vertical Persistence Test** ([`motor_vertical_persistence_test.dart`](test/features/motors/motor_vertical_persistence_test.dart)):
   - Menguji alur lengkap dari UI Flutter (Form dialog) hingga SharedPreferences.
   - Mensimulasikan **penutupan aplikasi / restart session** (pemberian `ProviderScope` baru) dan membuktikan data motor tetap muncul di layar tanpa hilang.

## Routing dan reusable widget

- `/` → `DashboardScreen`
- `/motors` → `MotorListScreen`
- `/maintenance` → `MaintenanceListScreen`
- `/bookings` → `BookingListScreen`
- `EmptyState` dipakai untuk kondisi data kosong (mendukung kustomisasi ikon).
- `ErrorState` memuat pesan error dan callback retry.
- Tema terpusat pada `AppTheme`.

## Strategi test

- **Widget test**: loading, success, empty, error+retry, validasi, dan submit loading/no double tap.
- **Vertical Persistence test**: CRUD lengkap dari UI hingga storage dengan simulasi app restart.
- **Repository test**: create, reopen/read, update, dan delete dengan mock storage.

Fitur Part, Riwayat Servis, Profil Penggunaan, dan Edukasi selanjutnya mengikuti pola vertikal yang sama. Saat sinkronisasi server dipakai, implementasi repository dapat menggabungkan database lokal dengan REST API yang sudah ada.
