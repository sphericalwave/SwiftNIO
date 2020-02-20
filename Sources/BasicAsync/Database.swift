
import NIO
import Foundation

class Database<Entity: DatabaseEntity>
{
    private let eventLoop: EventLoop
    private var entities = [Entity]()
    
    init() {
        self.eventLoop = MultiThreadedEventLoopGroup(numberOfThreads: 1).next() //FIXME: Hidden Dependency
    }
    
    func allEntities(completing promise: EventLoopPromise<[Entity]>) {
        eventLoop.execute { promise.succeed(result: self.entities) }
    }
    
    func deleteEntity(id: Entity.Identifier, completing promise: EventLoopPromise<Void>) {
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
    
    func entity(id: Entity.Identifier, completing promise: EventLoopPromise<Entity?>) {
        eventLoop.execute {
            for entity in self.entities where entity.id == id {
                promise.succeed(result: entity)
                return
            }
            promise.succeed(result: nil)
        }
    }
    
    func add(entity: Entity, completing promise: EventLoopPromise<Void>) {
        eventLoop.execute {
            for anEntity in self.entities {
                if anEntity.id == entity.id {
                    promise.fail(error: DatabaseError.entityAlreadyExists)
                    return
                }
            }
            self.entities.append(entity)
            promise.succeed(result: ())
        }
    }
}
