# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**romeow** adalah aplikasi macOS berbasis SwiftUI yang berfungsi sebagai klien API dan mock API — untuk membuat HTTP request, melihat response, serta menjalankan mock server lokal.

- **Platform:** macOS 26.2+
- **Language:** Swift 5.0
- **UI Framework:** SwiftUI
- **Architecture:** TCA (The Composable Architecture) + Multi Local SPM Package
- **Bundle ID:** `com.xabdaz.romeow`
- **HTTP Server:** Hummingbird v2 (untuk mock server engine)
- **App Mode:** Menu bar app (`MenuBarExtra`) + optional main window

## Build & Test Commands

```bash
# Build app
xcodebuild build -project romeow.xcodeproj -scheme romeow -destination 'generic/platform=macOS'

# Run semua unit tests
xcodebuild test -project romeow.xcodeproj -scheme romeow -destination 'platform=macOS'

# Run test untuk package tertentu (contoh: RequestFeature)
xcodebuild test -scheme RequestFeature -destination 'platform=macOS'

# Run single test
xcodebuild test -project romeow.xcodeproj -scheme romeow -destination 'platform=macOS' -only-testing:romeowTests/TestClassName/testMethodName
```

## Architecture

Menggunakan **TCA (The Composable Architecture)** dengan struktur **Multi Local SPM Package**. App target (`romeow/`) hanya berperan sebagai thin shell yang memanggil `AppFeature`.

### Struktur Package

```
romeow/
├── romeow/                   # App target (entry point saja)
│   ├── romeowApp.swift
│   └── ContentView.swift
└── Packages/
    ├── AppFeature/           # Root reducer + NavigationSplitView
    ├── RequestFeature/       # HTTP request builder (method, URL, headers, body)
    ├── ResponseFeature/      # Response viewer (status, headers, body, timing)
    ├── MockServerFeature/    # Mock API engine (define routes, start/stop server)
    ├── SharedModels/         # Tipe data bersama: APIRequest, APIResponse, MockRoute
    └── Dependencies/         # TCA dependency clients: URLSessionClient, MockServerClient
```

### Alur Data TCA

Setiap feature mengikuti pola standar TCA:

```
View → Action → Reducer → Effect → (State update / Dependency call)
```

- **State** — nilai immutable yang di-render oleh View
- **Action** — enum yang merepresentasikan "apa yang terjadi" (bukan "apa yang harus dilakukan")
- **Reducer** — pure function yang memutasi State dan menghasilkan Effect
- **Effect** — async work (network request, server, dll) yang dikembalikan sebagai `Effect<Action>`
- **Dependency** — diakses via `@Dependency(\.namaClient)` di dalam Reducer

### Navigation

Menggunakan `NavigationSplitView` (macOS pattern: sidebar + detail):
- **Sidebar** — daftar fitur (Request Builder, Mock Server, Collections)
- **Detail** — konten fitur yang dipilih, di-drive oleh selection state di `AppFeature`

### Dependencies

Semua I/O diabstraksi sebagai TCA dependency client di package `Dependencies/`:

| Client | Kegunaan |
|---|---|
| `URLSessionClient` | Eksekusi HTTP request |
| `MockServerClient` | Start/stop mock server, register route |

Setiap client memiliki `liveValue` (implementasi nyata) dan `testValue` (mock) sehingga reducer bisa di-test tanpa network atau server sungguhan.

### Menu Bar & Background Mode

App berjalan sebagai **menu bar app** menggunakan `MenuBarExtra` (SwiftUI native, macOS 13+):
- **Menu bar icon** — menampilkan status mock server (aktif/nonaktif) dan shortcut aksi cepat
- **Main window** — bisa dibuka dari menu bar, berisi full UI (Request Builder, Response Viewer, Mock Server manager)
- App tetap hidup di background selama mock server berjalan

```swift
@main
struct romeowApp: App {
    var body: some Scene {
        MenuBarExtra("romeow", systemImage: "network") {
            MenuBarView() // status server + quick actions
        }
        Window("romeow", id: "main") {
            AppView()    // full UI
        }
    }
}
```

### Mock Server Engine

Menggunakan **Hummingbird v2** sebagai embedded HTTP server di dalam `MockServerFeature`:

- Native `async/await` — kompatibel langsung dengan TCA `Effect`
- Ringan, tanpa dependency besar (tidak seperti Vapor)
- Start/stop dikontrol via `MockServerClient` dependency dari TCA

```swift
// MockServerClient.liveValue — start/stop server programatically
func start(routes: [MockRoute]) async throws -> HBApplication
func stop(_ app: HBApplication) async throws
```

SPM dependency di `MockServerFeature/Package.swift`:
```swift
.package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0")
```

### Testing

- **Unit tests per package** — setiap package punya test target sendiri
- **`TestStore`** — digunakan untuk test reducer TCA (assert state mutation dan effect)
- **Unit tests app:** `romeowTests/` menggunakan Swift Testing framework (`@Test`, `#expect`)
- **UI tests:** `romeowUITests/` menggunakan XCTest framework
