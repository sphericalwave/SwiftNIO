//
//  HttpResponder.swift
//  BasicAsync
//
//  Created by Aaron Anthony on 2020-02-20.
//

import Foundation
import NIO

//FIXME: Naming
protocol HTTPResponder  /// Any type that can respond to HTTP requests
{
    func respond(to request: HTTPRequest) -> EventLoopFuture<HTTPResponse>
}
