# PRD — Water Reminder App

## 1. Buat siapa?
Orang yang jarang minum air putih — lupa atau gak sadar sampai udah dehidrasi.

## 2. Problem apa?
Target user gak punya sistem pengingat buat minum air secara rutin, sehingga jatah minum harian (2 liter) sering gak terpenuhi tanpa mereka sadari.

## 3. Fitur Utama

- [ ] **Notifikasi pengingat minum** — muncul berulang tiap interval tertentu (default 30 menit) SELAMA jatah harian belum terpenuhi
- [ ] Interval notifikasi bisa di-setting oleh user (gak harus fix 30 menit)
- [ ] Notifikasi ini **prioritas tinggi** — harus tetap muncul meskipun app di background/HP silent mode (perlu riset teknis: notification channel importance HIGH di Android, atau equivalent di iOS)
- [ ] User bisa tandai "sudah minum" dari notifikasi langsung (tanpa buka app) — ini nentuin progress harian
- [ ] **Setting jatah harian** — user atur target total (default 2 liter / 2000ml), bisa diubah sesuai kebutuhan. Saat onboarding, user ditawari opsi personalisasi berdasarkan berat badan (rumus: BB kg × 30ml) atau pakai default 2L.
- [ ] Setting interval & prioritas notifikasi (bagian dari poin di atas, taruh di 1 screen setting)
- [ ] **Jam aktif notifikasi** — notifikasi hanya dikirim dalam rentang waktu tertentu (default **07:00 – 22:00** waktu lokal device). Di luar jam aktif, notifikasi **TIDAK dijadwalkan** meskipun target belum tercapai. User bisa ubah jam mulai & selesai di settings.
- [ ] **Snooze / Jeda** — user bisa pause notifikasi sementara:
  - **Snooze 1 jam** dari notifikasi langsung (tanpa buka app)
  - **Mode Jeda** di dalam app — stop semua notifikasi sampai di-resume manual
  - Tanpa fitur ini, user akan matikan notifikasi app secara permanen saat situasi tidak bisa diganggu (meeting, ibadah, tidur siang)

## 4. Bukan Fiturnya (Scope OUT)

- [ ] Tracking jenis minuman (kopi, teh, dll) — hanya air putih, cukup input jumlah
- [ ] Grafik/statistik historis minum (mingguan/bulanan) — v1 cukup progress harian aja
- [ ] Reminder makan atau fitur kesehatan lain di luar minum air
- [ ] Integrasi dengan smartwatch/wearable
- [ ] Social feature (share progress, leaderboard, dll)
- [ ] Multi-user/akun — single user per device dulu
- [ ] Custom sound/tone notifikasi — pakai default dulu

## 5. Sukses Gimana?

User bisa menyelesaikan seluruh alur inti hanya dengan **3 tap/task**:
1. Set jatah harian (sekali di awal, atau default langsung jalan)
2. Terima notifikasi → tap "Sudah minum"
3. Lihat progress (misal: 600ml/2000ml) tanpa perlu buka menu lain

Kalau user butuh lebih dari 3 langkah buat hal paling dasar (minum & catat), berarti gagal dari sisi UX.

**Metrik Sukses (terukur):**
- **% hari target tercapai** — dihitung dari data lokal: (jumlah hari target terpenuhi / total hari aktif pakai app) × 100%. Bisa ditampilkan di app sebagai motivasi user.
- **Retention D7** — apakah user masih aktif menggunakan app setelah 7 hari pertama? Definisi "aktif" = minimal 1× tap "Sudah minum" dalam sehari. Untuk v1 cukup didefinisikan dulu sebagai acuan, implementasi tracking-nya bisa pakai data lokal (hitung dari log harian yang tersimpan).

---

## Catatan Teknis Tambahan (biar agent gak nebak pas eksekusi)

**Data yang perlu disimpan (lokal, minimal v1):**
- Target harian (ml)
- Total terminum hari ini (ml)
- Interval notifikasi (menit)
- Jam aktif notifikasi — jam mulai & jam selesai
- Status snooze/jeda (aktif atau tidak, sampai kapan)
- Berat badan user (opsional, untuk kalkulasi target)
- Log harian per tanggal (untuk hitung % hari target tercapai & retention)
- Waktu reset counter (default: tengah malam / jam custom)

**Edge case — sudah diputuskan:**
- [x] Kalau target harian sudah tercapai → notifikasi **berhenti** total untuk hari itu (gak perlu nunggu jam tidur)
- [x] Counter progress **reset otomatis jam 00:00 (tengah malam)**, jalan lewat scheduler di background — TIDAK bergantung pada user buka app. Ini penting secara teknis: berarti butuh mekanisme reset yang jalan sendiri (background task/local scheduled job), bukan cuma "cek pas app dibuka"
- [x] Jumlah ml per "sudah minum" → **input manual + template pilihan cepat** (misal tombol preset: 100ml / 200ml / 300ml / custom). User gak harus ketik angka tiap kali, tapi tetap bisa kalau mau spesifik
- [x] Platform target: **Android & iOS** (cross-platform Flutter + Dart)
- [x] Reset jam 00:00 pakai **waktu lokal device**, bukan UTC/server time — biar gak nebak pas user pindah timezone
- [x] **Tap "Sudah minum" dari notifikasi** (tanpa buka app) → mencatat **200ml** sebagai default (1 gelas standar). Kalau user mau jumlah beda, buka app dan pakai preset/custom input. Trade-off: simplicity (1 tap dari notif) vs akurasi (harus buka app).
- [x] **Onboarding / First Launch** → user langsung masuk home screen dengan default (2000ml target, 30 menit interval). Muncul dialog minta **izin notifikasi** (wajib di iOS, direkomendasikan di Android 13+). Setelah itu, opsional: bottom sheet "Mau personalisasi target?" dengan opsi input berat badan (target = BB kg × 30ml) atau "Pakai default 2L". Gak perlu wizard bertele-tele — harus bisa di-skip.
- [x] **Kalau user deny notification permission** → tampilkan banner persisten di home screen yang menjelaskan bahwa app butuh izin notifikasi untuk berfungsi sebagai reminder, dengan tombol "Buka Settings" (deep link ke settings OS). App tetap bisa dipakai untuk log manual, tapi reminder gak jalan. JANGAN silent fail.
- [x] **Jam aktif notifikasi default**: 07:00 – 22:00 waktu lokal device. Di luar rentang ini, notifikasi tidak dijadwalkan meskipun target belum tercapai. User bisa ubah di settings.

**Constraint teknis (penting buat approach dari awal):**
- Target **cross-platform Flutter** — notifikasi prioritas tinggi meski app di-background/killed dicapai menggunakan **`android_alarm_manager_plus`** (Android) dan **`flutter_local_notifications`** (Android & iOS). Android punya kontrol penuh atas notification channel importance (HIGH), sehingga heads-up notification bisa reliable. Di iOS, gunakan UNNotification framework via plugin.
- Reset counter jam 00:00 juga butuh scheduled background task via **`workmanager`** (Flutter plugin), bukan sekadar cek tanggal pas app dibuka — kalau app gak pernah dibuka pas lewat tengah malam, sistem tetap harus reset di background.
- Perhatikan batasan battery optimization di Android (Doze mode, App Standby) — plugin `android_alarm_manager_plus` menggunakan `setExactAndAllowWhileIdle()` secara internal untuk notifikasi yang time-critical.

**⚠️ Notification Permission Handling (wajib di-implement):**
- Android 13+ (API 33) **wajib minta izin** `POST_NOTIFICATIONS` sebelum app bisa kirim notifikasi. Di iOS, izin notifikasi wajib diminta saat pertama kali. Gunakan **`permission_handler`** package untuk request cross-platform.
- Untuk Android 12 ke bawah, izin notifikasi otomatis granted — tapi tetap buat notification channel dengan importance HIGH.
- Kalau user deny → app tetap bisa dipakai untuk log manual, tapi fitur reminder (core feature) tidak berfungsi.
- Implementasi: tampilkan banner/card persisten di home screen dengan penjelasan + tombol "Buka Settings" yang deep link ke halaman permission app di Settings OS menggunakan **`openAppSettings()`** dari `permission_handler`.
- Jangan silent fail — user harus tahu kenapa mereka gak dapat notifikasi.

**⚠️ Temuan riset penting (wajib dibaca sebelum coding):**
- Android **tidak punya limit ketat** untuk jumlah notifikasi terjadwal seperti iOS (limit 64 pending notifications). Namun, tetap gunakan pendekatan yang efisien — schedule untuk window beberapa jam ke depan, bukan ratusan sekaligus.
- Gunakan **`android_alarm_manager_plus`** untuk alarm yang harus tepat waktu di Android — `workmanager` tidak menjamin waktu eksekusi yang presisi karena dioptimasi untuk battery. Di iOS, gunakan `flutter_local_notifications` dengan scheduled notifications.
- **Doze Mode** (Android 6.0+): Saat device idle, alarm bisa ditunda. `android_alarm_manager_plus` menggunakan `setExactAndAllowWhileIdle()` untuk override ini, tapi ada rate limit (~1 alarm per 9 menit saat Doze aktif). Ini acceptable untuk interval reminder minimum 10-15 menit.
- Beberapa OEM (Xiaomi, Samsung, Huawei) punya **battery optimization agresif** yang bisa kill background process. Pertimbangkan untuk memberikan panduan user agar exclude app dari battery optimization.

**✅ Keputusan Tech Stack:**
- **Bahasa: Dart**
- **Framework: Flutter** (cross-platform, single codebase untuk Android & iOS)
- **Arsitektur: Clean Architecture** dengan BLoC/Cubit untuk state management
- **Notifikasi:** `flutter_local_notifications` + `android_alarm_manager_plus` (Android exact alarm)
- **Background Task:** `workmanager` (Flutter plugin) untuk midnight reset dan periodic tasks
- **Storage:** `Hive` / `Isar` (local DB) + `shared_preferences` (simple key-value)
- **DI:** `get_it` + `injectable` (code generation untuk DI setup)
- **Min SDK:** Android API 26 (Android 8.0) / iOS 15.0

**✅ Approach Notifikasi (final):**
Sistem menggunakan **`android_alarm_manager_plus`** (Android) dan **`flutter_local_notifications`** (cross-platform) untuk menjadwalkan notifikasi berikutnya secara presisi. Setiap kali notifikasi selesai (user tap action atau notif muncul), sistem reschedule alarm untuk notifikasi berikutnya (chain scheduling). Saat app dibuka, semua alarm di-reschedule ulang untuk memastikan konsistensi.

**✅ Design System: Material Design 3 (Material You)**
- Pakai **Flutter Material 3** (`useMaterial3: true` di `ThemeData`) — sudah mendukung penuh spec Material You
- Gunakan `dynamic_color` package untuk dynamic color (Android 12+) dengan fallback ke `ColorScheme.fromSeed()` untuk device yang lebih lama / iOS
- Komponen kunci untuk home screen: `FilledButton` (aksi utama, misal "Jumlah lain"), `FilledButton.tonal` (aksi sekunder, misal preset 100ml/200ml)
- Layout home screen: 1 screen utama berisi progress ring (lingkaran, bukan bar) + 2 tombol preset + 1 tombol custom + ikon settings pojok kanan atas — sesuai target 3-task dari section 5
