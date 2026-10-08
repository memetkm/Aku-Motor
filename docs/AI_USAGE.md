# Penggunaan AI dan Review Kode

## Prompt yang digunakan

> Buat fitur Pengingat Servis (Maintenance Reminder) dan Edukasi Akibat Komponen pada Flutter menggunakan Riverpod AsyncNotifier. Fitur memungkinkan user mencatat kapan terakhir ganti oli, ban, v-belt, kampas rem, aki, dll beserta tanggal dan kilometer. Aplikasi menghitung sisa km dan hari untuk pengingat masa depan, menentukan status Aman/Perhatian/Ganti Segera, serta mengedukasi pengguna tentang akibat nyata jika telat ganti (Ringan, Sedang, Fatal, & Perbandingan Biaya) tanpa menyertakan fitur gejala teknis. Sediakan 6 kondisi UI lengkap (loading, success, empty, error+retry, form validation, submit double-tap prevention) dan widget test.

## Bagian yang diperiksa dan diperbaiki manual

- Widget bergantung pada provider (`AsyncNotifier`), bukan langsung pada plugin storage.
- Kontrak `MotorRepository` dan `MaintenanceRepository` dapat diganti dan di-override saat test melalui fake repository.
- Submit form memiliki guard `_isSubmitting` sekaligus tombol disabled untuk mencegah double tap.
- Kegagalan load memiliki aksi retry (`ErrorState`).
- Logika pengingat (`calculateStatus`, `calculateRemainingKm`, `calculateRemainingDays`) dihitung dinamis dari data motor dan katalog interval.
- Dialog edukasi komponen berfokus murni pada **akibat** (bukan gejala maupun penyebab) dan menyajikan estimasi perbandingan biaya nyata penggantian vs biaya turun mesin jika merembet.
- JSON memakai key stabil dan berversi (`aku_motor.motors.v1`, `aku_motor.maintenance.v1`).
- Seluruh 6 kondisi UI dan persistensi CRUD dicakup oleh test suite otomatis.
