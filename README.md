# Aku Motor

Aplikasi yang memberi tahu pemilik motor kapan part harus diganti dan apa akibatnya kalau dibiarkan.

---

## Deskripsi Masalah

Sebagian besar pemilik sepeda motor di Indonesia tidak tahu jadwal servis yang tepat untuk motornya. Buku manual jarang dibaca, saran bengkel sering tidak netral, dan informasi di internet tersebar serta tidak spesifik ke model motor.

Akibatnya:

- Part kritis seperti v-belt, kampas rem, dan oli sering diganti setelah rusak, bukan sebelum.
- Biaya perbaikan membengkak karena part lain ikut rusak.
- Risiko keselamatan meningkat, terutama untuk rem dan ban.
- Pemilik motor tidak punya gambaran "kalau ini dibiarkan, apa yang terjadi".

Reminder servis biasa hanya mengingatkan kapan, tanpa menjelaskan kenapa penting dan apa risikonya. Aku Motor menutup celah itu.

---

## Profil Target Pengguna

**Primer:**

- Pemilik sepeda motor harian, usia 18–40 tahun.
- Motor matic dan bebek 110–160cc (Vario, Beat, NMAX, Mio, Supra, Scoopy, Aerox, PCX).
- Pemakai harian: kerja, sekolah, ojek online, antar anak.
- Tidak paham teknis mesin, tapi ingin merawat motornya dengan benar.
- Pernah mengalami mogok atau biaya servis tak terduga.

**Sekunder:**

- Orang tua yang membelikan motor untuk anak.
- Pemilik motor bekas tanpa riwayat servis lengkap.
- Kurir atau driver ojol dengan pemakaian intens.

**Bukan target:**

- Pemilik moge atau motor sport yang sudah paham teknis.
- Bengkel atau mekanik profesional.
- Pengguna yang ingin jual-beli motor atau sparepart.

---

## Manfaat Aplikasi

1. Mencegah kerusakan sebelum terjadi — user tahu part mana yang mendekati batas dan apa risikonya.
2. Menghemat biaya — ganti part kecil lebih awal, hindari kerusakan part besar.
3. Meningkatkan keselamatan — terutama untuk rem, ban, dan CVT.
4. Mengedukasi tanpa menggurui — belajar dari konsekuensi nyata, bukan artikel panjang.
5. Menjaga nilai jual motor — riwayat servis tercatat menaikkan kepercayaan calon pembeli.
6. Personalisasi nyata — jadwal servis menyesuaikan cara pakai, medan, dan gaya bawa.

---

## Daftar Fitur Inti

| # | Fitur | Deskripsi |
|---|-------|-----------|
| 1 | Input Motor | Merk, tipe, tahun, kilometer saat ini. Tersedia daftar model populer Indonesia. |
| 2 | Input Riwayat Terakhir | Catat kapan terakhir ganti oli, ban, aki, CVT/rantai, servis rutin. |
| 3 | Input Cara Pakai | Km/hari, medan, gaya bawa, sering bonceng, sering hujan. |
| 4 | Dashboard Status Part | Setiap part berstatus **Aman**, **Perhatian**, atau **Segera**. |
| 5 | Reminder Adaptif + Notifikasi | Jadwal dihitung ulang dari cara pakai. Notifikasi saat part masuk zona perhatian. |
| 6 | Edukasi Akibat per Part | Kartu berisi akibat jika dibiarkan (3 level) + biaya sekarang vs nanti. |
| 7 | Kartu Riwayat Servis | Riwayat bisa diekspor sebagai gambar/PDF untuk dokumentasi atau jual motor. |

---

## Fitur yang Tidak Dikerjakan

Fitur berikut sengaja ditunda agar MVP selesai dalam 12 pertemuan:

- Fitur gejala / diagnosa
- Marketplace bengkel atau booking
- Komunitas / feed / komentar
- Jual-beli sparepart
- AI suara mesin atau getaran
- GPS otomatis (km diinput manual)
- Multi-kendaraan per akun
- Integrasi OBD
- Pembayaran dalam app
- Versi iOS (fokus Android dulu)
- Machine learning (pakai rumus sederhana)

---

## Kriteria Aplikasi Dinyatakan Berhasil

**Fungsional:**

- [ ] User bisa daftar motor dan isi riwayat dalam < 3 menit.
- [ ] Dashboard menampilkan status semua part dengan benar.
- [ ] Notifikasi muncul tepat waktu sesuai perhitungan adaptif.
- [ ] Kartu edukasi akibat tampil untuk setiap part.
- [ ] Riwayat servis bisa diekspor dan dibuka di perangkat lain.

**Pengguna:**

- [ ] Minimal 10 penguji menyelesaikan onboarding tanpa bantuan.
- [ ] Minimal 70% penguji paham "akibat kalau dibiarkan" setelah baca kartu edukasi.
- [ ] Minimal 50% penguji membuka app lagi dalam 7 hari.

**Teknis:**

- [ ] Berjalan stabil di Android 8.0+.
- [ ] Waktu muat dashboard < 2 detik.
- [ ] Tidak ada crash saat input atau ekspor.
- [ ] Data tersimpan lokal dan tersinkron ke server.
