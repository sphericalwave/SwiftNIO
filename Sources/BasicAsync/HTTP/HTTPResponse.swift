//
//  HttpResponse.swift
//  BasicAsync
//
//  Created by Aaron Anthony on 2020-02-20.
//

import Foundation
import NIOHTTP1

struct HTTPResponse
{
    let head: HTTPResponseHead      // The success or failure status and HTTP headers
    let body: HTTPBody?             //FIXME: Optional let WTF?
    
    /// The body's content-length and mimeType will overwrite those that may be present in the header
    init(status: HTTPResponseStatus, headers: HTTPHeaders = HTTPHeaders(), body: HTTPBody?) {
        self.head = HTTPResponseHead(version: HTTPVersion(major: 1, minor: 1), status: status, headers: headers)
        self.body = body
    }
}
