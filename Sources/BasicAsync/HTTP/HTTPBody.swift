//
//  HttpBody.swift
//  BasicAsync
//
//  Created by Aaron Anthony on 2020-02-20.
//

import Foundation
import NIO

struct HTTPBody: ExpressibleByStringLiteral
{
    static let allocator = ByteBufferAllocator()    //FIXME: Static / Hidden Dependency
    internal let buffer: ByteBuffer     // The binary data in this body //FIXME: internal?
    let mimeType: String?        // Used to set the `content-type` header when sending back a response

    //FIXME: convert to method?
    // Reads the Data from this body
    var data: Data {
        return buffer.withUnsafeReadableBytes { buffer -> Data in
            let buffer = buffer.bindMemory(to: UInt8.self)
            return Data.init(buffer: buffer)
        }
    }
    
    // Creates a new body from a binary `NIO.ByteBuffer`
    init(buffer: ByteBuffer, mimeType: String? = nil) {
        self.buffer = buffer
        self.mimeType = mimeType
    }
    
    // Creates a new text/plain body containing the text
    init(text: String) {
        var buffer = HTTPBody.allocator.buffer(capacity: text.utf8.count)
        buffer.write(string: text)
        self.buffer = buffer
        self.mimeType = "text/plain"
    }
    
    // Creates a new body from a binary `Foundation.Data`
    init(data: Data, mimeType: String? = nil) {
        var buffer = HTTPBody.allocator.buffer(capacity: data.count)
        buffer.write(bytes: data)
        self.buffer = buffer
        self.mimeType = mimeType
    }
    
    // Encodes an object to JSON with optional pretty printing as a response
    init<E: Encodable>(json: E, pretty: Bool = false) throws {
        let encoder = JSONEncoder()
        if pretty { encoder.outputFormatting = .prettyPrinted }
        let data = try encoder.encode(json)
        self.init(data: data, mimeType: "application/json")
    }
    
    // The same as the `text` initializer which allows this HTTPBody to be initialized from a String literal
    init(stringLiteral value: String) {
        self.init(text: value)
    }
    
    // Decodes the body as JSON into the provided Decodable type
    func decodeJSON<D: Decodable>(as type: D.Type) throws -> D {
        return try JSONDecoder().decode(type, from: data)
    }
}
