import ComposableArchitecture
import CoreData
import Foundation
import SharedModels

// MARK: - Core Data Client

public struct CoreDataClient: Sendable {
    public var fetchWorkspaces: @Sendable () async throws -> [MockWorkspace]
    public var saveWorkspace: @Sendable (MockWorkspace) async throws -> MockWorkspace
    public var deleteWorkspace: @Sendable (UUID) async throws -> Void
    public var fetchRoutes: @Sendable (UUID?) async throws -> [MockRoute]
    public var saveRoute: @Sendable (MockRoute) async throws -> MockRoute
    public var deleteRoute: @Sendable (UUID) async throws -> Void

    public init(
        fetchWorkspaces: @Sendable @escaping () async throws -> [MockWorkspace],
        saveWorkspace: @Sendable @escaping (MockWorkspace) async throws -> MockWorkspace,
        deleteWorkspace: @Sendable @escaping (UUID) async throws -> Void,
        fetchRoutes: @Sendable @escaping (UUID?) async throws -> [MockRoute],
        saveRoute: @Sendable @escaping (MockRoute) async throws -> MockRoute,
        deleteRoute: @Sendable @escaping (UUID) async throws -> Void
    ) {
        self.fetchWorkspaces = fetchWorkspaces
        self.saveWorkspace = saveWorkspace
        self.deleteWorkspace = deleteWorkspace
        self.fetchRoutes = fetchRoutes
        self.saveRoute = saveRoute
        self.deleteRoute = deleteRoute
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

        model.entities = [workspace, route]
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
        deleteRoute: { try await actor.deleteRoute(id: $0) }
    )

    public static let testValue = CoreDataClient(
        fetchWorkspaces: { [] },
        saveWorkspace: { $0 },
        deleteWorkspace: { _ in },
        fetchRoutes: { _ in [] },
        saveRoute: { $0 },
        deleteRoute: { _ in }
    )
}

extension DependencyValues {
    public var coreData: CoreDataClient {
        get { self[CoreDataClient.self] }
        set { self[CoreDataClient.self] = newValue }
    }
}
