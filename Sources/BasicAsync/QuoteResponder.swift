
import NIO
import NIOHTTP1
import Foundation

struct QuoteResponder: HTTPResponder {

  func respond(to request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
    switch request.head.method {
    case .GET:
      guard request.head.uri != "/" else {
        return listQuotes(for: request)
      }
      
      let components = request.head.uri.split(separator: "/", maxSplits: .max, omittingEmptySubsequences: true)
      
      guard components.count == 1,
            let component = components.first else {
        return request.eventLoop.newFailedFuture(error: QuoteAPIError.notFound)
      }
      
      let id = String(component)
      return getQuote(by: id, for: request)
    case .POST:
      return createQuote(from: request)
    case .DELETE:
      let components = request.head.uri.split(separator: "/", maxSplits: .max, omittingEmptySubsequences: true)
      
      guard components.count == 1,
        let component = components.first else {
          return request.eventLoop.newFailedFuture(error: QuoteAPIError.notFound)
      }
      
      let id = String(component)
      return deleteQuote(by: id, for: request)
    default:
      let notFound = HTTPResponse(status: .notFound, body: HTTPBody(text: "Not found"))
      return request.eventLoop.newSucceededFuture(result: notFound)
    }
  }
  
  let quoteRepository = ThreadSpecificVariable<QuoteRepository>()
  
  func makeQuoteRepository(for request: HTTPRequest) -> QuoteRepository {
    if let existingQuoteRepository = quoteRepository.currentValue {
      return existingQuoteRepository
    }
    
    let newQuoteRepository = QuoteRepository(for: request.eventLoop)
    quoteRepository.currentValue = newQuoteRepository
    return newQuoteRepository
  }
  
  private func listQuotes(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
    let repository = makeQuoteRepository(for: request)
    
    return repository.fetchAllQuotes().thenThrowing { quotes in
      let body = try HTTPBody(json: quotes, pretty: true)
      return HTTPResponse(status: .ok, body: body)
    }
  }
  
  private func createQuote(from request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
    guard let body = request.body else {
      return request.eventLoop.newFailedFuture(error: QuoteAPIError.badRequest)
    }
    
    do {
      let quoteRequest = try body.decodeJSON(as: QuoteRequest.self)
      let quote = Quote(id: UUID(), text: quoteRequest.text)
      
      let repository = makeQuoteRepository(for: request)
      
      return repository.insert(quote).thenThrowing {
        let body = try HTTPBody(json: quote, pretty: true)
        return HTTPResponse(status: .ok, body: body)
      }
    } catch {
      return request.eventLoop.newFailedFuture(error: error)
    }
  }
  
  private func getQuote(by id: String, for request: HTTPRequest)
    -> EventLoopFuture<HTTPResponse> {
      guard let id = UUID(uuidString: id) else {
        return request.eventLoop.newFailedFuture(error: QuoteAPIError.invalidIdentifier)
      }
      
      let repository = makeQuoteRepository(for: request)
      
      return repository.fetchOne(by: id).thenThrowing { quote in
        guard let quote = quote else {
          throw QuoteAPIError.notFound
        }
        
        let body = try HTTPBody(json: quote, pretty: true)
        return HTTPResponse(status: .ok, body: body)
      }
  }
  
  private func deleteQuote(by id: String, for request: HTTPRequest)
    -> EventLoopFuture<HTTPResponse> {
      guard let id = UUID(uuidString: id) else {
        return request.eventLoop.newFailedFuture(error: QuoteAPIError.invalidIdentifier)
      }
      
      let repository = makeQuoteRepository(for: request)
      
      return repository.fetchOne(by: id).then { quote -> EventLoopFuture<HTTPResponse> in
        guard let quote = quote else {
          return request.eventLoop.newFailedFuture(error: QuoteAPIError.notFound)
        }
        
        return repository.deleteOne(by: id).thenThrowing {
          let body = try HTTPBody(json: quote, pretty: true)
          return HTTPResponse(status: .ok, body: body)
        }
      }
  }
}

enum QuoteAPIError: Error {
  case notFound, badRequest, invalidIdentifier
}

struct QuoteRequest: Codable {
  let text: String
}
