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
| Pengajuan dana baru (+ struk wajib) | Ya | - |
| Riwayat pengajuan personal | Ya | - |
| Filter status pengajuan | Ya | Ya |
| Persetujuan & penolakan pengajuan | - | Ya |
| Manajemen Pagu Anggaran (CRUD) | - | Ya |
| Search & pagination pagu anggaran | - | Ya |
| Log aktivitas + search + filter tanggal | - | Ya |
| Arsip Laporan Tahunan + download | - | Ya |
| Export PDF pengajuan disetujui | - | Ya |
| Manajemen profil & keamanan akun | Ya | Ya |
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
│   │       ├── pengajuan_tab.dart       ← Upload struk wajib
│   │       └── profile_tab.dart
│   └── manager/
│       ├── manager_main_screen.dart
│       └── tabs/
│           ├── home_tab.dart            ← Dashboard + Export PDF
│           ├── budget_tab.dart          ← CRUD + search debounce
│           ├── pengajuan_tab.dart       ← Approve/Reject
│           ├── log_tab.dart             ← Real-time search + date filter
│           ├── arsip_tab.dart           ← Laporan tahunan + download
│           └── profile_tab.dart
├── services/
│   ├── api_config.dart
│   ├── auth_service.dart
│   ├── dashboard_service.dart
│   ├── profile_service.dart
│   ├── reimbursement_service.dart
│   ├── budget_service.dart
│   ├── activity_log_service.dart
│   └── annual_report_service.dart
├── theme/
│   ├── colors.dart
│   └── text_styles.dart
└── utils/
    ├── snackbar_utils.dart
    └── file_download_utils.dart         ← PDF save ke public Downloads
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
| `path_provider` | Akses direktori penyimpanan perangkat untuk PDF |
| `google_nav_bar` | Navigasi bawah bergaya modern dengan animasi |
| `lucide_icons` | Library ikon konsisten lintas platform |
| `intl` | Pemformatan mata uang Rupiah (`Rp`) |
| `image_picker` | Akses galeri untuk unggah struk/nota (wajib) |

---

## Log Perubahan (Changelog)

---

### [5 Mei 2026] — PDF Download, Validation Hardening & Bug Fixes

**By:** @jevonkagenou

#### Export PDF — Manager
- **PDF Berhasil Tersimpan:** Memperbaiki masalah mendasar di mana file PDF tidak dapat ditemukan di file manager perangkat. Root cause: `Android/data/` diblokir oleh Android 11+ untuk akses pihak ketiga. Solusi: menyimpan langsung ke `/storage/emulated/0/Download/` (folder Downloads publik) yang dapat dilihat langsung di Files app.
- **Rewrite `FileDownloadUtils`:** Implementasi strategi penyimpanan berlapis — public Downloads → external storage → app documents → cache (fallback terakhir). Snackbar kini menampilkan path file aktual bukan teks hardcoded.
- **Hapus `open_file` Plugin:** Plugin ini memerlukan Developer Mode Windows untuk symlinks. Diganti dengan pendekatan direct file write yang lebih andal dan tidak bergantung native plugin tambahan.
- **AndroidManifest:** Menambahkan `MANAGE_EXTERNAL_STORAGE` permission dan `android:requestLegacyExternalStorage="true"` agar akses ke public Downloads folder berfungsi di Android 11+.

#### Arsip Laporan Tahunan — Manager (Baru)
- **`arsip_tab.dart`:** Menambahkan tab baru Arsip Laporan Tahunan yang menampilkan daftar laporan dengan pagination, search bar, dan tombol download per laporan. File laporan diunduh langsung ke folder Downloads.

#### Pagu Anggaran — Search Bug Fix
- **Race Condition Debounce:** Memperbaiki bug di mana search bar memberikan hasil tidak konsisten saat mengetik cepat atau menekan clear. Penyebab: debounce menggunakan `_searchCtrl.text` yang sudah berubah saat timer fire. Solusi: `capturedValue` pattern.
- **`_loadBudgets(search:)`:** Fungsi load sekarang menerima parameter `search` eksplisit.

#### Log Aktivitas — Search Real-time
- **`onChanged` + Debounce:** Mengganti `onSubmitted` dengan `onChanged` + debounce 400ms untuk pengalaman search real-time yang responsif.
- **Clear Button Reaktif:** Tombol clear (×) dikendalikan variabel `_searchText` terpisah.

#### Validasi API Backend (ebudgeting-core)
- **`BudgetController::store()`:** Mengganti `$request->validate()` dengan `Validator::make()` — selalu mengembalikan JSON 422.
- **`BudgetController::update()`:** Validasi dipindah ke **sebelum** pengecekan duplikasi. `fiscal_year_id` ditambahkan ke rules update.
- **`ReimbursementController::store()`:** Konversi ke `Validator::make()` untuk konsistensi response JSON.
- **`ProfileController::update()`:** Memperbaiki `$user->role` (tidak ada di Eloquent) menjadi `$user->roles->first()->name ?? 'staff'`.

#### Struk/Nota — Sekarang Wajib
- Backend: Field `receipt` diubah dari `nullable` menjadi `required`.
- Mobile: Validasi client-side ditambahkan. Label upload: **"Bukti Struk / Nota (Wajib)"**.

---

### [28 April 2026] — Manager Approval, Budget CRUD & Activity Log Full Integration

**By:** @jevonkagenou

#### Pengajuan Dana — Manager
- **Live API Persetujuan (`pengajuan_tab.dart`):** Merombak total halaman pengajuan Manager dari data statis ke *live API* via endpoint baru `GET /api/reimbursements/manager`. Endpoint ini mengembalikan **semua status** (pending, approved, rejected) yang terbatas pada divisi yang dikelola manager, menggantikan endpoint `/pending` yang sebelumnya hanya mengambil status *pending*.
- **Filter Status Chip:** Filter chip (Semua / MENUNGGU / DISETUJUI / DITOLAK) kini berfungsi penuh secara *client-side*. Kunci filter diselaraskan dengan nilai API mentah (`pending`, `approved`, `rejected`) menggunakan *label map* agar tetap tampil dalam Bahasa Indonesia.
- **Backend Fix (`ReimbursementController`):** Menambahkan method `managerList()` baru yang menggunakan `whereHas('user', ...)` + relasi pivot `managedDivisions` untuk memfilter pengajuan secara aman per divisi manager, dengan dukungan *query param* `?status=` opsional.

#### Pagu Anggaran — Manager
- **Live API + CRUD Lengkap (`budget_tab.dart`):** Merombak total `BudgetTab` dari data statis ke *live API*. Mencakup: tampilan daftar dengan *search bar*, *pagination*, dan *progress bar* warna-adaptif (hijau → kuning → merah berdasarkan persentase pemakaian).
- **Form Buat/Edit Anggaran:** Mengimplementasikan *bottom sheet modal* yang identik dengan form web, mencakup field: Nama Anggaran, Tahun Anggaran (dropdown), Kategori (dropdown), Divisi (dropdown), Total Pagu (angka saja), Tanggal Mulai & Berakhir (*date picker*). Validasi *inline error banner* ditampilkan langsung di dalam modal.
- **Badge Kadaluarsa:** Menambahkan badge **"Kadaluarsa"** pada kartu anggaran yang `end_date`-nya sudah lewat dari tanggal hari ini. Periode tanggal juga diberi *strikethrough* sebagai penanda visual — selaras dengan tampilan web.
- **Backend Fix (`BudgetController`):**
  - Menambahkan endpoint `GET /budgets/form-metadata` yang mengembalikan data dropdown (`fiscal_years`, `divisions`, `budget_categories`) dalam satu request.
  - Memperbaiki validasi duplikasi `fiscal_year_id`: dari `Rule::unique` (pesan error generik) menjadi pengecekan manual dengan pesan informatif: *"Anggaran dengan kombinasi Tahun Anggaran, Kategori, dan Divisi yang sama sudah ada."*

#### Log Aktivitas — Manager
- **Filter & Search (`log_tab.dart`):** Menambahkan *search bar* (cari aktivitas/pelaku) dan *date range picker* (Tanggal Mulai & Akhir) yang terhubung ke query param backend (`?search=`, `?start_date=`, `?end_date=`). Tombol *Reset Filter* muncul otomatis saat filter aktif.
- **Modul Target Badge:** Badge modul kini berwarna dinamis per tipe entitas: Budget (hijau), User (biru), Reimbursement (kuning), Divisi (info), dsb — menggantikan badge teks abu polos sebelumnya.
- **Modal Detail Perubahan (mobile-first):** Mengganti tampilan JSON *side-by-side* (yang tidak cocok di layar sempit) dengan desain *DraggableScrollableSheet* bertab:
  - **Tab "Sebelum"** — menampilkan data lama dengan highlight merah pada field yang berubah
  - **Tab "Sesudah"** — menampilkan data baru dengan highlight hijau pada field yang berubah
  - Field yang berubah diurutkan ke **paling atas** secara otomatis
  - Nama field diterjemahkan ke Bahasa Indonesia (`fiscal_year_id` → "ID Tahun Anggaran", dst) via *label map*
  - Badge jumlah field yang berubah ditampilkan di header modal
  - *Empty state* kontekstual jika data dibuat baru (tidak ada "sebelum") atau dihapus (tidak ada "sesudah")

---

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
- **Slate Corporate Theme Implementation:** Integrasi palet warna khusus "Slate" (Primary `#696CFF`, Secondary `#6F71B1`, dst) beserta tipografi dinamis (*Manrope* untuk *Headline*, *Inter* untuk *Body*) demi menciptakan bahasa desain level *Enterprise SaaS*.
- **Role-Based Auth Mockup:** Pembuatan sistem *logic gateway* (dummy) pada form *Login* untuk memisahkan pintu masuk antara pengguna dengan peran "Staff" dan "Manager".
- **Staff Dashboard - Core Framework:** Implementasi fondasi navigasi utama (*Bottom Navigation Bar*) yang efisien.
- **Home Tab Design Integration:** Merakit desain ringkasan dana ("Total Dana Disetujui"), visualisasi bar "Ketersediaan Anggaran Divisi", serta riwayat pengajuan awal.
- **Fund Submission Gateway (Pengajuan Tab):** Menyusun antarmuka "Daftar Pengajuan Dana" dengan metrik berbasis *pill* dan riwayat komprehensif mengacu pada sistem ikon status persetujuan.
- **Secure Profile Form (Profile Tab):** Membangun form data ganda; blok identitas fungsional (*read-only* untuk info statis) dan kapsul Keamanan Akun bertema khusus untuk memperbarui kata sandi, dilengkapi *Routing Logout* terenkapsulasi secara UI.

---

### [19 Mei 2026] - Dashboard Optimization, Service Grid Redesign, and UI Alignment

**By:** @CitraAyu0

- **Staff Dashboard Layout Refactoring:** Melakukan tata ulang struktural pada layout dashboard *Staff* untuk komponen kartu informasi anggaran dan ringkasan *overview* agar visualisasi data menjadi lebih seimbang.
- **Manager Budget Card Refactoring:** Mengubah tata letak (*layouting*) pada kartu informasi anggaran di dashboard peran *Manager* guna mengoptimalkan hierarki informasi keuangan divisi.
- **Service Menu Grid Redesign :** Merombak total menu *Layanan* pada beranda Manager dari komponen baris konvensional menjadi struktur *4-column grid layout* yang ringkas, hemat ruang, dan presisi tinggi sesuai target desain antarmuka.
- **Filter Typography Realignment:** Memperbaiki (*bugfix*) penyimpangan visual pada halaman *Pengajuan* dengan meratakan teks tombol filter tepat ke posisi tengah (*center alignment*) demi konsistensi komponen UI.

---

## [19 Mei 2026] - UI Cleanup, Search Feature Enhancement, and Manager Page Simplification

By: @iakmorales

- **Global Header Simplification:** Menghapus icon notifikasi (bell icon) pada seluruh halaman aplikasi untuk menyederhanakan tampilan antarmuka serta menghilangkan elemen yang belum memiliki implementasi fungsional.

- **Manager Approval Page Cleanup:** Menghapus icon action (edit/document icon) pada halaman Persetujuan Dana role Manager guna mengurangi distraksi visual dan menjaga konsistensi tindakan utama pada halaman approval.

- **Budget Search Feature Enhancement:** Memperbaiki serta mengintegrasikan ulang mekanisme pencarian (search functionality) pada halaman Pagu Anggaran agar mampu melakukan filtering data secara optimal pada data ber-pagination.

- **Activity Log Search Improvement:** Melakukan perbaikan fitur pencarian pada halaman Log Aktivitas dengan mengimplementasikan client-side search filtering untuk memastikan proses pencarian data tetap responsif meskipun menggunakan pagination.

---

## Kontributor

| Kontributor | Peran |
|-------------|-------|
| [@jevonkagenou](https://github.com/jevonkagenou) | Lead Developer — Architecture, API Integration, UI/UX |
| [@Fii2X05](https://github.com/Fii2X05) | Contributor — Manager Core Features |

---

*SyncBudget Mobile — Dibangun menggunakan Flutter dan Laravel.*
