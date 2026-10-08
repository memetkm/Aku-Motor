# Penggunaan AI dan Review Kode

## Prompt yang digunakan

> Migrasi frontend Aku Motor dari React ke Flutter. Gunakan Riverpod secara konsisten. Buat satu vertical feature Manajemen Motor dari UI sampai shared_preferences dengan model dan CRUD. UI wajib memiliki initial loading, success, empty, error dengan retry, validasi form, dan loading submit yang mencegah double tap. Tambahkan feature Dashboard yang membaca state motor secara reaktif. Pisahkan widget, notifier/application, domain, dan repository. Buat widget test setiap state utama serta persistence test. Gunakan label dan pesan Bahasa Indonesia.

## Bagian yang diperiksa dan diperbaiki manual

- Widget bergantung pada provider, bukan langsung pada plugin storage.
- Kontrak `MotorRepository` dapat diganti dan di-override saat test.
- Submit memiliki guard `_isSubmitting` sekaligus tombol disabled.
- Kegagalan load memiliki aksi retry.
- JSON memakai key stabil dan berversi.
- Create, read melalui session baru, update, dan delete tercakup test persistence.
- Perubahan daftar motor otomatis memperbarui dashboard.
- Perubahan backend yang sudah ada dipertahankan; hanya frontend kosong yang diganti.

Pemilik submission tetap perlu menjelaskan aliran `Widget → Notifier → Repository → shared_preferences`, dependency injection pada test, dan perbedaan loading awal dengan loading submit.
