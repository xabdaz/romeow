# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**romeow** — macOS SwiftUI app that serves as both an API client (HTTP request builder + response viewer) and a local mock API server.

- **Platform:** macOS 14+
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Architecture:** TCA (The Composable Architecture 1.0+) with Multi Local SPM Package
- **Bundle ID:** `com.xabdaz.romeow`
- **HTTP Server:** Hummingbird v2 (mock server engine)
- **Persistence:** Core Data (programmatic model via generic `NSManagedObject` — no `.xcdatamodeld`)

## Build & Test Commands

```bash
# Build
xcodebuild build -project romeow.xcodeproj -scheme romeow -destination 'generic/platform=macOS'

# Run all unit tests
xcodebuild test -project romeow.xcodeproj -scheme romeow -destination 'platform=macOS'

# Run tests for a specific package
xcodebuild test -scheme RequestFeature -destination 'platform=macOS'

# Run a single test
xcodebuild test -project romeow.xcodeproj -scheme romeow -destination 'platform=macOS' \
  -only-testing:romeowTests/TestClassName/testMethodName
```

## Architecture

### Package Dependency Graph

App target (`romeow/`) is a thin shell — all logic lives in local SPM packages under `Packages/`:

```
                              ┌─────────────┐
                              │ SharedModels│
                              └─────────────┘
                                    ▲
                ┌───────────────────┼───────────────────┐
                │                   │                   │
         ┌──────┴──────┐    ┌──────┴──────┐    ┌───────┴───────┐
         │ AppClients  │    │ResponseFeature│   │               │
         └─────────────┘    └──────────────┘   │               │
                ▲                   ▲           │               │
                │                   │           │               │
         ┌──────┴──────┐            │    ┌──────┴──────┐        │
         │RequestFeature├───────────┘    │MockServerFeature─────┘
         └─────────────┘                 └─────────────┘
                ▲                               ▲
                │                               │
                └───────────┬───────────────────┘
                      ┌─────┴─────┐
                      │ AppFeature │
                      └───────────┘
```

External dependencies:
- **swift-composable-architecture** (1.0+) — used by all packages except SharedModels
- **hummingbird** (2.0+) — only in AppClients (mock server engine)
- **swift-http-types** (1.0+) — only in AppClients

### Key Features & Their Packages

| Feature | Package | Purpose |
|---|---|---|
| Root shell | `AppFeature` | Root `@Reducer`, `AppView` with `NavigationSplitView`, feature switching |
| HTTP client | `RequestFeature` | Request builder (method, URL, headers, body), sidebar with workspace/folder/request tree, response display |
| Response viewer | `ResponseFeature` | Tab-based response viewer (body, headers, info) |
| Mock server | `MockServerFeature` | Workspace-based mock route management, start/stop Hummingbird server |
| Shared types | `SharedModels` | `APIRequest`, `APIResponse`, `HTTPMethod`, `MockRoute`, `MockWorkspace`, `Workspace`, `Folder`, `RequestItem` — domain models shared across features |
| I/O clients | `AppClients` | `URLSessionClient`, `MockServerClient`, `CoreDataClient` — all TCA `DependencyKey` conforming, closure-based dependency injection |

### TCA Patterns Used

**State:** All features use `@ObservableState` macro on `State` structs.

**Feature composition:** `AppFeature` composes child features via `Scope`:
```swift
Scope(state: \.request, action: \.request) { RequestFeature() }
Scope(state: \.mockServer, action: \.mockServer) { MockServerFeature() }
```

**Child-to-parent communication:** Via `Delegate` action pattern:
```swift
public enum Action {
    case delegate(Delegate)
    public enum Delegate {
        case featureSwitcherTapped
    }
}
```
Parent intercepts delegate actions in its `Reduce` block.

**Response sync:** When `RequestFeature` receives a response, `AppFeature` intercepts `request(.responseReceived(.success(apiResponse)))` and writes it into `ResponseFeature.State`.

**Dependencies:** All I/O is abstracted as closure-based TCA dependency clients in `AppClients/`. Each client struct has `liveValue` (real implementation) and `testValue` (mock):
```swift
@Dependency(\.urlSessionClient) var urlSessionClient
@Dependency(\.mockServerClient) var mockServerClient
@Dependency(\.coreData) var coreData
```

### Core Data Architecture

Uses **programmatic model** — no `.xcdatamodeld` file. The model is built in `CoreDataStack.createModel()` inside `CoreDataClient.swift`.

- **Entities:** `Workspace` (id, name, createdAt, updatedAt) and `Route` (id, workspaceId, name, method, path, statusCode, responseBody, responseHeaders, isEnabled, createdAt, updatedAt)
- **Access pattern:** `CoreDataActor` (a Swift `actor`) wraps all operations for thread safety
- **Store location:** `~/Library/Application Support/romeow/MockAPI.sqlite`
- **Headers storage:** Response headers are JSON-encoded as strings in Core Data

> **Note:** There is also a `PersistenceController.swift` in `romeow/CoreData/` that references `MockWorkspaceEntity` / `MockRouteEntity` subclasses — this is an older approach. The active implementation uses the generic `NSManagedObject` pattern in `AppClients/CoreDataClient.swift`.

### Mock Server Engine

`MockServerClient` wraps a private `ServerManager` actor that manages a Hummingbird `Application`:
- Binds to `127.0.0.1:{port}` (default 8080)
- Registers a built-in `GET /health` endpoint (reserved, cannot be overridden by user routes)
- User routes are registered dynamically from enabled `MockRoute`s in the selected workspace
- Server runs in a cancellable `Task` — uses `CancelID.server` for TCA cancellation

### App Entry Point

`romeowApp.swift` creates a single `Window` scene with a TCA `Store`. MenuBarExtra is currently commented out but the UI (`MenuBarView`) is ready.

The main view (`ContentView`) shows a toolbar with `FeatureSwitcherButton` (grid popup to switch between "REST API" and "Mock Server") and a `SubFeatureSwitcherButton` (workspace picker).

### Sandbox Entitlements

The app runs sandboxed with `network.client` (outbound HTTP) and `network.server` (Hummingbird mock server) permissions.

## Commit Convention

Format: `<type>(<scope>): <description>`

Types: `feat`, `fix`, `docs`, `refactor`, `test`

Examples from history:
```
feat(MockServerFeature): add server reducer and start/stop UI
fix: refactor Core Data to use generic NSManagedObject
refactor: split multiple structs into separate files
```

## Testing

- **App-level tests:** `romeowTests/` — Swift Testing framework (`@Test`, `#expect`)
- **UI tests:** `romeowUITests/` — XCTest framework
- **Package tests:** Each package has a test target (e.g., `AppFeatureTests`, `RequestFeatureTests`) — use TCA `TestStore` for reducer testing
