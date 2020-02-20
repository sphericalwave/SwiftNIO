
import NIO
import NIOHTTP1
import Foundation

class QuoteRepository
{
    let database: Database<Quote>
    let eventLoop: EventLoop
    
    public init(eventLoop: EventLoop, database: Database<Quote>) {
        self.eventLoop = eventLoop
        self.database = database
    }
    
    func insert(quote: Quote) -> EventLoopFuture<Void> {
        let promise = eventLoop.newPromise(of: Void.self)
        database.add(entity: quote, completing: promise)  //FIXME: Encapsulation Violation
        return promise.futureResult
    }
    
    func allQuotes() -> EventLoopFuture<[Quote]> {
        let promise = eventLoop.newPromise(of: [Quote].self)
        database.allEntities(completing: promise)   //FIXME: Encapsulation Violation
        return promise.futureResult
    }
    
    func quote(id: Quote.Identifier) -> EventLoopFuture<Quote?> {
        let promise = eventLoop.newPromise(of: Quote?.self)
        database.entity(id: id, completing: promise)   //FIXME: Encapsulation Violation
        return promise.futureResult
    }
    
    func deleteQuote(id: Quote.Identifier) -> EventLoopFuture<Void> {
        let promise = eventLoop.newPromise(of: Void.self)
        database.deleteEntity(id: id, completing: promise)  //FIXME: Encapsulation Violation
        return promise.futureResult
    }
}
