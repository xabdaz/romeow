# Local Data Phase 1 - Planning Document

**Tujuan:** Implementasi local data persistence untuk Workspace, Folder, dan Request dalam aplikasi romeow.

---

## 1. Context & Current State

### Existing Models (SharedModels)
- `APIRequest` — Sudah ada, berisi: id, name, method, url, headers, body (Codable ✓)
- `APIResponse` — Tidak Codable (body: Data), hanya untuk runtime
- `MockRoute` — Sudah ada untuk mock server (Codable ✓)

### Current Limitation
- Semua data **in-memory only** — hilang saat app ditutup
- Tidak ada konsep Workspace/Folder
- Hanya single request editing (tidak ada collections)

---

## 2. Data Model Design

### 2.1 New Models (SharedModels)

```swift
// Workspace.swift
public struct Workspace: Equatable, Codable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var createdAt: Date
    public var updatedAt: Date
    public var folders: [Folder]
    public var requests: [RequestItem]  // requests tanpa folder (root level)
}

// Folder.swift
public struct Folder: Equatable, Codable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var createdAt: Date
    public var updatedAt: Date
    public var requests: [RequestItem]
    public var subfolders: [Folder]  // nested folder support
}

// RequestItem.swift (wrapper untuk APIRequest dengan metadata)
public struct RequestItem: Equatable, Codable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var request: APIRequest
    public var createdAt: Date
    public var updatedAt: Date
    public var tags: [String]  // untuk filtering/categorization
}
```

### 2.2 Updated APIRequest (tambahan field opsional)

```swift
public struct APIRequest: Equatable, Codable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var method: HTTPMethod
    public var url: String
    public var headers: [String: String]
    public var body: String?

    // Optional untuk response history (untuk Phase 2)
    // public var lastResponse: StoredAPIResponse?
}
```

### 2.3 StoredAPIResponse (untuk response history, Phase 2)

```swift
public struct StoredAPIResponse: Equatable, Codable, Sendable {
    public var statusCode: Int
    public var headers: [String: String]
    public var body: String?  // Base64 encoded atau raw string
    public var duration: TimeInterval
    public var timestamp: Date
}
```

---

## 3. Storage Strategy

### Pilihan 1: JSON File-based (Recommended untuk Phase 1)

**Lokasi:** `~/Library/Application Support/com.xabdaz.romeow/`

**File Structure:**
```
~/Library/Application Support/com.xabdaz.romeow/
├── workspaces.json          # Array<Workspace>
├── settings.json           # App preferences
└── responses/              # (Phase 2) response history per request
    └── {request-id}.json
```

**Alasan:**
- Sederhana, mudah debug (bisa dibuka di text editor)
- Cocok dengan pola TCA yang existing
- Tidak perlu migration complexity seperti SwiftData
- User bisa manual backup/restore dengan copy file

### Pilihan 2: SwiftData (untuk Phase 2/future)
- Pertimbangkan jika relasi data menjadi kompleks
- Query capabilities lebih powerful
- Tapi lebih complex untuk TCA integration

---

## 4. Architecture Integration (TCA)

### 4.1 New Dependency Client: PersistenceClient

```swift
// Dependencies/Sources/Dependencies/PersistenceClient.swift

public struct PersistenceClient {
    // Workspace operations
    public var loadWorkspaces: @Sendable () async throws -> [Workspace]
    public var saveWorkspaces: @Sendable ([Workspace]) async throws -> Void

    // Single workspace operations
    public var createWorkspace: @Sendable (String) async throws -> Workspace
    public var updateWorkspace: @Sendable (Workspace) async throws -> Void
    public var deleteWorkspace: @Sendable (UUID) async throws -> Void

    // Folder operations
    public var createFolder: @Sendable (workspaceId: UUID, name: String, parentFolderId: UUID?) async throws -> Folder
    public var updateFolder: @Sendable (Folder) async throws -> Void
    public var deleteFolder: @Sendable (UUID) async throws -> Void

    // Request operations
    public var createRequest: @Sendable (workspaceId: UUID, folderId: UUID?, request: APIRequest) async throws -> RequestItem
    public var updateRequest: @Sendable (RequestItem) async throws -> Void
    public var deleteRequest: @Sendable (UUID) async throws -> Void
}
```

### 4.2 Live Implementation

```swift
public extension PersistenceClient {
    static var liveValue: PersistenceClient {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("com.xabdaz.romeow", isDirectory: true)
        let workspacesFile = appSupportURL.appendingPathComponent("workspaces.json")

        return PersistenceClient(
            loadWorkspaces: {
                // Buat directory jika belum ada
                // Decode dari JSON file
            },
            saveWorkspaces: { workspaces in
                // Encode ke JSON dengan pretty print
                // Atomic write (ke temp file lalu rename)
            },
            // ... implementasi lainnya
        )
    }
}
```

---

## 5. Feature Modules (New)

### 5.1 WorkspaceFeature

**State:**
```swift
@ObservableState
public struct State: Equatable {
    public var workspaces: [Workspace] = []
    public var selectedWorkspaceId: UUID?
    public var isLoading: Bool = false
    public var errorMessage: String?

    // Sheet states
    public var isCreateWorkspaceSheetPresented: Bool = false
    public var newWorkspaceName: String = ""
}
```

**Action:**
```swift
public enum Action {
    case onAppear
    case workspacesLoaded([Workspace])
    case createWorkspaceTapped
    case createWorkspaceConfirmed
    case workspaceCreated(Workspace)
    case selectWorkspace(UUID)
    case deleteWorkspace(UUID)
    case setNewWorkspaceName(String)
    case dismissError
}
```

### 5.2 RequestListFeature

Menampilkan daftar request dalam workspace/folder dengan tree structure.

**State:**
```swift
@ObservableState
public struct State: Equatable {
    public var workspace: Workspace
    public var selectedItem: SelectedItem?  // request atau folder
    public var expandedFolders: Set<UUID> = []
    public var searchQuery: String = ""
}

public enum SelectedItem: Equatable {
    case request(UUID)
    case folder(UUID)
}
```

**Action:**
```swift
public enum Action {
    case requestTapped(UUID)
    case folderTapped(UUID)
    case folderExpanded(UUID)
    case folderCollapsed(UUID)
    case createRequestTapped(folderId: UUID?)
    case createFolderTapped(parentId: UUID?)
    case deleteRequest(UUID)
    case deleteFolder(UUID)
    case searchQueryChanged(String)
    case moveRequest(UUID, toFolder: UUID?)
}
```

### 5.3 Updates ke RequestFeature

Tambahkan integrasi dengan persisted data:

```swift
@ObservableState
public struct State: Equatable {
    public var requestItem: RequestItem  // instead of raw APIRequest
    public var isEditing: Bool = false
    public var hasUnsavedChanges: Bool = false
}
```

Actions baru:
- `saveButtonTapped` — Simpan ke persistence
- `duplicateTapped` — Buat copy baru
- `renameTapped` — Ganti nama request

---

## 6. UI Changes

### 6.1 Sidebar Structure Baru

```
📁 Sidebar (NavigationSplitView)
├── 🔍 Search Bar (filter workspaces/requests)
├── ➕ New Request Button
│
├── 📂 Workspaces Section
│   ├── Workspace A (expandable)
│   │   ├── 📁 Folder 1
│   │   │   ├── GET /users
│   │   │   └── POST /login
│   │   ├── 📁 Folder 2
│   │   └── 🌐 GET /products (root request)
│   └── Workspace B
│
├── ────────────────
│
├── ⚙️ Mock Server
│   └── Routes...
│
└── 🕐 History (Phase 2)
```

### 6.2 Context Menu Actions

**Pada Workspace:**
- Rename
- Delete
- Duplicate
- New Folder
- New Request
- Export

**Pada Folder:**
- Rename
- Delete
- New Subfolder
- New Request
- Collapse/Expand

**Pada Request:**
- Rename
- Duplicate
- Delete
- Move to Folder...
- Copy cURL
- Export

---

## 7. Implementation Phases

### Phase 1A: Foundation (Sprint ini)
1. **Create new models** di SharedModels (Workspace, Folder, RequestItem)
2. **Create PersistenceClient** dependency dengan live implementation
3. **Create WorkspaceFeature** — list workspace dasar
4. **Update AppFeature** — integrasi workspace ke navigation

### Phase 1B: Request Management
1. **Create RequestListFeature** — tree view requests & folders
2. **Update RequestFeature** — save/load dari persistence
3. **Implement CRUD operations** untuk request & folder
4. **Add search & filter**

### Phase 1C: Polish
1. **Drag & drop** untuk reorder dan move
2. **Import/Export** (JSON format)
3. **Keyboard shortcuts** (⌘N new request, ⌘⇧N new folder, ⌘⌫ delete)
4. **Recent workspaces** di menu bar

---

## 8. File Structure

```
romeow/Packages/
├── SharedModels/
│   └── Sources/SharedModels/
│       ├── APIRequest.swift          # (existing)
│       ├── Workspace.swift           # NEW
│       ├── Folder.swift              # NEW
│       └── RequestItem.swift         # NEW
│
├── Dependencies/
│   └── Sources/Dependencies/
│       ├── URLSessionClient.swift    # (existing)
│       ├── MockServerClient.swift    # (existing)
│       └── PersistenceClient.swift   # NEW
│
├── WorkspaceFeature/                 # NEW Package
│   └── Sources/WorkspaceFeature/
│       └── WorkspaceFeature.swift
│
├── RequestListFeature/               # NEW Package
│   └── Sources/RequestListFeature/
│       └── RequestListFeature.swift
│
├── RequestFeature/                   # (existing - update)
│   └── Sources/RequestFeature/
│       └── RequestFeature.swift
│
└── AppFeature/                       # (existing - update)
    └── Sources/AppFeature/
        └── AppFeature.swift
```

---

## 9. Data Migration Strategy

### Versioning
Tambahkan `version: Int` di root JSON untuk future migrations:

```json
{
  "version": 1,
  "workspaces": [...]
}
```

### Initial Data
Saat pertama kali launch (tidak ada file), buat default workspace:
- Name: "Default"
- Contains: Sample GET request ke https://httpbin.org/get

---

## 10. Testing Strategy

### Unit Tests per Feature
- Test reducer dengan `TestStore`
- Mock `PersistenceClient` untuk test

### Persistence Tests
- Test JSON encoding/decoding
- Test file operations (create, read, update, delete)
- Test atomic writes (tidak corrupt saat crash)

### Integration Tests
- End-to-end: create workspace → add request → save → relaunch → verify loaded

---

## 11. Open Questions

1. **Apakah perlu cloud sync?** (iCloud) — Untuk Phase 2?
2. **Apakah perlu environment variables per workspace?** (base URL, auth tokens)
3. **Bagaimana handle binary body untuk request?** (file upload)
4. **Apakah perlu request collections/sharing?** (export/import team)

---

## 12. Deliverables Checklist

- [ ] SharedModels: Workspace, Folder, RequestItem
- [ ] PersistenceClient dependency (live + test)
- [ ] WorkspaceFeature (list, create, delete)
- [ ] RequestListFeature (tree view)
- [ ] Updated RequestFeature (save integration)
- [ ] Updated AppFeature (new navigation)
- [ ] Unit tests untuk persistence
- [ ] Unit tests untuk features

---

## 13. Estimasi Effort

| Task | Estimasi |
|------|----------|
| Data Models | 2-3 jam |
| PersistenceClient | 4-5 jam |
| WorkspaceFeature | 4-6 jam |
| RequestListFeature | 6-8 jam |
| Update RequestFeature | 3-4 jam |
| UI Polish & Bugfix | 4-6 jam |
| Tests | 4-6 jam |
| **Total** | **~30-40 jam** |

---

*Document Version: 1.0*
*Created: 2026-03-14*
*Status: Ready for Review*
