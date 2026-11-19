# Backlog Issues & Bug Tracker - Aku Motor

Dokumen ini berisi daftar minimal 10 issues (6 Bug Reports yang ditemukan saat pengujian & implementasi + 6 Feature Requests) yang siap dimasukkan ke **GitHub Issues** maupun **JIRA Software**.

---

## Ringkasan Backlog

| ID | Tipe | Judul Issue | Komponen | Prioritas | Status |
|---|---|---|---|---|---|
| **AKU-1** | 🐛 Bug | RenderFlex overflow 16px pada dropdown jenis layanan servis | `Bookings` | High | Resolved |
| **AKU-2** | 🐛 Bug | Horizontal Row overflow 23px pada kartu ringkasan Dashboard | `Dashboard` | High | Resolved |
| **AKU-3** | 🐛 Bug | Ambiguity & type mismatch method update pada AsyncNotifier Riverpod | `Motors` | Critical | Resolved |
| **AKU-4** | 🐛 Bug | UnimplementedError SharedPreferences saat eksekusi headless widget test | `Auth` / `Core` | High | Resolved |
| **AKU-5** | 🐛 Bug | Software keyboard menutupi tombol konfirmasi dan input form pada mobile | `UI / UX` | Medium | Resolved |
| **AKU-6** | 🐛 Bug | Tidak ada feedback visual (silent deletion) saat pembatalan booking & motor | `Feedback` | Medium | Resolved |
| **AKU-7** | 💡 Feature | Ekspor riwayat servis & nota perawatan ke dokumen PDF / CSV | `Maintenance` | Medium | Backlog |
| **AKU-8** | 💡 Feature | Background sync otomatis dari local storage ke REST API PostgreSQL | `Network / Data` | High | Backlog |
| **AKU-9** | 💡 Feature | Integrasi notifikasi push native terjadwal untuk batas kilometer oli | `Notifications`| High | Backlog |
| **AKU-10**| 💡 Feature | Autentikasi biometrik (Fingerprint & Face Unlock) pada akun pemilik | `Auth` | Low | Backlog |
| **AKU-11**| 💡 Feature | Peta interaktif & rute navigasi real-time menuju bengkel terdekat | `Locations` | Medium | Backlog |
| **AKU-12**| 💡 Feature | Mode tema gelap (Dark Theme) dinamis Material 3 | `Theme` | Low | Backlog |

---

## 1. Rincian Bug Reports (Minimal 5 Bug Found)

### 🐛 AKU-1: RenderFlex overflow 16px pada dropdown jenis layanan servis
- **Issue Type:** Bug
- **Severity / Priority:** High
- **Component:** `lib/features/bookings/presentation/booking_form_dialog.dart`
- **Environment:** Flutter 3.47.7, Android / Web (Screen width < 480px)
- **Deskripsi:**
  Ketika pengguna membuka dialog booking servis, dropdown jenis layanan yang memiliki teks panjang (contoh: *"Perbaikan Mesin & Kelistrikan"*) mengalami overflow sebesar 16 piksel ke kanan dan memunculkan garis kuning-hitam (layout error).
- **Langkah Reproduksi (Steps to Reproduce):**
  1. Buka aplikasi dan navigasikan ke halaman *Booking Servis*.
  2. Tekan tombol *Buat Booking*.
  3. Buka pilihan pada dropdown *Jenis layanan servis*.
  4. Amati bahwa pada layar dengan lebar terbatas, widget `Row` internal pada `DropdownButtonFormField` mengalami overflow horizontal.
- **Hasil Aktual (Actual Result):**
  `A RenderFlex overflowed by 16 pixels on the right` pada `DropdownButtonFormField<String>-[<'serviceTypeField'>]`.
- **Hasil yang Diharapkan (Expected Result):**
  Teks dropdown otomatis terpotong atau membungkus secara adaptif tanpa overflow dengan memanfaatkan `isExpanded: true`.
- **Solusi yang Diterapkan:**
  Menambahkan properti `isExpanded: true` pada `DropdownButtonFormField` dan membungkus dialog dengan `ConstrainedBox(maxWidth: 480)`.

---

### 🐛 AKU-2: Horizontal Row overflow 23px pada kartu ringkasan Dashboard
- **Issue Type:** Bug
- **Severity / Priority:** High
- **Component:** `lib/features/dashboard/presentation/dashboard_screen.dart`
- **Environment:** Mobile Portrait (< 380px)
- **Deskripsi:**
  Komponen `_SummaryCard` di halaman utama dashboard menggunakan widget `Row` yang membungkus ikon dan label secara kaku. Saat ditempatkan di dalam `Wrap`, layout gagal menghitung flex batas ruang sehingga teks "Total kilometer" overflow 23 piksel pada layar kecil.
- **Langkah Reproduksi (Steps to Reproduce):**
  1. Buka aplikasi pada perangkat beresolusi 360x640 portrait.
  2. Masuk ke halaman dashboard utama.
  3. Perhatikan kartu statistik total motor dan kilometer.
- **Hasil Aktual (Actual Result):**
  `RenderFlex overflowed by 23 pixels on the right` pada baris ikon kartu statistik.
- **Hasil yang Diharapkan (Expected Result):**
  Ukuran kartu statistik menyesuaikan ruang yang tersedia (`mainAxisSize: MainAxisSize.min`) tanpa overflow.
- **Solusi yang Diterapkan:**
  Mengubah `Row` menjadi ukuran natural dengan `mainAxisSize: MainAxisSize.min` dan melengkapi dengan semantik accessibility.

---

### 🐛 AKU-3: Ambiguity & type mismatch method update pada AsyncNotifier Riverpod
- **Issue Type:** Bug
- **Severity / Priority:** Critical (Compilation Blocker)
- **Component:** `lib/features/motors/application/motor_providers.dart`
- **Environment:** Flutter Riverpod 2.6.1, Dart SDK >=3.3.0
- **Deskripsi:**
  Method mutasi `update(String id, MotorDraft draft)` pada `MotorListNotifier` menabrak nama method bawaan framework Riverpod `AsyncNotifierBase.update(FutureOr<State> Function(State))`. Hal ini menyebabkan error kompilasi analyzer karena jumlah parameter dan tipe kembalian tidak kompatibel dengan method yang di-*override*.
- **Langkah Reproduksi (Steps to Reproduce):**
  1. Jalankan perintah `flutter analyze` atau `flutter test`.
  2. Compiler Dart memunculkan error: `The return type of the method 'MotorListNotifier.update' is 'Future<bool>', which does not match the return type, 'Future<List<Motor>>', of the overridden method, 'AsyncNotifierBase.update'`.
- **Hasil Aktual (Actual Result):**
  Kompilasi gagal saat proses build atau pengujian dijalankan.
- **Hasil yang Diharapkan (Expected Result):**
  Kode dapat dikompilasi dengan bersih dan fungsi pembaharuan data motor berjalan normal.
- **Solusi yang Diterapkan:**
  Mengubah nama method menjadi `updateMotor(String id, MotorDraft draft)` untuk menghindari bentrokan method dasar Riverpod.

---

### 🐛 AKU-4: UnimplementedError SharedPreferences saat eksekusi headless widget test
- **Issue Type:** Bug
- **Severity / Priority:** High
- **Component:** `lib/features/auth/application/auth_providers.dart`, `lib/features/notifications/application/notification_providers.dart`
- **Environment:** Automated CI / Unit & Widget Tests
- **Deskripsi:**
  Ketika widget test diinisialisasi tanpa mock explisit untuk `sharedPreferencesProvider`, provider repository melempar `UnimplementedError: SharedPreferences belum diinisialisasi` yang menyebabkan seluruh widget test yang bergantung pada state auth/notifikasi gagal dijalankan.
- **Langkah Reproduksi (Steps to Reproduce):**
  1. Jalankan `flutter test test/features/dashboard/presentation/dashboard_screen_test.dart`.
  2. Provider `authStateProvider` mencoba membaca `sharedPreferencesProvider` yang belum di-override.
- **Hasil Aktual (Actual Result):**
  Test gagal dengan `UnimplementedError`.
- **Hasil yang Diharapkan (Expected Result):**
  Provider otomatis melakukan fallback ke `InMemoryAuthRepository` atau `InMemoryNotificationRepository` bila SharedPreferences belum tersedia di lingkungan testing.
- **Solusi yang Diterapkan:**
  Menambahkan blok `try-catch` pada provider default untuk otomatis mengarahkan ke in-memory mock repository saat dijalankan di lingkungan pengujian.

---

### 🐛 AKU-5: Software keyboard menutupi tombol konfirmasi dan input form pada mobile
- **Issue Type:** Bug
- **Severity / Priority:** Medium
- **Component:** `lib/features/bookings/presentation/booking_form_dialog.dart`, `lib/features/auth/presentation/register_screen.dart`
- **Environment:** Android OS (Virtual Keyboard Aktif)
- **Deskripsi:**
  Saat pengguna mengetik catatan keluhan servis atau form registrasi, keyboard software menutupi tombol *Simpan / Konfirmasi*. Pengguna harus menutup keyboard secara manual dengan tombol *Back* sistem operasi untuk dapat menekan tombol aksi.
- **Langkah Reproduksi (Steps to Reproduce):**
  1. Buka form booking atau registrasi di layar smartphone portrait.
  2. Ketuk text field paling bawah (contoh: *Catatan keluhan*).
  3. Keyboard virtual muncul menutupi bagian bawah dialog.
- **Hasil Aktual (Actual Result):**
  Tombol *Konfirmasi Booking* tertutup keyboard dan tidak ada ruang gulir tambahan.
- **Hasil yang Diharapkan (Expected Result):**
  Input field otomatis bergeser ke atas keyboard dengan padding yang memadai (`scrollPadding: 80px`) dan keyboard otomatis menutup saat list digulir (`onDrag`).
- **Solusi yang Diterapkan:**
  Menambahkan `scrollPadding: const EdgeInsets.only(bottom: 80)` pada seluruh text field dan `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` pada SingleChildScrollView.

---

### 🐛 AKU-6: Tidak ada feedback visual (silent deletion) saat pembatalan booking & motor
- **Issue Type:** Bug
- **Severity / Priority:** Medium
- **Component:** `lib/features/bookings/presentation/booking_list_screen.dart`, `lib/features/motors/presentation/motor_list_screen.dart`
- **Environment:** Mobile / Web
- **Deskripsi:**
  Saat pengguna mengonfirmasi pembatalan booking atau penghapusan motor, dialog tertutup seketika tanpa indikator progress atau notifikasi konfirmasi. Pengguna tidak mengetahui apakah proses berhasil, gagal, atau masih menunggu response I/O storage.
- **Langkah Reproduksi (Steps to Reproduce):**
  1. Masuk ke halaman *Booking Servis*.
  2. Pilih menu opsi titik tiga pada salah satu kartu -> pilih *Batalkan*.
  3. Tekan *Batalkan booking*.
- **Hasil Aktual (Actual Result):**
  Tidak ada indikator loading atau feedback SnackBar; aksi terkesan menggantung jika operasi I/O lambat.
- **Hasil yang Diharapkan (Expected Result):**
  Muncul SnackBar progress sementara yang diikuti SnackBar status hasil operasi ("Booking servis berhasil dibatalkan").
- **Solusi yang Diterapkan:**
  Mengimplementasikan feedback interaktif berupa `SnackBar(behavior: SnackBarBehavior.floating)` dengan indikator progress dan notifikasi sukses/gagal.

---

## 2. Rincian Fitur Tambahan (Feature Requests)

### 💡 AKU-7: Ekspor riwayat servis & nota perawatan ke dokumen PDF / CSV
- **Issue Type:** Feature Request
- **Priority:** Medium
- **Component:** `Maintenance & Service History`
- **User Story:**
  *Sebagai* pemilik sepeda motor,
  *Saya ingin* dapat mengekspor rekap riwayat servis berkala dan bukti nota ke dalam file PDF atau spreadsheet CSV,
  *Agar* saya memiliki bukti rekam jejak perawatan fisik yang rapi saat mengajukan klaim garansi atau meningkatkan nilai jual kembali (*resale value*) motor saya.
- **Kriteria Penerimaan (Acceptance Criteria):**
  1. Terdapat tombol opsi "Ekspor Riwayat Servis (PDF/CSV)" pada halaman daftar perawatan.
  2. Dokumen PDF memuat nama motor, pelat nomor, total kilometer terkini, tabel riwayat servis (tanggal, bengkel, komponen, biaya), dan lampiran foto bukti nota servis.
  3. File dapat disimpan ke direktori download perangkat atau dibagikan langsung via aplikasi chat/email.

---

### 💡 AKU-8: Background sync otomatis dari local storage ke REST API PostgreSQL
- **Issue Type:** Feature Request
- **Priority:** High
- **Component:** `Network & Data Sync`
- **User Story:**
  *Sebagai* pengguna aplikasi Aku Motor,
  *Saya ingin* data motor dan booking yang saya buat secara offline otomatis disinkronkan ke server backend API saat perangkat mendapatkan koneksi internet,
  *Agar* data saya aman di cloud dan dapat diakses dari perangkat lain setelah login.
- **Kriteria Penerimaan (Acceptance Criteria):**
  1. Menggunakan queue offline sync dengan pendeteksi koneksi jaringan (`connectivity_plus`).
  2. Mengirim data lokal ke endpoint `POST /api/motors` dan `POST /api/bookings` di `apps/api`.
  3. Menangani resolusi konflik bila data di cloud lebih baru daripada data lokal.

---

### 💡 AKU-9: Integrasi notifikasi push native terjadwal untuk batas kilometer oli
- **Issue Type:** Feature Request
- **Priority:** High
- **Component:** `Notifications & Background Service`
- **User Story:**
  *Sebagai* pengendara harian,
  *Saya ingin* menerima push notification di status bar ponsel ketika interval kilometer oli mesin tersisa 300 km lagi,
  *Agar* saya tidak telat mengganti oli mesin meskipun aplikasi sedang tidak saya buka selama beberapa hari.
- **Kriteria Penerimaan (Acceptance Criteria):**
  1. Menggunakan alarm background lokal (`flutter_local_notifications` / Android WorkManager).
  2. Notifikasi memicu suara dan getaran peringatan level warning.
  3. Mengetuk notifikasi langsung membuka dialog detail edukasi akibat oli aus (*PartConsequenceDialog*).

---

### 💡 AKU-10: Autentikasi biometrik (Fingerprint & Face Unlock) pada akun pemilik
- **Issue Type:** Feature Request
- **Priority:** Low
- **Component:** `Authentication & Security`
- **User Story:**
  *Sebagai* pengguna akun terdaftar,
  *Saya ingin* dapat masuk ke aplikasi menggunakan sensor sidik jari atau Face Unlock perangkat,
  *Agar* proses verifikasi identitas berjalan lebih cepat tanpa repot mengetikkan kata sandi setiap kali membuka aplikasi.
- **Kriteria Penerimaan (Acceptance Criteria):**
  1. Opsi "Aktifkan Masuk dengan Biometrik" pada pengaturan profil akun.
  2. Mendukung prompt biometrik native Android (Fingerprint / Face ID).
  3. Menyediakan fallback ke kata sandi manual bila sensor biometrik gagal atau tidak dikenali.

---

### 💡 AKU-11: Peta interaktif & rute navigasi real-time menuju bengkel terdekat
- **Issue Type:** Feature Request
- **Priority:** Medium
- **Component:** `Workshops & GPS Navigation`
- **User Story:**
  *Sebagai* pengendara yang mengalami kendala teknis di perjalanan,
  *Saya ingin* melihat visual peta interaktif dengan pin lokasi bengkel terdekat dan petunjuk rute mengemudi langsung dari posisi saya saat ini,
  *Agar* saya dapat memilih bengkel yang paling mudah dijangkau dengan estimasi waktu tempuh yang akurat.
- **Kriteria Penerimaan (Acceptance Criteria):**
  1. Menyematkan widget peta interaktif (Google Maps / OpenStreetMap) pada halaman *Bengkel Terdekat (GPS)*.
  2. Marker bengkel menampilkan rating, jam buka, dan kategori merek motor.
  3. Terdapat tombol "Buka Petunjuk Arah" yang otomatis membuka Google Maps / Waze menuju koordinat bengkel terkait.

---

### 💡 AKU-12: Mode tema gelap (Dark Theme) dinamis Material 3
- **Issue Type:** Feature Request
- **Priority:** Low
- **Component:** `Theme & Accessibility`
- **User Story:**
  *Sebagai* pengendara yang sering memeriksa aplikasi pada malam hari,
  *Saya ingin* aplikasi mendukung Dark Theme yang otomatis mengikuti tema sistem operasi atau dipilih secara manual,
  *Agar* tampilan layar tidak menyilaukan mata dan lebih hemat daya baterai pada perangkat layar AMOLED.
- **Kriteria Penerimaan (Acceptance Criteria):**
  1. Menyediakan palet warna `AppTheme.dark` sesuai standar Material Design 3.
  2. Opsi pengaturan tema: *Sistem*, *Terang*, atau *Gelap*.
  3. Kontras warna teks dan kartu telah memenuhi standar aksesibilitas WCAG AA (minimal kontras 4.5:1).
