//
//  HttpBody.swift
//  BasicAsync
//
//  Created by Aaron Anthony on 2020-02-20.
//

import Foundation
import NIO

struct HTTPBody
{
    let allocator: ByteBufferAllocator
    let buffer: ByteBuffer
    let mimeType: String?       //FIXME: Remove bcs Unused? // Used to set the `content-type` header when sending back a response

    //FIXME: convert to method?
    // Reads the Data from this body
    var data: Data {
        return buffer.withUnsafeReadableBytes { buffer -> Data in
            let buffer = buffer.bindMemory(to: UInt8.self)
            return Data.init(buffer: buffer)
        }
    }
    
    // Creates a new body from a binary `NIO.ByteBuffer`
    init(buffer: ByteBuffer, mimeType: String?, allocator: ByteBufferAllocator) {
        self.buffer = buffer
        self.mimeType = mimeType
        self.allocator = allocator  //FIXME: Naming
    }
    
    // Creates a new text/plain body containing the text
    init(text: String, allocator: ByteBufferAllocator) {
        var buffer = allocator.buffer(capacity: text.utf8.count)    //FIXME: Hidden Dependency
        buffer.write(string: text)
        self.buffer = buffer
        self.mimeType = "text/plain"
        self.allocator = allocator  //FIXME: Naming
    }
    
    // Creates a new body from a binary `Foundation.Data`
    init(data: Data, mimeType: String?, allocator: ByteBufferAllocator) {
        var buffer = allocator.buffer(capacity: data.count)     //FIXME: Hidden Dependency
        buffer.write(bytes: data)
        self.buffer = buffer
        self.mimeType = mimeType
        self.allocator = allocator  //FIXME: Naming
    }
    
    // Encodes an object to JSON with optional pretty printing as a response
    init<E: Encodable>(json: E, pretty: Bool = false, allocator: ByteBufferAllocator) throws {
        let encoder = JSONEncoder()
        if pretty { encoder.outputFormatting = .prettyPrinted }
        let data = try encoder.encode(json)
        self.init(data: data, mimeType: "application/json", allocator: allocator)
    }
    
    // The same as the `text` initializer which allows this HTTPBody to be initialized from a String literal
    init(stringLiteral value: String, allocator: ByteBufferAllocator) {
        self.init(text: value, allocator: allocator)
    }
    
    // Decodes the body as JSON into the provided Decodable type
    func decodeJSON<D: Decodable>(as type: D.Type) throws -> D {
        return try JSONDecoder().decode(type, from: data)
    }
}
