
import NIO
import NIOHTTP1
import Foundation

struct Quote: Codable, DatabaseEntity {
  let id: UUID
  let text: String
}

public final class QuoteRepository {

  private static let database = Database<Quote>()
  let eventLoop: EventLoop

  public init(for eventLoop: EventLoop) {
    self.eventLoop = eventLoop
  }

  func insert(_ quote: Quote) -> EventLoopFuture<Void> {
    let promise = eventLoop.newPromise(of: Void.self)
    QuoteRepository.database.addEntity(quote, completing: promise)
    return promise.futureResult
  }
  
  func fetchAllQuotes() -> EventLoopFuture<[Quote]> {
    let promise = eventLoop.newPromise(of: [Quote].self)
    QuoteRepository.database.getAllEntities(completing: promise)
    return promise.futureResult
  }
  
  func fetchOne(by id: Quote.Identifier) -> EventLoopFuture<Quote?> {
    let promise = eventLoop.newPromise(of: Quote?.self)
    QuoteRepository.database.findOne(by: id, completing: promise)
    return promise.futureResult
  }
  
  func deleteOne(by id: Quote.Identifier) -> EventLoopFuture<Void> {
    let promise = eventLoop.newPromise(of: Void.self)
    QuoteRepository.database.deleteOne(by: id, completing: promise)
    return promise.futureResult
  }
}
