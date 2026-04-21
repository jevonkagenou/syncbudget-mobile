# SyncBudget Mobile

# Log Perubahan (Changelog)

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
