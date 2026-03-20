import ComposableArchitecture
import CoreData
import Foundation
import SharedModels

// MARK: - Core Data Client

public struct CoreDataClient: Sendable {
    // MARK: - Mock Server Feature
    public var fetchWorkspaces: @Sendable () async throws -> [MockWorkspace]
    public var saveWorkspace: @Sendable (MockWorkspace) async throws -> MockWorkspace
    public var deleteWorkspace: @Sendable (UUID) async throws -> Void
    public var fetchRoutes: @Sendable (UUID?) async throws -> [MockRoute]
    public var saveRoute: @Sendable (MockRoute) async throws -> MockRoute
    public var deleteRoute: @Sendable (UUID) async throws -> Void

    // MARK: - REST API Feature
    public var fetchAPIWorkspaces: @Sendable () async throws -> [Workspace]
    public var saveAPIWorkspace: @Sendable (Workspace) async throws -> Workspace
    public var deleteAPIWorkspace: @Sendable (UUID) async throws -> Void
    public var fetchAPIFolders: @Sendable (UUID) async throws -> [Folder]
    public var saveAPIFolder: @Sendable (Folder, UUID) async throws -> Folder
    public var deleteAPIFolder: @Sendable (UUID) async throws -> Void
    public var fetchAPIRequests: @Sendable (UUID?) async throws -> [RequestItem]
    public var saveAPIRequest: @Sendable (RequestItem, UUID?) async throws -> RequestItem
    public var deleteAPIRequest: @Sendable (UUID) async throws -> Void

    public init(
        fetchWorkspaces: @Sendable @escaping () async throws -> [MockWorkspace],
        saveWorkspace: @Sendable @escaping (MockWorkspace) async throws -> MockWorkspace,
        deleteWorkspace: @Sendable @escaping (UUID) async throws -> Void,
        fetchRoutes: @Sendable @escaping (UUID?) async throws -> [MockRoute],
        saveRoute: @Sendable @escaping (MockRoute) async throws -> MockRoute,
        deleteRoute: @Sendable @escaping (UUID) async throws -> Void,
        fetchAPIWorkspaces: @Sendable @escaping () async throws -> [Workspace],
        saveAPIWorkspace: @Sendable @escaping (Workspace) async throws -> Workspace,
        deleteAPIWorkspace: @Sendable @escaping (UUID) async throws -> Void,
        fetchAPIFolders: @Sendable @escaping (UUID) async throws -> [Folder],
        saveAPIFolder: @Sendable @escaping (Folder, UUID) async throws -> Folder,
        deleteAPIFolder: @Sendable @escaping (UUID) async throws -> Void,
        fetchAPIRequests: @Sendable @escaping (UUID?) async throws -> [RequestItem],
        saveAPIRequest: @Sendable @escaping (RequestItem, UUID?) async throws -> RequestItem,
        deleteAPIRequest: @Sendable @escaping (UUID) async throws -> Void
    ) {
        self.fetchWorkspaces = fetchWorkspaces
        self.saveWorkspace = saveWorkspace
        self.deleteWorkspace = deleteWorkspace
        self.fetchRoutes = fetchRoutes
        self.saveRoute = saveRoute
        self.deleteRoute = deleteRoute
        self.fetchAPIWorkspaces = fetchAPIWorkspaces
        self.saveAPIWorkspace = saveAPIWorkspace
        self.deleteAPIWorkspace = deleteAPIWorkspace
        self.fetchAPIFolders = fetchAPIFolders
        self.saveAPIFolder = saveAPIFolder
        self.deleteAPIFolder = deleteAPIFolder
        self.fetchAPIRequests = fetchAPIRequests
        self.saveAPIRequest = saveAPIRequest
        self.deleteAPIRequest = deleteAPIRequest
    }
}

// MARK: - Core Data Stack

private final class CoreDataStack: @unchecked Sendable {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    private init() {
        // Create model programmatically
        let model = CoreDataStack.createModel()

        persistentContainer = NSPersistentContainer(name: "MockAPIModel", managedObjectModel: model)

        let storeURL = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("romeow")
            .appendingPathComponent("MockAPI.sqlite")

        if let storeURL = storeURL {
            let directoryURL = storeURL.deletingLastPathComponent()
            try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

            // DEBUG: Log store location
            print("[CoreData] Store URL: \(storeURL.path)")
            print("[CoreData] Store exists: \(FileManager.default.fileExists(atPath: storeURL.path))")

            // WARNING: Only enable this for development/clear data
            // This will DELETE ALL DATA on every app launch!
            // Uncomment below to reset:
            // if FileManager.default.fileExists(atPath: storeURL.path) {
            //     print("[CoreData] Clearing existing store...")
            //     try? FileManager.default.removeItem(at: storeURL)
            // }

            let description = NSPersistentStoreDescription(url: storeURL)
            description.type = NSSQLiteStoreType
            persistentContainer.persistentStoreDescriptions = [description]
        }

        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed: \(error)")
            }
        }

        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Workspace Entity
        let workspace = NSEntityDescription()
        workspace.name = "Workspace"
        workspace.managedObjectClassName = "NSManagedObject"

        let wId = NSAttributeDescription()
        wId.name = "id"
        wId.attributeType = .UUIDAttributeType

        let wName = NSAttributeDescription()
        wName.name = "name"
        wName.attributeType = .stringAttributeType

        let wCreated = NSAttributeDescription()
        wCreated.name = "createdAt"
        wCreated.attributeType = .dateAttributeType

        let wUpdated = NSAttributeDescription()
        wUpdated.name = "updatedAt"
        wUpdated.attributeType = .dateAttributeType

        workspace.properties = [wId, wName, wCreated, wUpdated]

        // Route Entity
        let route = NSEntityDescription()
        route.name = "Route"
        route.managedObjectClassName = "NSManagedObject"

        let rId = NSAttributeDescription()
        rId.name = "id"
        rId.attributeType = .UUIDAttributeType

        let rWorkspaceId = NSAttributeDescription()
        rWorkspaceId.name = "workspaceId"
        rWorkspaceId.attributeType = .UUIDAttributeType

        let rName = NSAttributeDescription()
        rName.name = "name"
        rName.attributeType = .stringAttributeType

        let rMethod = NSAttributeDescription()
        rMethod.name = "method"
        rMethod.attributeType = .stringAttributeType

        let rPath = NSAttributeDescription()
        rPath.name = "path"
        rPath.attributeType = .stringAttributeType

        let rStatus = NSAttributeDescription()
        rStatus.name = "statusCode"
        rStatus.attributeType = .integer16AttributeType
        rStatus.defaultValue = 200

        let rBody = NSAttributeDescription()
        rBody.name = "responseBody"
        rBody.attributeType = .stringAttributeType

        let rHeaders = NSAttributeDescription()
        rHeaders.name = "responseHeaders"
        rHeaders.attributeType = .stringAttributeType

        let rEnabled = NSAttributeDescription()
        rEnabled.name = "isEnabled"
        rEnabled.attributeType = .booleanAttributeType
        rEnabled.defaultValue = true

        let rCreated = NSAttributeDescription()
        rCreated.name = "createdAt"
        rCreated.attributeType = .dateAttributeType

        let rUpdated = NSAttributeDescription()
        rUpdated.name = "updatedAt"
        rUpdated.attributeType = .dateAttributeType

        route.properties = [rId, rWorkspaceId, rName, rMethod, rPath, rStatus, rBody, rHeaders, rEnabled, rCreated, rUpdated]

        // MARK: - API Folder Entity (for REST API feature)
        let apiFolder = NSEntityDescription()
        apiFolder.name = "APIFolder"
        apiFolder.managedObjectClassName = "NSManagedObject"

        let fId = NSAttributeDescription()
        fId.name = "id"
        fId.attributeType = .UUIDAttributeType

        let fWorkspaceId = NSAttributeDescription()
        fWorkspaceId.name = "workspaceId"
        fWorkspaceId.attributeType = .UUIDAttributeType

        let fName = NSAttributeDescription()
        fName.name = "name"
        fName.attributeType = .stringAttributeType

        let fCreated = NSAttributeDescription()
        fCreated.name = "createdAt"
        fCreated.attributeType = .dateAttributeType

        let fUpdated = NSAttributeDescription()
        fUpdated.name = "updatedAt"
        fUpdated.attributeType = .dateAttributeType

        apiFolder.properties = [fId, fWorkspaceId, fName, fCreated, fUpdated]

        // MARK: - API Request Entity (for REST API feature)
        let apiRequest = NSEntityDescription()
        apiRequest.name = "APIRequest"
        apiRequest.managedObjectClassName = "NSManagedObject"

        let arId = NSAttributeDescription()
        arId.name = "id"
        arId.attributeType = .UUIDAttributeType

        let arFolderId = NSAttributeDescription()
        arFolderId.name = "folderId"
        arFolderId.attributeType = .UUIDAttributeType
        arFolderId.isOptional = true

        let arName = NSAttributeDescription()
        arName.name = "name"
        arName.attributeType = .stringAttributeType

        let arMethod = NSAttributeDescription()
        arMethod.name = "method"
        arMethod.attributeType = .stringAttributeType

        let arURL = NSAttributeDescription()
        arURL.name = "url"
        arURL.attributeType = .stringAttributeType

        let arCreated = NSAttributeDescription()
        arCreated.name = "createdAt"
        arCreated.attributeType = .dateAttributeType

        let arUpdated = NSAttributeDescription()
        arUpdated.name = "updatedAt"
        arUpdated.attributeType = .dateAttributeType

        apiRequest.properties = [arId, arFolderId, arName, arMethod, arURL, arCreated, arUpdated]

        model.entities = [workspace, route, apiFolder, apiRequest]
        return model
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}

// MARK: - Actor

private actor CoreDataActor {
    let stack = CoreDataStack.shared

    func fetchWorkspaces() async throws -> [MockWorkspace] {
        let context = stack.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Workspace")
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            let results = try context.fetch(request)
            print("[CoreData] Fetched \(results.count) workspaces")
            return results.map { obj in
                MockWorkspace(
                    id: obj.value(forKey: "id") as? UUID ?? UUID(),
                    name: obj.value(forKey: "name") as? String ?? "",
                    createdAt: obj.value(forKey: "createdAt") as? Date ?? Date(),
                    updatedAt: obj.value(forKey: "updatedAt") as? Date ?? Date()
                )
            }
        }
    }

    func saveWorkspace(_ workspace: MockWorkspace) async throws -> MockWorkspace {
        let context = stack.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Workspace")
            request.predicate = NSPredicate(format: "id == %@", workspace.id as CVarArg)

            let entity: NSManagedObject
            let isNew: Bool
            if let existing = try context.fetch(request).first {
                entity = existing
                isNew = false
            } else {
                entity = NSEntityDescription.insertNewObject(forEntityName: "Workspace", into: context)
                entity.setValue(workspace.id, forKey: "id")
                entity.setValue(workspace.createdAt, forKey: "createdAt")
                isNew = true
            }

            entity.setValue(workspace.name, forKey: "name")
            entity.setValue(Date(), forKey: "updatedAt")

            try context.save()
            print("[CoreData] \(isNew ? "Created" : "Updated") workspace: \(workspace.name) (\(workspace.id))")
            return workspace
        }
    }

    func deleteWorkspace(id: UUID) async throws {
        let context = stack.newBackgroundContext()
        try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Workspace")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try context.save()
                print("[CoreData] Deleted workspace: \(id)")
            } else {
                print("[CoreData] Workspace not found for deletion: \(id)")
            }
        }
    }

    func fetchRoutes(workspaceId: UUID?) async throws -> [MockRoute] {
        let context = stack.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Route")

            if let workspaceId = workspaceId {
                request.predicate = NSPredicate(format: "workspaceId == %@", workspaceId as CVarArg)
            }

            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

            let results = try context.fetch(request)
            print("[CoreData] Fetched \(results.count) routes" + (workspaceId != nil ? " for workspace \(workspaceId!)" : ""))
            return results.map { obj in
                let headersString = obj.value(forKey: "responseHeaders") as? String
                let headers: [String: String]
                if let data = headersString?.data(using: .utf8),
                   let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
                    headers = decoded
                } else {
                    headers = [:]
                }

                return MockRoute(
                    id: obj.value(forKey: "id") as? UUID ?? UUID(),
                    workspaceId: obj.value(forKey: "workspaceId") as? UUID,
                    name: obj.value(forKey: "name") as? String ?? "",
                    method: HTTPMethod(rawValue: obj.value(forKey: "method") as? String ?? "GET") ?? .get,
                    path: obj.value(forKey: "path") as? String ?? "",
                    statusCode: Int(obj.value(forKey: "statusCode") as? Int16 ?? 200),
                    responseHeaders: headers,
                    responseBody: obj.value(forKey: "responseBody") as? String ?? "",
                    isEnabled: obj.value(forKey: "isEnabled") as? Bool ?? true,
                    createdAt: obj.value(forKey: "createdAt") as? Date ?? Date(),
                    updatedAt: obj.value(forKey: "updatedAt") as? Date ?? Date()
                )
            }
        }
    }

    func saveRoute(_ route: MockRoute) async throws -> MockRoute {
        let context = stack.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Route")
            request.predicate = NSPredicate(format: "id == %@", route.id as CVarArg)

            let entity: NSManagedObject
            let isNew: Bool
            if let existing = try context.fetch(request).first {
                entity = existing
                isNew = false
            } else {
                entity = NSEntityDescription.insertNewObject(forEntityName: "Route", into: context)
                entity.setValue(route.id, forKey: "id")
                entity.setValue(route.createdAt, forKey: "createdAt")
                isNew = true
            }

            entity.setValue(route.workspaceId, forKey: "workspaceId")
            entity.setValue(route.name, forKey: "name")
            entity.setValue(route.method.rawValue, forKey: "method")
            entity.setValue(route.path, forKey: "path")
            entity.setValue(Int16(route.statusCode), forKey: "statusCode")
            entity.setValue(route.responseBody, forKey: "responseBody")

            if let headersData = try? JSONEncoder().encode(route.responseHeaders),
               let headersString = String(data: headersData, encoding: .utf8) {
                entity.setValue(headersString, forKey: "responseHeaders")
            }

            entity.setValue(route.isEnabled, forKey: "isEnabled")
            entity.setValue(Date(), forKey: "updatedAt")

            try context.save()
            print("[CoreData] \(isNew ? "Created" : "Updated") route: \(route.name) (\(route.method.rawValue) \(route.path))")
            return route
        }
    }

    func deleteRoute(id: UUID) async throws {
        let context = stack.newBackgroundContext()
        try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Route")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try context.save()
                print("[CoreData] Deleted route: \(id)")
            } else {
                print("[CoreData] Route not found for deletion: \(id)")
            }
        }
    }

    // MARK: - REST API Feature Methods

    func fetchAPIWorkspaces() async throws -> [Workspace] {
        let context = stack.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Workspace")
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

            let results = try context.fetch(request)
            print("[CoreData] Fetched \(results.count) API workspaces")

            return try results.map { obj in
                let workspaceId = obj.value(forKey: "id") as? UUID ?? UUID()

                // Fetch folders for this workspace
                let folderRequest = NSFetchRequest<NSManagedObject>(entityName: "APIFolder")
                folderRequest.predicate = NSPredicate(format: "workspaceId == %@", workspaceId as CVarArg)
                folderRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
                let folderResults = try context.fetch(folderRequest)

                let folders: [Folder] = try folderResults.map { folderObj in
                    let folderId = folderObj.value(forKey: "id") as? UUID ?? UUID()

                    // Fetch requests for this folder
                    let requestRequest = NSFetchRequest<NSManagedObject>(entityName: "APIRequest")
                    requestRequest.predicate = NSPredicate(format: "folderId == %@", folderId as CVarArg)
                    requestRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
                    let requestResults = try context.fetch(requestRequest)

                    let requests = requestResults.map { reqObj in
                        RequestItem(
                            id: reqObj.value(forKey: "id") as? UUID ?? UUID(),
                            name: reqObj.value(forKey: "name") as? String ?? "",
                            method: HTTPMethod(rawValue: reqObj.value(forKey: "method") as? String ?? "GET") ?? .get,
                            url: reqObj.value(forKey: "url") as? String ?? ""
                        )
                    }

                    return Folder(
                        id: folderId,
                        name: folderObj.value(forKey: "name") as? String ?? "",
                        requests: requests
                    )
                }

                // Fetch root requests (requests without folder)
                let rootRequestRequest = NSFetchRequest<NSManagedObject>(entityName: "APIRequest")
                rootRequestRequest.predicate = NSPredicate(format: "folderId == nil")
                rootRequestRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
                let rootRequestResults = try context.fetch(rootRequestRequest)

                let rootRequests = rootRequestResults.map { reqObj in
                    RequestItem(
                        id: reqObj.value(forKey: "id") as? UUID ?? UUID(),
                        name: reqObj.value(forKey: "name") as? String ?? "",
                        method: HTTPMethod(rawValue: reqObj.value(forKey: "method") as? String ?? "GET") ?? .get,
                        url: reqObj.value(forKey: "url") as? String ?? ""
                    )
                }

                return Workspace(
                    id: workspaceId,
                    name: obj.value(forKey: "name") as? String ?? "",
                    folders: folders,
                    requests: rootRequests
                )
            }
        }
    }

    func saveAPIWorkspace(_ workspace: Workspace) async throws -> Workspace {
        let context = stack.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Workspace")
            request.predicate = NSPredicate(format: "id == %@", workspace.id as CVarArg)

            let entity: NSManagedObject
            let isNew: Bool
            if let existing = try context.fetch(request).first {
                entity = existing
                isNew = false
            } else {
                entity = NSEntityDescription.insertNewObject(forEntityName: "Workspace", into: context)
                entity.setValue(workspace.id, forKey: "id")
                entity.setValue(Date(), forKey: "createdAt")
                isNew = true
            }

            entity.setValue(workspace.name, forKey: "name")
            entity.setValue(Date(), forKey: "updatedAt")

            try context.save()
            print("[CoreData] \(isNew ? "Created" : "Updated") API workspace: \(workspace.name)")
            return workspace
        }
    }

    func deleteAPIWorkspace(id: UUID) async throws {
        let context = stack.newBackgroundContext()
        try await context.perform {
            // Delete associated folders and requests first
            let folderRequest = NSFetchRequest<NSManagedObject>(entityName: "APIFolder")
            folderRequest.predicate = NSPredicate(format: "workspaceId == %@", id as CVarArg)
            let folders = try context.fetch(folderRequest)
            for folder in folders {
                context.delete(folder)
            }

            let requestRequest = NSFetchRequest<NSManagedObject>(entityName: "APIRequest")
            requestRequest.predicate = NSPredicate(format: "folderId == nil") // Root requests
            let requests = try context.fetch(requestRequest)
            for req in requests {
                context.delete(req)
            }

            // Delete workspace
            let workspaceRequest = NSFetchRequest<NSManagedObject>(entityName: "Workspace")
            workspaceRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            if let entity = try context.fetch(workspaceRequest).first {
                context.delete(entity)
                try context.save()
                print("[CoreData] Deleted API workspace: \(id)")
            }
        }
    }

    func fetchAPIFolders(workspaceId: UUID) async throws -> [Folder] {
        let context = stack.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "APIFolder")
            request.predicate = NSPredicate(format: "workspaceId == %@", workspaceId as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

            let results = try context.fetch(request)
            print("[CoreData] Fetched \(results.count) folders for workspace \(workspaceId)")

            return try results.map { obj in
                let folderId = obj.value(forKey: "id") as? UUID ?? UUID()

                // Fetch requests for this folder
                let requestRequest = NSFetchRequest<NSManagedObject>(entityName: "APIRequest")
                requestRequest.predicate = NSPredicate(format: "folderId == %@", folderId as CVarArg)
                requestRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
                let requestResults = try context.fetch(requestRequest)

                let requests = requestResults.map { reqObj in
                    RequestItem(
                        id: reqObj.value(forKey: "id") as? UUID ?? UUID(),
                        name: reqObj.value(forKey: "name") as? String ?? "",
                        method: HTTPMethod(rawValue: reqObj.value(forKey: "method") as? String ?? "GET") ?? .get,
                        url: reqObj.value(forKey: "url") as? String ?? ""
                    )
                }

                return Folder(
                    id: folderId,
                    name: obj.value(forKey: "name") as? String ?? "",
                    requests: requests
                )
            }
        }
    }

    func saveAPIFolder(_ folder: Folder, workspaceId: UUID) async throws -> Folder {
        let context = stack.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "APIFolder")
            request.predicate = NSPredicate(format: "id == %@", folder.id as CVarArg)

            let entity: NSManagedObject
            let isNew: Bool
            if let existing = try context.fetch(request).first {
                entity = existing
                isNew = false
            } else {
                entity = NSEntityDescription.insertNewObject(forEntityName: "APIFolder", into: context)
                entity.setValue(folder.id, forKey: "id")
                entity.setValue(Date(), forKey: "createdAt")
                isNew = true
            }

            entity.setValue(workspaceId, forKey: "workspaceId")
            entity.setValue(folder.name, forKey: "name")
            entity.setValue(Date(), forKey: "updatedAt")

            try context.save()
            print("[CoreData] \(isNew ? "Created" : "Updated") folder: \(folder.name)")
            return folder
        }
    }

    func deleteAPIFolder(id: UUID) async throws {
        let context = stack.newBackgroundContext()
        try await context.perform {
            // Delete associated requests first
            let requestRequest = NSFetchRequest<NSManagedObject>(entityName: "APIRequest")
            requestRequest.predicate = NSPredicate(format: "folderId == %@", id as CVarArg)
            let requests = try context.fetch(requestRequest)
            for req in requests {
                context.delete(req)
            }

            // Delete folder
            let folderRequest = NSFetchRequest<NSManagedObject>(entityName: "APIFolder")
            folderRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            if let entity = try context.fetch(folderRequest).first {
                context.delete(entity)
                try context.save()
                print("[CoreData] Deleted folder: \(id)")
            }
        }
    }

    func fetchAPIRequests(folderId: UUID?) async throws -> [RequestItem] {
        let context = stack.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "APIRequest")
            if let folderId = folderId {
                request.predicate = NSPredicate(format: "folderId == %@", folderId as CVarArg)
            } else {
                request.predicate = NSPredicate(format: "folderId == nil")
            }
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

            let results = try context.fetch(request)
            print("[CoreData] Fetched \(results.count) requests")

            return results.map { obj in
                RequestItem(
                    id: obj.value(forKey: "id") as? UUID ?? UUID(),
                    name: obj.value(forKey: "name") as? String ?? "",
                    method: HTTPMethod(rawValue: obj.value(forKey: "method") as? String ?? "GET") ?? .get,
                    url: obj.value(forKey: "url") as? String ?? ""
                )
            }
        }
    }

    func saveAPIRequest(_ requestItem: RequestItem, folderId: UUID?) async throws -> RequestItem {
        let context = stack.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "APIRequest")
            request.predicate = NSPredicate(format: "id == %@", requestItem.id as CVarArg)

            let entity: NSManagedObject
            let isNew: Bool
            if let existing = try context.fetch(request).first {
                entity = existing
                isNew = false
            } else {
                entity = NSEntityDescription.insertNewObject(forEntityName: "APIRequest", into: context)
                entity.setValue(requestItem.id, forKey: "id")
                entity.setValue(Date(), forKey: "createdAt")
                isNew = true
            }

            entity.setValue(folderId, forKey: "folderId")
            entity.setValue(requestItem.name, forKey: "name")
            entity.setValue(requestItem.method.rawValue, forKey: "method")
            entity.setValue(requestItem.url, forKey: "url")
            entity.setValue(Date(), forKey: "updatedAt")

            try context.save()
            print("[CoreData] \(isNew ? "Created" : "Updated") request: \(requestItem.name)")
            return requestItem
        }
    }

    func deleteAPIRequest(id: UUID) async throws {
        let context = stack.newBackgroundContext()
        try await context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "APIRequest")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try context.save()
                print("[CoreData] Deleted request: \(id)")
            }
        }
    }
}

private let actor = CoreDataActor()

// MARK: - Dependency

extension CoreDataClient: DependencyKey {
    public static let liveValue = CoreDataClient(
        fetchWorkspaces: { try await actor.fetchWorkspaces() },
        saveWorkspace: { try await actor.saveWorkspace($0) },
        deleteWorkspace: { try await actor.deleteWorkspace(id: $0) },
        fetchRoutes: { try await actor.fetchRoutes(workspaceId: $0) },
        saveRoute: { try await actor.saveRoute($0) },
        deleteRoute: { try await actor.deleteRoute(id: $0) },
        fetchAPIWorkspaces: { try await actor.fetchAPIWorkspaces() },
        saveAPIWorkspace: { try await actor.saveAPIWorkspace($0) },
        deleteAPIWorkspace: { try await actor.deleteAPIWorkspace(id: $0) },
        fetchAPIFolders: { try await actor.fetchAPIFolders(workspaceId: $0) },
        saveAPIFolder: { try await actor.saveAPIFolder($0, workspaceId: $1) },
        deleteAPIFolder: { try await actor.deleteAPIFolder(id: $0) },
        fetchAPIRequests: { try await actor.fetchAPIRequests(folderId: $0) },
        saveAPIRequest: { try await actor.saveAPIRequest($0, folderId: $1) },
        deleteAPIRequest: { try await actor.deleteAPIRequest(id: $0) }
    )

    public static let testValue = CoreDataClient(
        fetchWorkspaces: { [] },
        saveWorkspace: { $0 },
        deleteWorkspace: { _ in },
        fetchRoutes: { _ in [] },
        saveRoute: { $0 },
        deleteRoute: { _ in },
        fetchAPIWorkspaces: { [] },
        saveAPIWorkspace: { $0 },
        deleteAPIWorkspace: { _ in },
        fetchAPIFolders: { _ in [] },
        saveAPIFolder: { folder, _ in folder },
        deleteAPIFolder: { _ in },
        fetchAPIRequests: { _ in [] },
        saveAPIRequest: { request, _ in request },
        deleteAPIRequest: { _ in }
    )
}

extension DependencyValues {
    public var coreData: CoreDataClient {
        get { self[CoreDataClient.self] }
        set { self[CoreDataClient.self] = newValue }
    }
}
