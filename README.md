# MarkMe — Smart QR Attendance Mobile App

MarkMe is a high-performance cross-platform mobile attendance solution built with Flutter, powered by a Supabase REST backend, state-managed via BLoC, networked via pure Dio HTTP client, and persisted locally using SQLite for offline access.

---

## 🔐 Credentials & Testing Accounts

The application provides dedicated portals for **Admin** and **Employee** roles, with an easy portal switcher to toggle between portals.

### 🏢 Admin Portal Credentials
Used to generate time-limited (2-minute) authoritative QR sessions, inspect employee records with real-time search, filters, pagination, and monitor today's attendance metrics.

| Role | Email | Password | Employee Code | Name |
|---|---|---|---|---|
| **System Admin** | `admin@markme.com` | `Password123!` | `ADM001` | System Admin |
| **Admin Demo** | `admin@mail.com` | `MarkMe@2026` | `ADM001` | System Admin |

### 👷 Employee Portal Credentials
Used to scan active admin QR codes with high-accuracy GPS coordinates, record check-in and check-out, and view personal attendance history offline.

| Account | Email | Password | Employee Code | Name |
|---|---|---|---|---|
| **User 1 (Primary)** | `user1@mail.com` | `User@01` | `EMP006` | User One |
| **User 2 (Secondary)** | `user2@mail.com` | `User@02` | `EMP007` | User Two |
| **Employee 1** | `emp1@markme.com` | `Password123!` | `EMP001` | Alice Johnson |

---

## 📱 Core Features

### 1. Dual Authentication & Portal Switcher
- Dedicated **Admin Sign In** and **Employee Sign In** interfaces.
- One-tap portal switcher button at the bottom of the sign-in form.
- Encrypted JWT session restoration with auto-login via `flutter_secure_storage`.
- Role-based route protection via declarative `GoRouter`.

### 2. Admin Station & Monitoring
- **Time-Limited QR Session Generation:** Generates authoritative 2-minute attendance QR sessions via backend RPC.
- **Dynamic Live Countdown:** Color-coded timer (Blue $\rightarrow$ Amber $\rightarrow$ Red) with auto-expiration at 0s.
- **Attendance Records Dashboard:** PostgREST queries joined with employee records, lazy-loading infinite pagination (20 records/page), real-time search, and date filters ("All Dates", "Today", custom picker).
- **Today's Metric Cards:** Vertical column arrangement (`Icon` $\rightarrow$ `Count` $\rightarrow$ `Label`) for Today's Check-Ins and Completed Today.
- **Shimmer Skeletons:** Slate-gradient skeleton loading across metric cards, record lists, and pagination.

### 3. Employee Attendance & Scanner
- **Today's Status Dashboard:** Real-time arrival and departure summary, dynamic status pills, verified timestamps, and work duration.
- **Live QR Scanner:** Built with `mobile_scanner`, custom Royal Blue corner guides, animated beam, torch control, and GPS location validation.
- **Zero-Trust Backend Validation:** Prevents QR reuse (`SESSION_REUSED`), double check-outs (`ALREADY_COMPLETED`), and expired session scans (`QR_EXPIRED`).
- **Offline-First Attendance History:** Local SQLite database (`markme_local.db`) caching with pull-to-refresh synchronization.

---

## 🛠 Tech Stack & Architecture

- **Architecture:** Feature-First Clean Architecture (Presentation, Domain, Data)
- **Framework:** Flutter (Dart SDK `^3.13.4`)
- **State Management:** `flutter_bloc` / `bloc_concurrency` with `droppable()` transformers
- **Networking:** Pure `dio` (no `supabase_flutter` SDK)
- **Local Persistence:** `sqflite` (SQLite) + `flutter_secure_storage`
- **Scanning & Rendering:** `mobile_scanner` + `qr_flutter`
- **Responsive UI:** `flutter_screenutil` (anchored to `375x812` canvas)
- **Typography & Theme:** Google Fonts (Plus Jakarta Sans) with Royal Blue design system

---

## 🚀 Getting Started

### 1. Environment Setup
Create a `.env` file in the project root (see `.env.example`):
```env
SUPABASE_URL=https://<your-project-ref>.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
```

### 2. Run the Application
Run with compile-time environment configuration:
```bash
flutter run --dart-define-from-file=.env
```

### 3. Run Static Analysis & Tests
```bash
# Verify static analysis (0 errors, 0 warnings)
dart analyze

# Run unit and widget test suite
flutter test
```
flutter build apk --split-per-abi --release --dart-define-from-file=.env --obfuscate --split-debug-info=./debug-symbols/android