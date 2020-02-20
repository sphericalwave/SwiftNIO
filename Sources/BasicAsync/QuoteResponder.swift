
import NIO
import NIOHTTP1
import Foundation

struct QuoteResponder: HTTPResponder    //FIXME: Naming, what is a QuoteResponder
{
    let quoteRepository = ThreadSpecificVariable<QuoteRepository>()
    
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
    
    
    func makeQuoteRepository(for request: HTTPRequest) -> QuoteRepository {
        if let existingQuoteRepository = quoteRepository.currentValue {
            return existingQuoteRepository
        }
        
        let newQuoteRepository = QuoteRepository(eventLoop: request.eventLoop, database: Database<Quote>())
        quoteRepository.currentValue = newQuoteRepository   //FIXME: Be Immutable
        return newQuoteRepository
    }
    
    private func listQuotes(for request: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        let repository = makeQuoteRepository(for: request)
        
        return repository.allQuotes().thenThrowing { quotes in
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
            
            return repository.insert(quote: quote).thenThrowing {
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
            
            return repository.quote(id: id).thenThrowing { quote in
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
            
            return repository.quote(id: id).then { quote -> EventLoopFuture<HTTPResponse> in
                guard let quote = quote else {
                    return request.eventLoop.newFailedFuture(error: QuoteAPIError.notFound)
                }
                
                return repository.deleteQuote(id: id).thenThrowing {
                    let body = try HTTPBody(json: quote, pretty: true)
                    return HTTPResponse(status: .ok, body: body)
                }
            }
    }
}
