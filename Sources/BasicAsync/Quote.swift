//
//  Quote.swift
//  BasicAsync
//
//  Created by Aaron Anthony on 2020-02-20.
//

import Foundation

struct Quote: Codable, DatabaseEntity //FIXME: Replace DatabaseEntity with Identifiable
{
    let id: UUID
    let text: String
}
