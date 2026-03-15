import ComposableArchitecture
import CoreData
import Foundation
import SharedModels

// MARK: - Core Data Client

public struct CoreDataClient: Sendable {
    // Workspace operations
    public var fetchWorkspaces: @Sendable () async throws -> [MockWorkspace]
    public var saveWorkspace: @Sendable (MockWorkspace) async throws -> MockWorkspace
    public var deleteWorkspace: @Sendable (UUID) async throws -> Void

    // Route operations
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
        // Create managed object model programmatically
        let model = CoreDataStack.createManagedObjectModel()

        persistentContainer = NSPersistentContainer(name: "MockAPIModel", managedObjectModel: model)

        let storeURL = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("romeow")
            .appendingPathComponent("MockAPI.sqlite")

        if let storeURL = storeURL {
            // Ensure directory exists
            let directoryURL = storeURL.deletingLastPathComponent()
            try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

            // Remove old store if exists to avoid migration issues during development
            if FileManager.default.fileExists(atPath: storeURL.path) {
                try? FileManager.default.removeItem(at: storeURL)
            }

            let description = NSPersistentStoreDescription(url: storeURL)
            description.type = NSSQLiteStoreType
            persistentContainer.persistentStoreDescriptions = [description]
        }

        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }

        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func createManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // MockWorkspaceEntity
        let workspaceEntity = NSEntityDescription()
        workspaceEntity.name = "MockWorkspaceEntity"
        workspaceEntity.managedObjectClassName = "MockWorkspaceEntity"

        let workspaceId = NSAttributeDescription()
        workspaceId.name = "id"
        workspaceId.attributeType = .UUIDAttributeType

        let workspaceName = NSAttributeDescription()
        workspaceName.name = "name"
        workspaceName.attributeType = .stringAttributeType

        let workspaceCreatedAt = NSAttributeDescription()
        workspaceCreatedAt.name = "createdAt"
        workspaceCreatedAt.attributeType = .dateAttributeType

        let workspaceUpdatedAt = NSAttributeDescription()
        workspaceUpdatedAt.name = "updatedAt"
        workspaceUpdatedAt.attributeType = .dateAttributeType

        workspaceEntity.properties = [workspaceId, workspaceName, workspaceCreatedAt, workspaceUpdatedAt]

        // MockRouteEntity
        let routeEntity = NSEntityDescription()
        routeEntity.name = "MockRouteEntity"
        routeEntity.managedObjectClassName = "MockRouteEntity"

        let routeId = NSAttributeDescription()
        routeId.name = "id"
        routeId.attributeType = .UUIDAttributeType

        let routeWorkspaceId = NSAttributeDescription()
        routeWorkspaceId.name = "workspaceId"
        routeWorkspaceId.attributeType = .UUIDAttributeType
        routeWorkspaceId.isOptional = true

        let routeName = NSAttributeDescription()
        routeName.name = "name"
        routeName.attributeType = .stringAttributeType

        let routeMethod = NSAttributeDescription()
        routeMethod.name = "method"
        routeMethod.attributeType = .stringAttributeType

        let routePath = NSAttributeDescription()
        routePath.name = "path"
        routePath.attributeType = .stringAttributeType

        let routeStatusCode = NSAttributeDescription()
        routeStatusCode.name = "statusCode"
        routeStatusCode.attributeType = .integer16AttributeType
        routeStatusCode.defaultValue = 200

        let routeResponseBody = NSAttributeDescription()
        routeResponseBody.name = "responseBody"
        routeResponseBody.attributeType = .stringAttributeType
        routeResponseBody.isOptional = true

        let routeResponseHeaders = NSAttributeDescription()
        routeResponseHeaders.name = "responseHeaders"
        routeResponseHeaders.attributeType = .stringAttributeType
        routeResponseHeaders.isOptional = true

        let routeIsEnabled = NSAttributeDescription()
        routeIsEnabled.name = "isEnabled"
        routeIsEnabled.attributeType = .booleanAttributeType
        routeIsEnabled.defaultValue = true

        let routeCreatedAt = NSAttributeDescription()
        routeCreatedAt.name = "createdAt"
        routeCreatedAt.attributeType = .dateAttributeType

        let routeUpdatedAt = NSAttributeDescription()
        routeUpdatedAt.name = "updatedAt"
        routeUpdatedAt.attributeType = .dateAttributeType

        routeEntity.properties = [
            routeId, routeWorkspaceId, routeName, routeMethod, routePath,
            routeStatusCode, routeResponseBody, routeResponseHeaders,
            routeIsEnabled, routeCreatedAt, routeUpdatedAt
        ]

        // Relationships
        let workspaceRoutes = NSRelationshipDescription()
        workspaceRoutes.name = "routes"
        workspaceRoutes.destinationEntity = routeEntity
        workspaceRoutes.minCount = 0
        workspaceRoutes.maxCount = 0 // to-many
        workspaceRoutes.deleteRule = .cascadeDeleteRule

        let routeWorkspace = NSRelationshipDescription()
        routeWorkspace.name = "workspace"
        routeWorkspace.destinationEntity = workspaceEntity
        routeWorkspace.minCount = 0
        routeWorkspace.maxCount = 1 // to-one
        routeWorkspace.deleteRule = .nullifyDeleteRule

        workspaceRoutes.inverseRelationship = routeWorkspace
        routeWorkspace.inverseRelationship = workspaceRoutes

        workspaceEntity.properties.append(workspaceRoutes)
        routeEntity.properties.append(routeWorkspace)

        model.entities = [workspaceEntity, routeEntity]

        return model
    }

    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    @discardableResult
    func save(context: NSManagedObjectContext) -> Bool {
        guard context.hasChanges else { return true }
        do {
            try context.save()
            return true
        } catch {
            print("Core Data save error: \(error)")
            return false
        }
    }
}

// MARK: - NSManagedObject Subclasses

@objc(MockWorkspaceEntity)
private class MockWorkspaceEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var createdAt: Date?
    @NSManaged var updatedAt: Date?
    @NSManaged var routes: Set<MockRouteEntity>?

    func toModel() -> MockWorkspace {
        MockWorkspace(
            id: id ?? UUID(),
            name: name ?? "",
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
}

@objc(MockRouteEntity)
private class MockRouteEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var workspaceId: UUID?
    @NSManaged var name: String?
    @NSManaged var method: String?
    @NSManaged var path: String?
    @NSManaged var statusCode: Int16
    @NSManaged var responseBody: String?
    @NSManaged var responseHeaders: String?
    @NSManaged var isEnabled: Bool
    @NSManaged var createdAt: Date?
    @NSManaged var updatedAt: Date?
    @NSManaged var workspace: MockWorkspaceEntity?

    func toModel() -> MockRoute {
        let headers: [String: String]
        if let headersString = responseHeaders,
           let data = headersString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            headers = decoded
        } else {
            headers = [:]
        }

        return MockRoute(
            id: id ?? UUID(),
            workspaceId: workspaceId,
            name: name ?? "",
            method: HTTPMethod(rawValue: method ?? "GET") ?? .get,
            path: path ?? "",
            statusCode: Int(statusCode),
            responseHeaders: headers,
            responseBody: responseBody ?? "",
            isEnabled: isEnabled,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
}

// MARK: - Core Data Operations

private actor CoreDataActor {
    let stack: CoreDataStack

    init(stack: CoreDataStack = .shared) {
        self.stack = stack
    }

    func fetchWorkspaces() async throws -> [MockWorkspace] {
        let context = stack.backgroundContext
        return try await context.perform {
            let request = NSFetchRequest<MockWorkspaceEntity>(entityName: "MockWorkspaceEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            let entities = try context.fetch(request)
            return entities.map { $0.toModel() }
        }
    }

    func saveWorkspace(_ workspace: MockWorkspace) async throws -> MockWorkspace {
        let context = stack.backgroundContext
        return try await context.perform {
            let request = NSFetchRequest<MockWorkspaceEntity>(entityName: "MockWorkspaceEntity")
            request.predicate = NSPredicate(format: "id == %@", workspace.id as CVarArg)

            let entity: MockWorkspaceEntity
            if let existing = try context.fetch(request).first {
                entity = existing
            } else {
                entity = MockWorkspaceEntity(context: context)
                entity.id = workspace.id
                entity.createdAt = workspace.createdAt
            }

            entity.name = workspace.name
            entity.updatedAt = Date()

            guard self.stack.save(context: context) else {
                throw CoreDataError.saveFailed
            }

            return entity.toModel()
        }
    }

    func deleteWorkspace(id: UUID) async throws {
        let context = stack.backgroundContext
        try await context.perform {
            let request = NSFetchRequest<MockWorkspaceEntity>(entityName: "MockWorkspaceEntity")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            guard let entity = try context.fetch(request).first else {
                throw CoreDataError.notFound
            }

            context.delete(entity)

            guard self.stack.save(context: context) else {
                throw CoreDataError.saveFailed
            }
        }
    }

    func fetchRoutes(workspaceId: UUID?) async throws -> [MockRoute] {
        let context = stack.backgroundContext
        return try await context.perform {
            let request = NSFetchRequest<MockRouteEntity>(entityName: "MockRouteEntity")

            if let workspaceId = workspaceId {
                request.predicate = NSPredicate(format: "workspaceId == %@", workspaceId as CVarArg)
            }

            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            let entities = try context.fetch(request)
            return entities.map { $0.toModel() }
        }
    }

    func saveRoute(_ route: MockRoute) async throws -> MockRoute {
        let context = stack.backgroundContext
        return try await context.perform {
            let request = NSFetchRequest<MockRouteEntity>(entityName: "MockRouteEntity")
            request.predicate = NSPredicate(format: "id == %@", route.id as CVarArg)

            let entity: MockRouteEntity
            if let existing = try context.fetch(request).first {
                entity = existing
            } else {
                entity = MockRouteEntity(context: context)
                entity.id = route.id
                entity.createdAt = route.createdAt
            }

            entity.workspaceId = route.workspaceId
            entity.name = route.name
            entity.path = route.path
            entity.method = route.method.rawValue
            entity.statusCode = Int16(route.statusCode)
            entity.responseBody = route.responseBody
            entity.responseHeaders = self.encodeHeaders(route.responseHeaders)
            entity.isEnabled = route.isEnabled
            entity.updatedAt = Date()

            // Link to workspace if exists
            if let workspaceId = route.workspaceId {
                let workspaceRequest = NSFetchRequest<MockWorkspaceEntity>(entityName: "MockWorkspaceEntity")
                workspaceRequest.predicate = NSPredicate(format: "id == %@", workspaceId as CVarArg)
                if let workspace = try context.fetch(workspaceRequest).first {
                    entity.workspace = workspace
                }
            }

            guard self.stack.save(context: context) else {
                throw CoreDataError.saveFailed
            }

            return entity.toModel()
        }
    }

    func deleteRoute(id: UUID) async throws {
        let context = stack.backgroundContext
        try await context.perform {
            let request = NSFetchRequest<MockRouteEntity>(entityName: "MockRouteEntity")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            guard let entity = try context.fetch(request).first else {
                throw CoreDataError.notFound
            }

            context.delete(entity)

            guard self.stack.save(context: context) else {
                throw CoreDataError.saveFailed
            }
        }
    }

    private func encodeHeaders(_ headers: [String: String]) -> String? {
        guard let data = try? JSONEncoder().encode(headers),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }
}

private enum CoreDataError: Error {
    case saveFailed
    case notFound
}

private let coreDataActor = CoreDataActor()

// MARK: - DependencyKey

extension CoreDataClient: DependencyKey {
    public static let liveValue = CoreDataClient(
        fetchWorkspaces: {
            try await coreDataActor.fetchWorkspaces()
        },
        saveWorkspace: { workspace in
            try await coreDataActor.saveWorkspace(workspace)
        },
        deleteWorkspace: { id in
            try await coreDataActor.deleteWorkspace(id: id)
        },
        fetchRoutes: { workspaceId in
            try await coreDataActor.fetchRoutes(workspaceId: workspaceId)
        },
        saveRoute: { route in
            try await coreDataActor.saveRoute(route)
        },
        deleteRoute: { id in
            try await coreDataActor.deleteRoute(id: id)
        }
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
