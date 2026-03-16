# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**romeow** adalah aplikasi macOS berbasis SwiftUI yang berfungsi sebagai klien API dan mock API — untuk membuat HTTP request, melihat response, serta menjalankan mock server lokal.

- **Platform:** macOS 14+
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Architecture:** TCA (The Composable Architecture) + Multi Local SPM Package
- **Bundle ID:** `com.xabdaz.romeow`
- **HTTP Server:** Hummingbird v2 (untuk mock server engine)
- **Persistence:** Core Data (programmatic model, generic NSManagedObject)

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
│   ├── ContentView.swift
│   ├── MenuBarView.swift
│   └── CoreData/
└── Packages/
    ├── AppFeature/           # Root reducer + NavigationSplitView
    ├── RequestFeature/       # HTTP request builder (method, URL, headers, body)
    ├── ResponseFeature/      # Response viewer (status, headers, body, timing)
    ├── MockServerFeature/    # Mock API engine with workspace support
    ├── SharedModels/         # Tipe data bersama: APIRequest, APIResponse, MockRoute, MockWorkspace
    └── AppClients/           # TCA dependency clients: URLSessionClient, MockServerClient, CoreDataClient
```

### Alur Data TCA

Setiap feature mengikuti pola standar TCA:

```
View → Action → Reducer → Effect → (State update / Dependency call)
```

- **State** — nilai immutable yang di-render oleh View, menggunakan `@ObservableState` macro
- **Action** — enum yang merepresentasikan "apa yang terjadi" (bukan "apa yang harus dilakukan")
- **Reducer** — `@Reducer` struct dengan `body` property yang mengkomposisi reducer lain
- **Effect** — async work yang dikembalikan sebagai `Effect<Action>`, menggunakan `.run { send in }`
- **Dependency** — diakses via `@Dependency(\.clientName)` di dalam Reducer

### Feature Composition Pattern

Features dikomposisi menggunakan `Scope` dan `Reduce`:

```swift
public var body: some ReducerOf<Self> {
    Scope(state: \.childFeature, action: \.childFeature) {
        ChildFeature()
    }
    Reduce { state, action in
        // Handle actions and delegate from child
    }
}
```

Child features mengkomunikasikan ke parent via `Delegate` action pattern:

```swift
public enum Action {
    case delegate(Delegate)
    public enum Delegate {
        case featureSwitcherTapped
    }
}
```

### Dependencies

Semua I/O diabstraksi sebagai TCA dependency client di package `AppClients/`:

| Client | Kegunaan |
|---|---|
| `URLSessionClient` | Eksekusi HTTP request via URLSession |
| `MockServerClient` | Start/stop Hummingbird mock server |
| `CoreDataClient` | CRUD workspace dan route ke Core Data |

Setiap client adalah struct dengan closure properties dan mengkonform `DependencyKey`:

```swift
public struct SomeClient: Sendable {
    public var doSomething: @Sendable () async throws -> Result
}

extension SomeClient: DependencyKey {
    public static let liveValue = SomeClient(...)  // Implementasi nyata
    public static let testValue = SomeClient(...)  // Mock untuk test
}
```

### Mock Server dengan Workspace

`MockServerFeature` mengorganisir routes dalam **workspaces** yang dipersist ke Core Data:

- **Workspace** — container untuk sekelompok routes (contoh: "Project API", "Mobile Backend")
- **Route** — endpoint mock dengan method, path, status code, response body, dan headers
- **Persistence** — Core Data dengan programmatic model (tidak menggunakan .xcdatamodeld)

Pattern Core Data:
- Menggunakan generic `NSManagedObject` (tidak ada subclass entity)
- Model didefinisikan programmatic di `CoreDataStack.createModel()`
- Actor-based (`CoreDataActor`) untuk thread safety
- Store di `~/Library/Application Support/romeow/MockAPI.sqlite`

### Mock Server Engine

Menggunakan **Hummingbird v2** sebagai embedded HTTP server:

```swift
// MockServerClient.liveValue — start/stop server via actor
func start(port: Int, routes: [MockRoute]) async throws
func stop() async throws
```

- Native `async/await` — kompatibel dengan TCA `Effect`
- Routes diregister dynamic saat server start
- Server berjalan di background Task yang bisa di-cancel

### Testing

- **Unit tests per package** — setiap package punya test target sendiri
- **`TestStore`** — digunakan untuk test reducer TCA (assert state mutation dan effect)
- **Unit tests app:** `romeowTests/` menggunakan Swift Testing framework (`@Test`, `#expect`)
- **UI tests:** `romeowUITests/` menggunakan XCTest framework
