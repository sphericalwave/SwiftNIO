
import NIO
import NIOHTTP1
import Foundation

public final class QuoteRepository
{
    private static let database = Database<Quote>()
    let eventLoop: EventLoop
    
    public init(for eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }
    
    func insert(quote: Quote) -> EventLoopFuture<Void> {
        let promise = eventLoop.newPromise(of: Void.self)
        QuoteRepository.database.add(entity: quote, completing: promise)  //FIXME: Encapsulation Violation
        return promise.futureResult
    }
    
    func allQuotes() -> EventLoopFuture<[Quote]> {
        let promise = eventLoop.newPromise(of: [Quote].self)
        QuoteRepository.database.allEntities(completing: promise)   //FIXME: Encapsulation Violation
        return promise.futureResult
    }
    
    func quote(id: Quote.Identifier) -> EventLoopFuture<Quote?> {
        let promise = eventLoop.newPromise(of: Quote?.self)
        QuoteRepository.database.entity(id: id, completing: promise)   //FIXME: Encapsulation Violation
        return promise.futureResult
    }
    
    func deleteQuote(id: Quote.Identifier) -> EventLoopFuture<Void> {
        let promise = eventLoop.newPromise(of: Void.self)
        QuoteRepository.database.deleteEntity(id: id, completing: promise)  //FIXME: Encapsulation Violation
        return promise.futureResult
    }
}
