//
//  HttpResponder.swift
//  BasicAsync
//
//  Created by Aaron Anthony on 2020-02-20.
//

import Foundation
import NIO

//FIXME: Naming
/// Any type that can respond to HTTP requests
protocol HTTPResponder
{
    func respond(to request: HTTPRequest) -> EventLoopFuture<HTTPResponse>
}
