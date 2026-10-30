# Aku Motor

Aku Motor adalah aplikasi Flutter untuk membantu pemilik sepeda motor memantau kondisi kendaraan, mencatat riwayat penggantian komponen (oli, ban, rem, v-belt, dll.), mengaktifkan pengingat servis otomatis ke depannya, serta mengedukasi pengguna tentang akibat nyata jika terlambat melakukan perawatan (tanpa fitur diagnosa gejala teknis).

Aplikasi mengadopsi arsitektur berlapis vertikal (*vertical slice*) yang mendukung penyimpanan lokal *offline-first* via `shared_preferences` maupun integrasi REST API dengan backend Express/Prisma di `apps/api`.

---

## Fitur Utama

### 1. Manajemen Motor (Feature Inti)
- Pencatatan motor milik pengguna (merek, model, tahun pembuatan, dan kilometer saat ini).
- Operasi CRUD lengkap dengan form tervalidasi.
- Guard submit `_isSubmitting` dengan tombol *disabled* untuk mencegah *double tap*.
- Mendukung dua implementasi penyimpanan: `SharedPreferencesMotorRepository` (lokal) dan `ApiMotorRepository` (REST API).

### 2. Pengingat Servis & Catatan Perawatan (Maintenance Reminder)
- Pencatatan kapan terakhir servis atau ganti komponen:
  - **Oli Mesin**
  - **Oli Gardan / Transmisi**
  - **V-Belt**
  - **Roller CVT**
  - **Kampas Rem**
  - **Ban**
  - **Aki**
  - **Filter Udara**
- Kalkulasi otomatis sisa jarak tempuh (`remainingKm`) dan estimasi waktu (`remainingDays`).
- Status kesehatan komponen:
  - 🟢 **Aman**: Kondisi normal dalam rentang rekomendasi.
  - 🟡 **Perhatian**: Mendekati batas kilometer/waktu (sisa $\le 20\%$ interval atau $\le 14$ hari).
  - 🔴 **Ganti Segera**: Sudah melewati batas kilometer atau waktu rekomendasi.

### 3. Edukasi Akibat Komponen ("Kalo gak diganti bakal apa?")
- Menjelaskan alasan mengapa suatu komponen rawan aus dan butuh perhatian lebih.
- Memberikan informasi edukasi **akibat nyata bukan penyebab**, tanpa fitur diagnosa gejala/suara:
  - **1. Akibat Ringan**: Tarikan berat, mesin panas, konsumsi bensin boros.
  - **2. Akibat Sedang**: Komponen pendukung lain mulai tergerus aus.
  - **3. Akibat Fatal**: Mesin jebol/seher ngancing, v-belt putus di jalan, rem blong kecelakaan.
- **Perbandingan Biaya Nyata**: Biaya penggantian tepat waktu vs Biaya turun mesin/perbaikan jika kerusakan merembet.

### 4. Proses Booking Servis Bengkel
- Formulir booking jadwal servis ke bengkel resmi atau mitra.
- Validasi nama motor, bengkel tujuan, jenis layanan servis, tanggal servis, dan keluhan perawatan.
- Guard anti *double-tap* saat proses konfirmasi booking.

### 5. Dashboard Terpadu
- Merangkum total motor, total kilometer kendaraan, dan motor terbaru secara reaktif.
- Navigasi cepat menuju **Kelola motor**, **Pengingat servis**, **Booking servis**, dan **Bengkel terdekat (GPS)**.
- Integrasi ikon profil pengguna (Autentikasi), lonceng badge notifikasi, serta tombol Bantuan Darurat SOS (Sensor).

### 6. Integrasi 5 Fitur Tingkat Lanjut (Advanced Features)
- **Autentikasi Pengguna & Profil (`features/auth`)**:
  - Melindungi data kendaraan pribadi, sinkronisasi multi-device, dan mencegah tercampurnya catatan motor antarpengguna.
  - Akun demo instan (`budi@akumotor.id` / `password123`), mode tamu (*guest mode*), pendaftaran akun baru, ubah profil nama/telepon, dan konfirmasi logout.
- **Notifikasi Servis Cerdas (`features/notifications`)**:
  - Mengirimkan pengingat proaktif sebelum batas rekomendasi oli mesin, v-belt, atau kampas rem habis.
  - Manajemen izin notifikasi (*granted*, *denied*, *notDetermined*), badge jumlah belum dibaca, filter unread, serta tombol simulasi pengingat.
- **Lokasi Bengkel Terdekat & Integrasi GPS (`features/locations`)**:
  - Menghitung jarak real-time menggunakan formula Haversine ke bengkel resmi terdekat (AHASS Honda, Yamaha Sentral, Kawasaki, Suzuki, Bengkel Umum Mitra).
  - Penanganan izin lokasi GPS, filter kategori merek, panggilan telepon bengkel, dan aksi 1-klik "Booking di Sini" yang otomatis mengisi nama bengkel ke form booking.
- **Kamera & Bukti Foto Nota Servis (`features/camera`)**:
  - Mengabadikan bukti fisik nota bengkel atau foto kilometer odometer sebagai bukti perawatan valid.
  - Penanganan izin kamera, penanganan pembatalan (*cancellation handling*) saat batal foto, serta pratinjau nota digital (`PhotoPreviewDialog`).
- **Sensor Guncangan & Bantuan Darurat SOS (`features/sensor`)**:
  - Deteksi situasi darurat saat motor mogok di jalan raya.
  - Akses cepat 1-sentuhan ke derek resmi Jasa Marga 24 jam (14080), Honda Care (1-500-989), YES Yamaha (021-4618000), dan Polisi (110).

---

## State Management & 6 Kondisi UI

Seluruh fitur menggunakan **Flutter Riverpod** (`AsyncNotifier`, `Provider`) secara konsisten dan mematuhi minimal 6 kondisi antarmuka pengguna (UI):

1. **Initial Loading**: Menampilkan indikator loading saat data pertama kali diambil dari repository.
2. **Data Loaded (Success)**: Menampilkan data dalam bentuk daftar kartu yang rapi.
3. **Empty State**: Menampilkan pesan informatif dan tombol Call-To-Action (CTA) saat data kosong.
4. **Error State + Retry**: Menampilkan pesan kesalahan dan tombol **Coba lagi** yang memanggil ulang `notifier.reload()`.
5. **Validasi Form**: Validator pada form memeriksa kelengkapan data sebelum diproses.
6. **Submit Loading & Anti Double-Tap**: Mengunci tombol (`onPressed: null`) dan menampilkan spinner saat submit berlangsung agar pengguna tidak dapat melakukan klik ganda.

---

## Local Data & Persistence

Penyimpanan lokal menggunakan `shared_preferences` yang berjalan di Android (disk native) dan Web (browser `localStorage`):

- Skema JSON array berversi untuk menjamin integritas data:
  - `aku_motor.motors.v1`: Data kendaraan bermotor.
  - `aku_motor.maintenance.v1`: Catatan servis komponen dan pengingat.
  - `aku_motor.bookings.v1`: Jadwal booking servis bengkel.
- Setiap entitas model dilengkapi metode serialisasi `toJson()` dan deserialisasi `fromJson()`.
- Data terbukti tetap tersimpan setelah aplikasi ditutup dan dibuka kembali, atau browser di-refresh.

---

## Integrasi Backend REST API (Vertical Slice)

Tersedia klien API terisolasi di `core/network/api_client.dart` dan implementasi `ApiMotorRepository` yang terhubung ke backend Express/Prisma (`apps/api`):

- **GET `/api/motors`**: Memuat daftar motor (menangani state *loading*, *empty*, *error*, dan *success*).
- **POST `/api/motors`**: Menyimpan data motor baru ke database.
- **PUT `/api/motors/:Id`**: Memperbarui data motor di server.
- **DELETE `/api/motors/:Id`**: Menghapus data motor dari server.

---

## Struktur Direktori

```text
Aku-Motor/
├── apps/
│   ├── web/                                  # Aplikasi Flutter (Android & Web)
│   │   ├── lib/
│   │   │   ├── core/
│   │   │   │   ├── network/api_client.dart   # Abstraksi REST API Client
│   │   │   │   └── theme/app_theme.dart      # Tema Material 3 terpusat
│   │   │   ├── features/
│   │   │   │   ├── dashboard/                # Ringkasan & navigasi cepat
│   │   │   │   ├── motors/                   # CRUD Motor (Local & API)
│   │   │   │   ├── maintenance/              # Reminder & Edukasi Akibat
│   │   │   │   └── bookings/                 # Proses Booking Servis
│   │   │   ├── shared/widgets/               # EmptyState, ErrorState reusable
│   │   │   ├── app.dart                      # Routing aplikasi
│   │   │   └── main.dart                     # Entry point & ProviderScope
│   │   └── test/                             # Test suite (Unit, Widget, Persistence)
│   │
│   └── api/                                  # Backend REST API Express/Prisma
│       └── src/routes/motorRoutes.ts         # Endpoint /api/motors
│
├── packages/
│   └── shared/                               # DTO dan Model TypeScript shared
├── docs/
│   ├── AI_USAGE.md                           # Prompt AI dan catatan review manual
│   └── VERIFICATION.md                       # Laporan verifikasi dan status SDK
├── Architecture.md                           # Dokumentasi teknis arsitektur lengkap
└── README.md
```

---

## Panduan Menjalankan Proyek

### Prasyarat
- Flutter SDK (stable)
- Google Chrome atau Android Emulator
- Node.js & npm (opsional jika ingin menjalankan backend lokal)

### 1. Menjalankan Frontend Flutter (`apps/web`)
```bash
cd apps/web
flutter pub get
flutter run -d chrome
```

### 2. Menjalankan Backend API (`apps/api`) *(Opsional)*
```bash
cd apps/api
npm install
npm run dev
```
Backend berjalan pada `http://localhost:3000` dengan endpoint `/api/motors`.

---

## Pengujian Otomatis (Test Suite)

Jalankan seluruh pengujian dari direktori `apps/web`:

```bash
cd apps/web
flutter test
```

### Cakupan Pengujian:
1. **Unit Test Integrasi API & Model (Minimal 6 Skenario Wajib)**:
   - Terletak pada:
     - `test/features/motors/domain/motor_test.dart` (Unit Test Model)
     - `test/features/motors/data/api_motor_repository_test.dart` (Unit Test Repository)
     - `test/features/motors/api_motor_repository_test.dart` (Suite Unit Test Terpadu)
   - 6 Skenario Unit Test Individual:
     - `Unit Test 1 (model valid)`: Deserialisasi JSON valid dari backend sukses
     - `Unit Test 2 (model invalid)`: JSON tidak lengkap/salah melempar `FormatException`
     - `Unit Test 3 (API sukses)`: Endpoint HTTP 200 mengembalikan `List<Motor>`
     - `Unit Test 4 (data kosong)`: Endpoint HTTP 200 dengan payload `[]` mengembalikan list kosong
     - `Unit Test 5 (HTTP gagal)`: Endpoint HTTP 500 melempar `ApiException`
     - `Unit Test 6 (JSON rusak)`: Payload HTTP 200 malformed melempar `FormatException`
     - *(Tambahan)* `Unit Test 7` (Create/POST), `Unit Test 8` (Update/PUT), `Unit Test 9` (Delete/DELETE)
2. **Vertical Slice & State Test**:
   - `test/features/motors/api_vertical_slice_test.dart`: Menguji transisi UI Loading, Error, Retry, Empty, dan Success yang terhubung dengan API.
3. **Local Data Persistence Test**:
   - `test/features/motors/motor_vertical_persistence_test.dart`: Menguji alur dari UI Form hingga `SharedPreferences` dan membuktikan data tetap ada setelah restart aplikasi.
   - `test/features/motors/data/shared_preferences_motor_repository_test.dart`: Lifecycle CRUD lokal.
   - `test/features/maintenance/data/shared_preferences_maintenance_repository_test.dart`: Persistensi reminder.
4. **Widget UI 6 Kondisi**:
   - `test/features/motors/presentation/motor_list_screen_test.dart`
   - `test/features/maintenance/presentation/maintenance_list_screen_test.dart` (termasuk modal edukasi akibat)
   - `test/features/bookings/presentation/booking_list_screen_test.dart`
   - `test/features/dashboard/presentation/dashboard_screen_test.dart`

---

## Panduan Demo Singkat untuk Reviewer

1. **Demo CRUD & Persistence Lokal**:
   - Buka aplikasi ➔ Buka menu **Kelola motor** ➔ Klik **Tambah motor**.
   - Masukkan: Honda Vario 160, tahun 2024, 8500 km ➔ Klik **Simpan motor**.
   - **Refresh halaman browser (F5)** ➔ Data motor tetap muncul (terbukti persisten).
   - Edit kilometer menjadi 9000 km ➔ Refresh browser lagi ➔ Nilai 9000 km tetap tersimpan.
   - Hapus motor ➔ Refresh browser ➔ Layar kembali ke kondisi kosong (*Empty State*).

2. **Demo Pengingat Servis & Edukasi Akibat**:
   - Masuk ke menu **Pengingat servis** ➔ Klik **Catat servis part**.
   - Pilih motor dan pilih komponen **Oli Mesin**, masukkan tanggal dan kilometer saat penggantian.
   - Periksa kartu status: Sisa jarak tempuh, estimasi hari, dan badge warna status (Aman / Perhatian / Ganti Segera).
   - Klik tombol **"Kalo Oli Mesin gak diganti bakal apa?"**.
   - Dialog akan menampilkan alasan rawan aus, 3 tingkatan akibat (Ringan, Sedang, Fatal), serta perbandingan biaya ganti tepat waktu vs biaya turun mesin jika merembet.

3. **Demo Kamera & Bukti Foto Nota**:
   - Buka form **Catat servis part** ➔ Klik **Ambil Foto Nota** (atau Galeri).
   - Foto nota terlampir dengan stempel waktu dan token unik.
   - Klik **Simpan catatan** ➔ Pada kartu servis, muncul badge **Nota**.
   - Ketuk badge **Nota** atau tombol gambar ➔ Dialog `PhotoPreviewDialog` menampilkan detail bukti servis fisik terverifikasi.

4. **Demo Lokasi & Bengkel Terdekat (GPS)**:
   - Dari Dashboard, ketuk tombol **Bengkel terdekat (GPS)** (atau dari layar Booking).
   - Tampil banner izin GPS: pilih **Izinkan** untuk menghitung jarak real-time dari posisi pengguna.
   - Gunakan filter merek: **Honda**, **Yamaha**, atau **Umum**.
   - Pilih salah satu bengkel (misal: AHASS 001) ➔ Ketuk **Booking di Sini**.
   - Form booking servis otomatis terbuka dengan nama bengkel yang sudah terisi (*pre-filled*).

5. **Demo Notifikasi Servis Cerdas**:
   - Dari Dashboard, ketuk ikon lonceng notifikasi (terdapat badge merah unread).
   - Tampil pusat notifikasi dengan banner izin notifikasi interaktif.
   - Ketuk **Simulasikan Pengingat Servis** (atau sistem otomatis membuat saat part memasuki status *Perhatian/Urgent*).
   - Ketuk notifikasi ➔ Status berubah menjadi terbaca (*read*), atau navigasi langsung ke menu terkait.

6. **Demo Autentikasi Pengguna & Profil**:
   - Dari Dashboard, ketuk ikon profil di kanan atas AppBar.
   - Jika belum login, terbuka layar **Masuk Akun** ➔ Ketuk **Isi Cepat Akun Demo (Budi)** atau masuk mode tamu.
   - Setelah masuk, ikon profil menampilkan avatar pengguna.
   - Ketuk profil untuk melihat detail email, telepon, edit profil, atau logout.

7. **Demo Sensor & Bantuan Darurat SOS**:
   - Dari Dashboard, ketuk tombol merah **SOS** di AppBar.
   - Dialog darurat menampilkan deteksi sensor guncangan dan nomor kontak derek resmi Jasa Marga 24 jam serta call center darurat.
