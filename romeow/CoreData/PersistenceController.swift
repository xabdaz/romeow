import CoreData
import SharedModels

/// Core Data stack manager untuk romeow app
public final class PersistenceController: @unchecked Sendable {
    public static let shared = PersistenceController()

    public let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MockAPIModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading Core Data stores: \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// Preview instance untuk SwiftUI previews
    public static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()

    /// Background context untuk async operations
    public var backgroundContext: NSManagedObjectContext {
        return container.newBackgroundContext()
    }

    /// Save context dengan error handling
    @discardableResult
    public func save(context: NSManagedObjectContext) -> Bool {
        guard context.hasChanges else { return true }

        do {
            try context.save()
            return true
        } catch {
            print("Core Data save error: \(error)")
            return false
        }
    }

    // MARK: - Workspace Operations

    public func fetchWorkspaces() async throws -> [MockWorkspace] {
        let context = backgroundContext

        return try await context.perform {
            let request = MockWorkspaceEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \MockWorkspaceEntity.createdAt, ascending: false)]

            let entities = try context.fetch(request)
            return entities.map { $0.toModel() }
        }
    }

    public func saveWorkspace(_ workspace: MockWorkspace) async throws -> MockWorkspace {
        let context = backgroundContext

        return try await context.perform {
            let entity: MockWorkspaceEntity

            // Check if exists
            let request = MockWorkspaceEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", workspace.id as CVarArg)

            if let existing = try context.fetch(request).first {
                entity = existing
                entity.updatedAt = Date()
            } else {
                entity = MockWorkspaceEntity(context: context)
                entity.id = workspace.id
                entity.createdAt = workspace.createdAt
            }

            entity.name = workspace.name
            entity.updatedAt = Date()

            guard self.save(context: context) else {
                throw PersistenceError.saveFailed
            }

            return entity.toModel()
        }
    }

    public func deleteWorkspace(id: UUID) async throws {
        let context = backgroundContext

        try await context.perform {
            let request = MockWorkspaceEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            guard let entity = try context.fetch(request).first else {
                throw PersistenceError.notFound
            }

            context.delete(entity)

            guard self.save(context: context) else {
                throw PersistenceError.saveFailed
            }
        }
    }

    // MARK: - Route Operations

    public func fetchRoutes(workspaceId: UUID? = nil) async throws -> [MockRoute] {
        let context = backgroundContext

        return try await context.perform {
            let request = MockRouteEntity.fetchRequest()

            if let workspaceId = workspaceId {
                request.predicate = NSPredicate(format: "workspaceId == %@", workspaceId as CVarArg)
            }

            request.sortDescriptors = [NSSortDescriptor(keyPath: \MockRouteEntity.createdAt, ascending: false)]

            let entities = try context.fetch(request)
            return entities.map { $0.toModel() }
        }
    }

    public func saveRoute(_ route: MockRoute) async throws -> MockRoute {
        let context = backgroundContext

        return try await context.perform {
            let entity: MockRouteEntity

            // Check if exists
            let request = MockRouteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", route.id as CVarArg)

            if let existing = try context.fetch(request).first {
                entity = existing
            } else {
                entity = MockRouteEntity(context: context)
                entity.id = route.id
                entity.createdAt = route.createdAt
            }

            // Update fields
            entity.workspaceId = route.workspaceId
            entity.name = route.name
            entity.path = route.path
            entity.method = route.method.rawValue
            entity.statusCode = Int16(route.statusCode)
            entity.responseBody = route.responseBody
            entity.responseHeaders = self.encodeHeaders(route.responseHeaders)
            entity.isEnabled = route.isEnabled
            entity.updatedAt = Date()

            // Link to workspace if workspaceId exists
            if let workspaceId = route.workspaceId {
                let workspaceRequest = MockWorkspaceEntity.fetchRequest()
                workspaceRequest.predicate = NSPredicate(format: "id == %@", workspaceId as CVarArg)
                if let workspace = try context.fetch(workspaceRequest).first {
                    entity.workspace = workspace
                }
            }

            guard self.save(context: context) else {
                throw PersistenceError.saveFailed
            }

            return entity.toModel()
        }
    }

    public func deleteRoute(id: UUID) async throws {
        let context = backgroundContext

        try await context.perform {
            let request = MockRouteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

            guard let entity = try context.fetch(request).first else {
                throw PersistenceError.notFound
            }

            context.delete(entity)

            guard self.save(context: context) else {
                throw PersistenceError.saveFailed
            }
        }
    }

    // MARK: - Helpers

    private func encodeHeaders(_ headers: [String: String]) -> String? {
        guard let data = try? JSONEncoder().encode(headers),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }
}

// MARK: - Errors

public enum PersistenceError: Error, LocalizedError {
    case saveFailed
    case notFound
    case decodeFailed

    public var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save data"
        case .notFound:
            return "Item not found"
        case .decodeFailed:
            return "Failed to decode data"
        }
    }
}

// MARK: - Entity Extensions

extension MockWorkspaceEntity {
    func toModel() -> MockWorkspace {
        MockWorkspace(
            id: id ?? UUID(),
            name: name ?? "",
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
}

extension MockRouteEntity {
    func toModel() -> MockRoute {
        MockRoute(
            id: id ?? UUID(),
            workspaceId: workspaceId,
            name: name ?? "",
            method: HTTPMethod(rawValue: method ?? "GET") ?? .get,
            path: path ?? "",
            statusCode: Int(statusCode),
            responseHeaders: decodeHeaders() ?? [:],
            responseBody: responseBody ?? "",
            isEnabled: isEnabled,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }

    private func decodeHeaders() -> [String: String]? {
        guard let headersString = responseHeaders,
              let data = headersString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode([String: String].self, from: data)
    }
}
