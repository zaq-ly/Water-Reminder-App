# AGENTS.md — Water Reminder App

Read and apply: C:\Users\ACER\.gemini\config\AGENTS.md

> Rules dan guidelines untuk semua AI agents yang bekerja di project ini.

---

## 📌 Project Overview

- **Nama**: Water Reminder App
- **Platform**: Android & iOS (cross-platform)
- **Stack**: Flutter (Dart) + Material Design 3
- **Arsitektur**: Clean Architecture + BLoC/Cubit (state management)
- **DI**: get_it + injectable
- **Storage**: Hive / Isar (local DB) + shared_preferences
- **Background**: flutter_local_notifications + android_alarm_manager_plus + workmanager
- **Min SDK**: Android API 26 (Android 8.0) / iOS 15.0
- **Repository**: https://github.com/zaq-ly/Water-Reminder-App.git

---

## 🏗️ Architecture Rules

### Folder Structure
Ikuti Clean Architecture pattern dengan feature-first organization:

```
lib/
├── main.dart                        # Entry point
├── app.dart                         # MaterialApp, theme, routing
│
├── core/                            # Shared/common code
│   ├── constants/                   # App-wide constants
│   │   └── app_constants.dart       # Default values, channel IDs, keys
│   ├── theme/                       # Material 3 theming
│   │   ├── app_theme.dart           # ThemeData (light/dark + dynamic color)
│   │   ├── app_colors.dart          # Color definitions
│   │   └── app_typography.dart      # Typography definitions
│   ├── utils/                       # Helpers & extensions
│   │   └── helpers.dart             # Format ml, time helpers, kalkulasi BB
│   ├── router/                      # Navigation (go_router)
│   │   └── app_router.dart          # Route definitions
│   └── di/                          # Dependency Injection setup
│       └── injection.dart           # get_it + injectable config
│
├── data/                            # Data layer
│   ├── models/                      # Data models
│   │   ├── intake_entry.dart        # Intake log model
│   │   ├── daily_summary.dart       # Daily aggregation model
│   │   └── user_settings.dart       # Settings model
│   ├── datasources/                 # Local data sources
│   │   ├── intake_local_datasource.dart
│   │   └── settings_local_datasource.dart
│   └── repositories/                # Repository implementations
│       ├── intake_repository_impl.dart
│       └── settings_repository_impl.dart
│
├── domain/                          # Domain/business layer
│   ├── repositories/                # Repository interfaces (abstract)
│   │   ├── intake_repository.dart
│   │   └── settings_repository.dart
│   └── usecases/                    # Business logic use cases
│       ├── add_intake.dart
│       ├── get_today_intake.dart
│       ├── reset_daily.dart
│       └── schedule_notification.dart
│
├── presentation/                    # UI layer
│   ├── home/                        # Home screen feature
│   │   ├── bloc/                    # BLoC/Cubit + State
│   │   │   ├── home_cubit.dart
│   │   │   └── home_state.dart
│   │   ├── widgets/                 # Home-specific widgets
│   │   │   ├── progress_ring.dart
│   │   │   ├── preset_button.dart
│   │   │   ├── custom_input_dialog.dart
│   │   │   ├── permission_banner.dart
│   │   │   ├── pause_banner.dart
│   │   │   └── celebration_overlay.dart
│   │   └── home_screen.dart
│   ├── settings/                    # Settings screen feature
│   │   ├── bloc/
│   │   │   ├── settings_cubit.dart
│   │   │   └── settings_state.dart
│   │   └── settings_screen.dart
│   └── onboarding/                  # Onboarding flow
│       └── onboarding_sheet.dart
│
└── services/                        # Background services
    ├── notification_service.dart     # Schedule, cancel, reschedule notifications
    ├── alarm_service.dart           # Platform-specific alarm handling
    └── midnight_reset_service.dart  # Daily reset logic
```

### Pattern & Conventions
- **Clean Architecture strict** — UI (Widget) TIDAK boleh akses data layer langsung. Semua lewat BLoC/Cubit → UseCase → Repository.
- **BLoC/Cubit** untuk state management — BUKAN setState(), Provider manual, atau Riverpod.
- **Repository pattern** — Cubit akses data lewat UseCase → Repository, bukan langsung ke DataSource.
- **get_it** untuk dependency injection — jangan manual instantiate dependencies.
- **Immutable state** — gunakan `freezed` atau `Equatable` untuk semua state dan model classes.

---

## 📝 Coding Style

### Dart
- Gunakan Dart idioms: `cascade (..)`, `null-aware (?., ??)`, `collection if/for`.
- **Immutable classes** dengan `freezed` atau manual `copyWith()` untuk semua model/state.
- **Sealed class** (Dart 3) untuk UI events dan state variants.
- `async/await` untuk async — jangan pakai raw `Future.then()` chains.
- **Named parameters** untuk fungsi dengan > 2 parameter.
- Prefer `final` over `var` di mana pun.

### Flutter Widgets
- Widget names PascalCase (e.g., `ProgressRing`, `HomeScreen`).
- Gunakan `const` constructor di mana pun memungkinkan.
- Pisahkan widget besar ke file terpisah — max ~200 baris per widget.
- **Material 3** components — gunakan `useMaterial3: true` di `ThemeData`.
- Dynamic color via `dynamic_color` package sebagai default, fallback ke seed color.

### Naming
- Files: snake_case (`home_screen.dart`, `intake_repository.dart`).
- Classes: PascalCase (`HomeScreen`, `IntakeRepository`).
- Variables/functions: camelCase (`todayIntake`, `addIntake()`).
- Constants: camelCase untuk top-level, UPPER_SNAKE_CASE di dalam class (`kDefaultTarget`, `CHANNEL_ID`).
- Private: prefix underscore (`_uiState`, `_loadData()`).

---

## 📦 Dependencies (pubspec.yaml)

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.0
  equatable: ^2.0.0

  # Dependency Injection
  get_it: ^7.6.0
  injectable: ^2.3.0

  # Navigation
  go_router: ^14.0.0

  # Local Storage
  hive: ^4.0.0              # atau isar
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.0

  # Notifications
  flutter_local_notifications: ^17.0.0
  android_alarm_manager_plus: ^4.0.0
  workmanager: ^0.5.0
  permission_handler: ^11.0.0

  # UI
  dynamic_color: ^1.7.0     # Material You dynamic color

  # Utils
  intl: ^0.19.0             # Date/time formatting
  freezed_annotation: ^2.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.0
  freezed: ^2.4.0
  injectable_generator: ^2.4.0
  hive_generator: ^2.0.0

  # Testing
  bloc_test: ^9.1.0
  mocktail: ^1.0.0

  # Linting
  flutter_lints: ^4.0.0
```

---

## 🔀 Git & Version Control

### Branch Strategy
- `main` — production-ready code, protected branch.
- `dev` — development branch, fitur di-merge ke sini dulu.
- `feature/*` — branch fitur baru (e.g., `feature/notification-system`).
- `fix/*` — branch bug fix (e.g., `fix/midnight-reset`).
- `release/*` — branch persiapan release (e.g., `release/v1.0.0`).

### Commit Convention (Conventional Commits)
Wajib ikuti format [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Types yang dipakai:**
| Type | Keterangan | Contoh |
|------|-----------|--------|
| `feat` | Fitur baru | `feat(home): add progress ring animation` |
| `fix` | Bug fix | `fix(notif): alarm not firing in Doze mode` |
| `refactor` | Refactor tanpa ubah behavior | `refactor(repo): extract common DB operations` |
| `perf` | Performance improvement | `perf(ring): optimize canvas redraw` |
| `docs` | Dokumentasi | `docs: update TDD with notification flow` |
| `style` | Formatting, no logic change | `style: apply dart format` |
| `test` | Tambah/ubah test | `test(bloc): add HomeCubit unit tests` |
| `build` | Build system, dependencies | `build: bump flutter_bloc to 8.2` |
| `ci` | CI/CD changes | `ci: add release workflow` |
| `chore` | Maintenance tasks | `chore: clean unused imports` |

**Breaking changes** — tambah `!` setelah type atau tulis `BREAKING CHANGE:` di footer:
```
feat(settings)!: change interval from seconds to minutes
```

### Auto Release & Tagging
Project ini menggunakan GitHub Actions untuk release otomatis (lihat `.github/workflows/release.yml`):
- Push ke `main` dengan conventional commits → auto version bump & release.
- `feat:` → MINOR bump (0.x.0)
- `fix:` / `perf:` / `refactor:` → PATCH bump (0.0.x)
- Breaking change → MAJOR bump (x.0.0)
- Manual trigger via GitHub Actions UI juga tersedia.

---

## ⚠️ Important Rules

### WAJIB
1. **Baca PRD dan TDD** sebelum mulai coding — semua keputusan produk dan teknis sudah tertulis di sana.
2. **Jangan ubah edge case decisions** yang sudah ditandai `[x]` di PRD tanpa approval user.
3. **Notifikasi pakai `android_alarm_manager_plus`** dengan exact alarm, BUKAN `workmanager` untuk time-critical notifications.
4. **`workmanager`** hanya untuk midnight reset dan periodic non-time-critical tasks.
5. **Notification permission** (Android 13+ / iOS) harus di-handle — jangan silent fail.
6. **Test setiap phase** — setiap phase harus bisa build & run sebelum lanjut.

### JANGAN
1. **Jangan** tambah package baru tanpa alasan kuat — stack sudah ditentukan.
2. **Jangan** pakai `SharedPreferences` untuk data kompleks — gunakan `Hive`/`Isar` untuk structured data, `shared_preferences` hanya untuk simple key-value.
3. **Jangan** pakai `setState()` untuk state management — gunakan `BLoC/Cubit`.
4. **Jangan** buat fitur yang ada di "Scope OUT" (PRD section 4).
5. **Jangan** hardcode strings — semua user-facing text siap localization (gunakan `intl` / ARB files).
6. **Jangan** skip notification permission handling — ini core feature.
7. **Jangan** pakai `StatefulWidget` kalau bisa pakai `StatelessWidget` + BLoC.

---

## 🧪 Testing

### Unit Tests
- Cubit/BLoC tests wajib ada untuk `HomeCubit` dan `SettingsCubit`.
- Repository tests untuk logic di `IntakeRepository` dan `SettingsRepository`.
- Notification scheduling logic harus di-test.
- Gunakan `mocktail` untuk mocking, `bloc_test` untuk BLoC testing.

### Widget Tests
- Widget tests untuk Home Screen dan Settings Screen.
- Test user flow: tap preset → progress update → target reached.

### Run Tests
```bash
flutter test                      # All unit & widget tests
flutter test --coverage           # With coverage report
flutter analyze                   # Lint/static analysis
```

---

## 📎 Reference Documents

- [PRD_water-reminder-app.md](./PRD_water-reminder-app.md) — Product Requirements Document
- [TDD_water-reminder-app.md](./TDD_water-reminder-app.md) — Technical Design Document
- [Conventional Commits](https://www.conventionalcommits.org/) — Commit message standard
- [Material Design 3](https://m3.material.io/) — Design system reference
- [BLoC Library](https://bloclibrary.dev/) — State management reference
