# SyncBudget Mobile

> Aplikasi mobile *e-budgeting* berbasis Flutter untuk sistem manajemen pengajuan dan persetujuan anggaran perusahaan secara real-time.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Laravel API](https://img.shields.io/badge/Backend-Laravel-FF2D20?logo=laravel)](https://laravel.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Tentang Proyek

**SyncBudget Mobile** adalah aplikasi mobile companion untuk sistem *e-budgeting* berbasis web. Aplikasi ini memungkinkan staf dan manajer untuk mengelola pengajuan dan persetujuan anggaran secara efisien langsung dari perangkat mobile mereka, terhubung ke backend **Laravel** melalui REST API.

### Fitur Utama

| Fitur | Staff | Manager |
|-------|:-----:|:-------:|
| Dasbor ringkasan anggaran real-time | Ya | Ya |
| Pengajuan dana baru | Ya | - |
| Riwayat pengajuan personal | Ya | - |
| Persetujuan & penolakan pengajuan | - | Ya |
| Monitoring anggaran per divisi | - | Ya |
| Manajemen profil & keamanan akun | Ya | Ya |
| Log aktivitas | - | Ya |
| Pull-to-refresh data real-time | Ya | Ya |

---

## Arsitektur Proyek

```
lib/
├── main.dart
├── screens/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── staff/
│   │   ├── staff_main_screen.dart
│   │   ├── riwayat_pengajuan_screen.dart
│   │   └── tabs/
│   │       ├── home_tab.dart
│   │       ├── pengajuan_tab.dart
│   │       └── profile_tab.dart
│   └── manager/
│       ├── manager_main_screen.dart
│       └── tabs/
│           ├── home_tab.dart
│           ├── budget_tab.dart
│           ├── pengajuan_tab.dart
│           ├── log_tab.dart
│           └── profile_tab.dart
├── services/
│   ├── api_config.dart        # Base URL & konfigurasi
│   ├── auth_service.dart      # Login, Logout, isLoggedIn
│   ├── dashboard_service.dart # getDashboardData
│   └── profile_service.dart   # updateProfile
├── theme/
│   ├── colors.dart
│   └── text_styles.dart
└── utils/
    └── snackbar_utils.dart
```

---

## Cara Menjalankan

### Prasyarat
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Backend Laravel berjalan di `http://localhost:8000`

### Langkah Instalasi

```bash
# 1. Clone repository
git clone https://github.com/jevonkagenou/syncbudget-mobile.git
cd syncbudget-mobile

# 2. Install dependencies
flutter pub get

# 3. Jalankan aplikasi (pastikan emulator/perangkat terhubung)
flutter run
```

### Konfigurasi API

Sesuaikan `baseUrl` di `lib/services/api_config.dart` berdasarkan lingkungan Anda:

```dart
// Android Emulator
static const String baseUrl = 'http://10.0.2.2:8000/api';

// iOS Simulator
static const String baseUrl = 'http://127.0.0.1:8000/api';

// Perangkat Fisik (ganti dengan IP komputer Anda)
static const String baseUrl = 'http://192.168.1.x:8000/api';
```

---

## Dependencies Utama

| Package | Kegunaan |
|---------|----------|
| `http` | HTTP client untuk komunikasi REST API |
| `shared_preferences` | Penyimpanan token autentikasi lokal |
| `google_nav_bar` | Navigasi bawah bergaya modern dengan animasi |
| `lucide_icons` | Library ikon konsisten lintas platform |
| `intl` | Pemformatan mata uang Rupiah (`Rp`) |

---

## Log Perubahan (Changelog)

### [24 April 2026] - API Integration, Refactoring & UI Consistency

**By:** @jevonkagenou

- **Full Dashboard API Integration (Staff & Manager):** Menghubungkan dasbor Staff dan Manager secara penuh ke endpoint `/api/dashboard` Laravel. Data profil, statistik anggaran, dan riwayat pengajuan kini bersumber dari API secara *real-time*, menggantikan seluruh data statis (*dummy data*).
- **Pull-to-Refresh:** Menambahkan `RefreshIndicator` pada dasbor Staff dan Manager, memungkinkan pengguna memperbarui data terkini cukup dengan menarik layar ke bawah tanpa perlu *logout*.
- **Manager Dashboard Overhaul:** Merombak UI dasbor Manager dari satu kartu besar statis menjadi tiga *Stat Card* horizontal yang dapat digeser, menampilkan: jumlah pengajuan *pending*, realisasi divisi bulan ini, dan sisa anggaran divisi — selaras dengan tampilan web.
- **Navigation Bar Consistency (GNav):** Mengganti `BottomNavigationBar` konvensional di halaman Manager dengan `GNav` (*Google Nav Bar*) bergaya kapsul beranimasi, menyamakan tampilan dengan navigasi milik Staff. Ikon dan label tab pertama diseragamkan menjadi `Beranda` untuk konsistensi lintas peran.
- **Forgot Password UX:** Mengimplementasikan *Bottom Sheet* modern sebagai pengganti alur *forgot password* yang sebelumnya kosong, memberikan instruksi prosedural kepada pengguna untuk menghubungi admin.
- **Structural Refactoring (Folder & Naming):** Merestrukturisasi folder Manager dari pola `manager_*_screen.dart` menjadi `tabs/*_tab.dart` — identik dengan struktur Staff — untuk menghilangkan inkonsistensi yang terjadi akibat *push* dari kontributor berbeda.
- **API Service Decomposition:** Memecah `api_service.dart` monolitik menjadi empat modul layanan terpisah: `api_config.dart`, `auth_service.dart`, `dashboard_service.dart`, dan `profile_service.dart` — meningkatkan keterbacaan, pemeliharaan, dan pemisahan tanggung jawab (*Separation of Concerns*).
- **Profile Update Fix:** Memperbaiki bug di sisi backend Laravel (`ProfileController.php`) di mana field `email` tidak tersimpan ke database karena tidak ter-*assign* ke model `User` sebelum pemanggilan `save()`.

---

### [21 April 2026] - Manager Core Features: Budgeting, Approval, and Profiling

**By:** @Fii2X05

- **Manager Budget Monitoring (Anggaran):** Mengembangkan layar `ManagerBudgetScreen` yang menyajikan gambaran finansial komprehensif. Menampilkan total anggaran perusahaan secara global serta distribusi alokasi anggaran yang telah disetujui per divisi lengkap dengan persentase penggunaannya melalui *progress bar*.
- **Fund Approval & Auditing Gateway (Persetujuan Dana):** Membangun `ManagerReimbursementScreen` untuk memfasilitasi peran pengawasan manajer. Manajer kini dapat melihat daftar pengajuan dana dari staf, serta memberikan keputusan langsung berupa persetujuan (*Setujui*), penolakan (*Tolak*), maupun melakukan eskalasi untuk audit lanjutan (*Mulai Audit*).
- **Manager Profile Standardization:** Menyempurnakan `ManagerProfileScreen` agar selaras dengan arsitektur profil staf. Dilengkapi dengan identitas peran manajerial, pengaturan keamanan berlapis (form ganti *password*), dan fitur penghentian sesi (*logout*) yang terstruktur.

---

### [19 April 2026] - Enhancing UX, Dynamic APIs, and Manager Role Architecture

**By:** @jevonkagenou

- **UX Modernization (GNav & Form Redesign):** Mengganti *BottomNavigationBar* konvensional ke *Google Navigation Bar* (GNav) dengan animasi kapsul yang *fluid*. Merestrukturisasi antarmuka form pengajuan (dan form lainnya) ke standar *Enterprise SaaS* dengan zona unggah dokumen bersilangan (*upload surface*), seleksi garis batas berwarna tematik, serta ruang spasi interaktif.
- **Dynamic Variable Mapping (API Readiness):** Menghilangkan entitas ikon dan warna bawaan dari *hardcoded JSON* statis menjadi sistem fungsi yang dikomputasi interaktif secara *real-time* (`getIconForStatus`, `getColorForStatus`) agar transisi data saat implementasi *Backend API* kelak tidak perlu melakukan intervensi visual.
- **Riwayat Pengajuan & Feature Routing:** Menjadikan UI tombol sebagai pengarah arah (*route binding*), serta menciptakan layar baru independen `RiwayatPengajuanScreen` yang dipersenjatai filter *Dropdown* (*State Management*) dan pencarian data *Search Bar* yang hidup.
- **Flutter Framework Mitigation:** Membasmi fungsi visual diusangkan / *deprecated* Flutter (`withOpacity`) dengan standarisasi `withValues` pada matriks warna komponen-komponen utama secara menyeluruh untuk memastikan kepatuhan atas spesifikasi Flutter *engine* tingkat akhir.
- **Manager Architectural Entry:** Mewujudkan pintu depan khusus area Manajer dengan layar singgah yang dilengkapi pengawasan sesi (*logout confirmation dialog*) sebagai landasan fitur persetujuan dan persilangan *routing*.

---

### [19 April 2026] - Initial Mobile Front-End & Staff Dashboard Architecture

**By:** @jevonkagenou

- **Flutter Foundation Initialization:** Pembuatan struktur *project base* menggunakan framework Flutter untuk entitas *SyncBudget Mobile*.
- **Slate Corporate Theme Implementation:** Integrasi palet warna khusus \"Slate\" (Primary `#696CFF`, Secondary `#6F71B1`, dst) beserta tipografi dinamis (*Manrope* untuk *Headline*, *Inter* untuk *Body*) demi menciptakan bahasa desain level *Enterprise SaaS*.
- **Role-Based Auth Mockup:** Pembuatan sistem *logic gateway* (dummy) pada form *Login* untuk memisahkan pintu masuk antara pengguna dengan peran \"Staff\" dan \"Manager\".
- **Staff Dashboard - Core Framework:** Implementasi fondasi navigasi utama (*Bottom Navigation Bar*) yang efisien.
- **Home Tab Design Integration:** Merakit desain ringkasan dana (\"Total Dana Disetujui\"), visualisasi bar \"Ketersediaan Anggaran Divisi\", serta riwayat pengajuan awal.
- **Fund Submission Gateway (Pengajuan Tab):** Menyusun antarmuka \"Daftar Pengajuan Dana\" dengan metrik berbasis *pill* dan riwayat komprehensif mengacu pada sistem ikon status persetujuan.
- **Secure Profile Form (Profile Tab):** Membangun form data ganda; blok identitas fungsional (*read-only* untuk info statis) dan kapsul Keamanan Akun bertema khusus untuk memperbarui kata sandi, dilengkapi *Routing Logout* terenkapsulasi secara UI.

---

## Kontributor

| Kontributor | Peran |
|-------------|-------|
| [@jevonkagenou](https://github.com/jevonkagenou) | Lead Developer — Architecture, API Integration, UI/UX |
| [@Fii2X05](https://github.com/Fii2X05) | Contributor — Manager Core Features |

---

*SyncBudget Mobile — Dibangun menggunakan Flutter dan Laravel.*
