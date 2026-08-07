# 💧 Water Reminder App

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Material Design 3](https://img.shields.io/badge/Material_3-%23000000.svg?style=for-the-badge)](https://m3.material.io/)

Aplikasi mobile pengingat minum air harian yang dirancang dengan **Material Design 3** untuk membantu Anda menjaga hidrasi tubuh dengan mudah dan elegan.

---

## 📱 Tentang Aplikasi

**Water Reminder App** adalah aplikasi *cross-platform* (Android & iOS) yang membantu Anda mencapai target konsumsi air harian. Aplikasi ini tidak hanya mencatat asupan air Anda, tetapi juga memberikan pengingat cerdas agar Anda tidak lupa minum sepanjang hari. 

Dibangun dengan standar modern (Clean Architecture) dan antarmuka yang bersih (Dynamic Color), aplikasi ini memastikan pengalaman penggunaan yang cepat, ringan, dan nyaman.

---

## ✨ Fitur Utama

- **🎯 Target Harian:** Pantau target minum air Anda (default 2000ml).
- **📊 Visualisasi Progress:** Pantau hidrasi Anda melalui indikator *Progress Ring* yang interaktif.
- **⚡ Pencatatan Cepat (Presets):** Tambahkan asupan air dengan satu ketukan (misal: Gelas 200ml, Botol 500ml).
- **✏️ Input Kustom:** Catat jumlah air spesifik sesuai keinginan Anda.
- **🔔 Pengingat Cerdas:** Notifikasi latar belakang yang dapat diandalkan untuk mengingatkan Anda minum.
- **🔄 Reset Otomatis:** Data asupan air akan direset secara otomatis setiap tengah malam.
- **🎨 Material You:** Antarmuka adaptif yang menyesuaikan dengan tema perangkat Anda (*Dynamic Color*).
- **📴 Offline Support:** Data tersimpan aman secara lokal di perangkat, berfungsi 100% tanpa internet.

---

## 📥 Cara Download & Install Aplikasi

Anda dapat menginstal aplikasi ini secara langsung dengan melakukan *build* dari *source code* di repositori ini.

### Prasyarat
Pastikan PC/Laptop Anda sudah terinstal:
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio (untuk Android) atau Xcode (untuk iOS)

### Langkah-langkah Instalasi
1. Buka terminal/Command Prompt dan *clone* repositori ini:
   ```bash
   git clone https://github.com/zaq-ly/Water-Reminder-App.git
   ```
2. Masuk ke folder proyek:
   ```bash
   cd Water-Reminder-App
   ```
3. Unduh semua *dependencies*:
   ```bash
   flutter pub get
   ```
4. Hubungkan HP Anda menggunakan kabel USB (pastikan *USB Debugging* / *Developer Mode* sudah aktif).
5. Jalankan perintah berikut untuk menginstal aplikasi ke HP Anda:
   ```bash
   flutter run
   ```

---

## 🛠️ Teknologi yang Digunakan

- **Framework:** Flutter (Dart)
- **State Management:** BLoC / Cubit
- **Architecture:** Clean Architecture
- **Dependency Injection:** GetIt + Injectable
- **Local Storage:** Hive
- **Background Tasks:** Workmanager & Android Alarm Manager Plus
- **Navigation:** GoRouter

---

<p align="center">
  Dibuat untuk mendukung gaya hidup yang lebih sehat 💧
</p>
