//
//  DatabaseError.swift
//  BasicAsync
//
//  Created by Aaron Anthony on 2020-02-19.
//

import Foundation

enum DatabaseError: Error
{
    case entityAlreadyExists
    case entityNotFound
}
