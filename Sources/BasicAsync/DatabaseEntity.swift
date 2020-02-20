//
//  DatabaseEntity.swift
//  BasicAsync
//
//  Created by Aaron Anthony on 2020-02-19.
//

import Foundation

public protocol DatabaseEntity  //FIXME: Replace DatabaseEntity with Identifiable
{
    associatedtype Identifier: Equatable
    var id: Identifier { get }
}
