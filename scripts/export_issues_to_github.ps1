# Script untuk mengunggah otomatis daftar 12 issues backlog ke GitHub Issues
# Jalankan dengan: .\scripts\export_issues_to_github.ps1 -Token "YOUR_GITHUB_PERSONAL_ACCESS_TOKEN"

param(
    [Parameter(Mandatory=$false)]
    [string]$Token = $env:GITHUB_TOKEN,
    [string]$Repo = "memetkm/Aku-Motor"
)

if (-not $Token) {
    Write-Host "[!] Masukkan GitHub Personal Access Token (PAT) atau set `$env:GITHUB_TOKEN terlebih dahulu." -ForegroundColor Yellow
    Write-Host "Contoh: .\scripts\export_issues_to_github.ps1 -Token ghp_xxxx" -ForegroundColor Cyan
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $Token"
    "Accept"        = "application/vnd.github.v3+json"
    "User-Agent"    = "Aku-Motor-Issue-Uploader"
}

$issues = @(
    @{
        title = "[BUG] RenderFlex overflow 16px pada dropdown jenis layanan servis"
        body = "**Komponen**: Bookings\n**Severity**: High\n\n**Deskripsi**:\nPada dialog booking servis, pilihan jenis layanan panjang seperti 'Perbaikan Mesin & Kelistrikan' menyebabkan RenderFlex overflow 16px pada layar sempit.\n\n**Solusi**:\nMenambahkan `isExpanded: true` pada `DropdownButtonFormField`."
        labels = @("bug", "ui/ux", "resolved")
    },
    @{
        title = "[BUG] Horizontal Row overflow 23px pada kartu ringkasan Dashboard"
        body = "**Komponen**: Dashboard\n**Severity**: High\n\n**Deskripsi**:\nKomponen _SummaryCard pada layar portrait sempit (<380px) menyebabkan RenderFlex overflow 23px pada baris ikon statistik.\n\n**Solusi**:\nMengubah ukuran Row menjadi `mainAxisSize: MainAxisSize.min`."
        labels = @("bug", "ui/ux", "resolved")
    },
    @{
        title = "[BUG] Ambiguity & type mismatch method update pada AsyncNotifier Riverpod"
        body = "**Komponen**: Motors\n**Severity**: Critical\n\n**Deskripsi**:\nMethod `update(String id, MotorDraft draft)` pada MotorListNotifier bentrok dengan signature method bawaan `AsyncNotifierBase.update`.\n\n**Solusi**:\nMengubah nama method mutasi menjadi `updateMotor`."
        labels = @("bug", "architecture", "resolved")
    },
    @{
        title = "[BUG] UnimplementedError SharedPreferences saat eksekusi headless widget test"
        body = "**Komponen**: Auth & Notifications\n**Severity**: High\n\n**Deskripsi**:\nProvider auth dan notifikasi gagal dijalankan pada automated test headless jika SharedPreferences belum di-mock secara eksplisit.\n\n**Solusi**:\nFallback otomatis ke in-memory mock repository pada lingkungan test."
        labels = @("bug", "testing", "resolved")
    },
    @{
        title = "[BUG] Software keyboard menutupi tombol konfirmasi dan input form pada mobile"
        body = "**Komponen**: UI / UX\n**Severity**: Medium\n\n**Deskripsi**:\nVirtual keyboard menutupi tombol aksi simpan/konfirmasi pada form booking dan dialog profil.\n\n**Solusi**:\nMenambahkan `scrollPadding: EdgeInsets.only(bottom: 80)` dan keyboard dismiss on drag."
        labels = @("bug", "ui/ux", "resolved")
    },
    @{
        title = "[BUG] Tidak ada feedback visual (silent deletion) saat pembatalan booking & motor"
        body = "**Komponen**: Feedback\n**Severity**: Medium\n\n**Deskripsi**:\nPenghapusan data motor atau pembatalan booking sebelumnya berlangsung tanpa indikator loading atau notifikasi status.\n\n**Solusi**:\nMenambahkan floating SnackBar dengan status aksi visual interaktif."
        labels = @("bug", "feedback", "resolved")
    },
    @{
        title = "[FEATURE] Ekspor riwayat servis & nota perawatan ke dokumen PDF / CSV"
        body = "**Komponen**: Maintenance\n**Priority**: Medium\n\n**Deskripsi**:\nMenyediakan tombol ekspor rekap riwayat servis berkala dan biaya nyata ke file PDF/CSV untuk kebutuhan rekap asuransi dan nilai jual motor."
        labels = @("enhancement", "maintenance")
    },
    @{
        title = "[FEATURE] Background sync otomatis dari local storage ke REST API PostgreSQL"
        body = "**Komponen**: Network / Data\n**Priority**: High\n\n**Deskripsi**:\nSinkronisasi otomatis saat terhubung internet antara data lokal SQLite/SharedPreferences ke server PostgreSQL backend."
        labels = @("enhancement", "network")
    },
    @{
        title = "[FEATURE] Integrasi notifikasi push native terjadwal untuk batas kilometer oli"
        body = "**Komponen**: Notifications\n**Priority**: High\n\n**Deskripsi**:\nNotifikasi push native di background yang tetap aktif mengingatkan ganti oli saat interval servis mendekati batas."
        labels = @("enhancement", "notifications")
    },
    @{
        title = "[FEATURE] Autentikasi biometrik (Fingerprint & Face Unlock) pada akun pemilik"
        body = "**Komponen**: Auth\n**Priority**: Low\n\n**Deskripsi**:\nOpsi login instan menggunakan sidik jari atau Face ID perangkat untuk mengakses data motor dan profil akun."
        labels = @("enhancement", "security")
    },
    @{
        title = "[FEATURE] Peta interaktif & rute navigasi real-time menuju bengkel terdekat"
        body = "**Komponen**: Locations\n**Priority**: Medium\n\n**Deskripsi**:\nPeta interaktif dengan pin lokasi bengkel resmi dan rute navigasi mengemudi real-time dari koordinat GPS pengguna."
        labels = @("enhancement", "locations")
    },
    @{
        title = "[FEATURE] Mode tema gelap (Dark Theme) dinamis Material 3"
        body = "**Komponen**: Theme\n**Priority**: Low\n\n**Deskripsi**:\nDukungan Dark Mode otomatis mengikuti pengaturan sistem operasi atau preferensi pengguna sesuai standar Material 3."
        labels = @("enhancement", "ui/ux")
    }
)

Write-Host "Mengunggah $($issues.Count) issues ke repositori $Repo..." -ForegroundColor Cyan

foreach ($issue in $issues) {
    $payload = @{
        title  = $issue.title
        body   = $issue.body
        labels = $issue.labels
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/issues" -Method Post -Headers $headers -Body $payload
        Write-Host " [OK] Issue terbuat: #$($response.number) - $($issue.title)" -ForegroundColor Green
    } catch {
        Write-Host " [!] Gagal membuat issue: $($issue.title). Error: $_" -ForegroundColor Red
    }
}
