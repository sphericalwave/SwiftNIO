
import NIO
import NIOHTTP1

let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

let bootstrap = ServerBootstrap(group: group)
    // Specifies that we can have 256 TCP sockets waiting to be accepted for processing at a given time
    .serverChannelOption(ChannelOptions.backlog, value: 256)
    // Allows reusing the IP address and port so that multiple threads can receive clients
    .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
    
    // Sets up the HTTP parser and handler on the SwiftNIO channel
    .childChannelInitializer { channel in
        channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true).then {
            channel.pipeline.add(handler: HTTPHandler(responder: QuoteResponder()))
        }
}

// The host and port to which the webserver will bind
// ::1 can usually be accessed as `localhost`
// The difference is that `::1` is also available from other computers
let host = "::1"
let port = 8080

let serverChannel = try bootstrap.bind(host: host, port: port).wait()

guard serverChannel.localAddress != nil else {
    fatalError("Unable to bind to \(host) at port \(port)")
}

print("Server started and listening")

try serverChannel.closeFuture.wait()
