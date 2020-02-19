
import NIO
import Foundation

/// Entities that can be stored in the mock database provided below
public protocol DatabaseEntity
{
    associatedtype Identifier: Equatable
    var id: Identifier { get }   /// Used for `find` and `delete` operations
}

/// A mock database generic to a single DatabaseEntity type
///
/// All results are returned by completing the provided promise
/// This ensures that the results are passed to the EventLoop the EventLoopPromise originated from
public final class Database<Entity: DatabaseEntity>
{
    
    /// Creates a new mock database for storing the generic `Entity`
    public init() {
        eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1).next()
    }
    
    /// The database has it's own eventloop because it's shared between many threads
    ///
    /// To ensure all entity access is thread safe, all operations happen on this EventLoop
    private let eventLoop: EventLoop
    
    private var entities = [Entity]()   /// The internal storage of the mock database
    
    /// Lists all entities in the database and returns them by completing the promise with this result
    public func getAllEntities(completing promise: EventLoopPromise<[Entity]>) {
        eventLoop.execute {
            promise.succeed(result: self.entities)
        }
    }
    
    /// Deletes a single entity
    ///
    /// Succeeds when the deletion was successful and fails if no entity was found to remove
    public func deleteOne(by id: Entity.Identifier, completing promise: EventLoopPromise<Void>) {
        eventLoop.execute {
            for i in 0..<self.entities.count {
                if self.entities[i].id == id {
                    self.entities.remove(at: i)
                    promise.succeed(result: ())
                    return
                }
            }
            
            promise.fail(error: DatabaseError.entityNotFound)
        }
    }
    
    /// Finds a single entity by it's identifier and completed the promise with the result
    ///
    /// The promise will be completed with `nil` if the entity was not found
    public func findOne(by id: Entity.Identifier, completing promise: EventLoopPromise<Entity?>) {
        eventLoop.execute {
            for entity in self.entities where entity.id == id {
                promise.succeed(result: entity)
                return
            }
            
            promise.succeed(result: nil)
        }
    }
    
    /// Adds an entity to the database
    ///
    /// This operation can fail if an entity with this ID already exists
    public func addEntity(_ newEntity: Entity, completing promise: EventLoopPromise<Void>) {
        eventLoop.execute {
            for entity in self.entities {
                if entity.id == newEntity.id {
                    promise.fail(error: DatabaseError.entityAlreadyExists)
                    return
                }
            }
            
            self.entities.append(newEntity)
            promise.succeed(result: ())
        }
    }
}

/// The databsae can fail with these status codes
///
/// Most databases will have too many errors to sum up simply in an enum
/// and are implemented outside of the application's access
fileprivate enum DatabaseError: Error
{
    case entityAlreadyExists
    case entityNotFound
}
