
import NIO
import Foundation
import NIOHTTP1

struct HTTPRequest
{
    let eventLoop: EventLoop
    let head: HTTPRequestHead
    var bodyBuffer: ByteBuffer?
    
    init(eventLoop: EventLoop, head: HTTPRequestHead, bodyBuffer: ByteBuffer?) {
        self.eventLoop = eventLoop
        self.head = head
        self.bodyBuffer = bodyBuffer
    }
    
    //FIXME: Convert to method
    var body: HTTPBody? {
        guard let bodyBuffer = bodyBuffer else { return nil }
        return HTTPBody(buffer: bodyBuffer, mimeType: nil, allocator: ByteBufferAllocator()) //FIXME: no nil
    }
}
