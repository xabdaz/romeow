# Vibe Kanban Workspace

Workspace development management untuk project romeow menggunakan Git worktree.

## Apa itu Vibe Kanban?

Vibe Kanban adalah sistem workspace management yang memungkinkan:
- Multiple branch aktif secara simultan dalam direktori terpisah
- Isolasi feature development antar branch
- Preview proxy server untuk testing
- Konteks project yang terjaga antar session

## Struktur Workspace

```
/private/var/folders/ns/x_tj8srd7w50_4h7xhnrk7x40000gn/T/vibe-kanban/
├── vibe-kanban.port          # Konfigurasi port (main: 8318, preview: 64993)
├── README.md                 # Dokumentasi ini
└── worktrees/                # Git worktrees
    └── a3a4-pelajari-project/  # Current worktree (vk/a3a4-pelajari-project branch)
        └── romeow/             # Project root
```

## Konfigurasi Port

File `vibe-kanban.port`:
```json
{
  "main_port": 8318,
  "preview_proxy_port": 64993
}
```

| Port | Kegunaan |
|------|----------|
| 8318 | Main development server |
| 64993 | Preview proxy untuk testing |

## Project: romeow

**romeow** adalah aplikasi macOS menu bar untuk API client dan mock server.

### Tech Stack

- **Platform**: macOS 26.2+
- **Language**: Swift 5.0
- **UI Framework**: SwiftUI
- **Architecture**: TCA (The Composable Architecture)
- **HTTP Server**: Hummingbird v2
- **Bundle ID**: `com.xabdaz.romeow`

### Struktur Project

```
romeow/
├── romeow/                   # App target (entry point)
│   ├── romeowApp.swift       # MenuBarExtra + Window
│   ├── ContentView.swift     # Main window
│   ├── MenuBarView.swift     # Menu bar UI
│   └── romeow.entitlements   # Sandbox permissions
├── romeowTests/              # Unit tests (Swift Testing)
├── romeowUITests/            # UI tests (XCTest)
├── romeow.xcodeproj/         # Xcode project
└── Packages/                 # Local SPM packages
    ├── AppFeature/           # Root reducer + NavigationSplitView
    ├── RequestFeature/       # HTTP request builder
    ├── ResponseFeature/      # Response viewer
    ├── MockServerFeature/    # Mock API engine (Hummingbird)
    ├── SharedModels/         # APIRequest, APIResponse, MockRoute
    └── AppClients/           # TCA dependency clients
```

### Build Commands

```bash
# Build app
xcodebuild build -project romeow.xcodeproj -scheme romeow -destination 'generic/platform=macOS'

# Run all tests
xcodebuild test -project romeow.xcodeproj -scheme romeow -destination 'platform=macOS'

# Run package tests
xcodebuild test -scheme RequestFeature -destination 'platform=macOS'
```

### Features

1. **HTTP Request Builder** - Membuat dan mengirim HTTP request
2. **Response Viewer** - Melihat response (status, headers, body, timing)
3. **Mock Server** - Menjalankan local HTTP mock server dengan route yang dikonfigurasi

### TCA Architecture Pattern

```
View → Action → Reducer → Effect → State update / Dependency call
```

Setiap feature mengikuti pola:
- **State** — immutable value di-render oleh View
- **Action** — enum "apa yang terjadi"
- **Reducer** — pure function mutasi State + Effect
- **Effect** — async work (network, server)
- **Dependency** — `@Dependency(\.client)`

### Dependencies

| Client | Kegunaan |
|--------|----------|
| `URLSessionClient` | Eksekusi HTTP request |
| `MockServerClient` | Start/stop mock server |

## Workflow Development

### Membuat Worktree Baru

```bash
# Dari main branch
git checkout main

# Buat worktree baru untuk feature
git worktree add ../worktrees/nama-feature-branch nama-feature-branch

# Atau buat branch baru
git worktree add -b vk/nama-feature ../worktrees/nama-feature
```

### Switch Worktree

```bash
# Masuk ke worktree
cd /private/var/folders/ns/x_tj8srd7w50_4h7xhnrk7x40000gn/T/vibe-kanban/worktrees/[nama-worktree]/romeow

# Atau symlink jika diperlukan
```

### Cleanup Worktree

```bash
# Hapus worktree
git worktree remove worktrees/nama-feature

# Hapus branch (jika tidak diperlukan lagi)
git branch -D nama-feature
```

## Git Workflow

### Current Branch
- **main** — Production-ready code
- **vk/a3a4-pelajari-project** — Current development branch (pelajari-project)

### Commit Convention

Format: `<type>(<scope>): <description>`

Types:
- `feat` — New feature
- `fix` — Bug fix
- `docs` — Documentation
- `refactor` — Code restructuring
- `test` — Adding tests

Contoh:
```
feat(MockServerFeature): add server reducer and start/stop UI
fix(app): wire up TCA store, menu bar, and app entry point
```

## Development Notes

### Sandbox Permissions

File: `romeow/romeow/romeow.entitlements`

```xml
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.network.server</key>
<true/>
```

Diperlukan untuk:
- `network.client` — Membuat HTTP request outbound
- `network.server` — Menjalankan mock server (Hummingbird)

### Mock Server Default Route

Server otomatis menyediakan endpoint health check:
```
GET http://127.0.0.1:{port}/health
Response: {"status":"ok"}
```

### Menu Bar Integration

App berjalan sebagai menu bar app:
- Icon menampilkan status server (running/stopped)
- Quick actions: Start/Stop server, Open main window, Quit
- App tetap hidup di background saat server running

## Resources

- [TCA Documentation](https://pointfreeco.github.io/swift-composable-architecture/)
- [Hummingbird v2](https://github.com/hummingbird-project/hummingbird)
- [SwiftUI MenuBarExtra](https://developer.apple.com/documentation/swiftui/menubarextra)

---

*Workspace ini dikelola oleh Claude Code untuk development romeow project.*
