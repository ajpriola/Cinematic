//
//  Searching.swift
//  TMDB
//
//  Created by AJ Priola on 2/20/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import Foundation

protocol Searching {
    
    associatedtype ResultType
    associatedtype QueryType
    
    typealias ResultClosure = (Result<[ResultType]>) -> Void
    
    static func search(_ query: QueryType, _ closure: @escaping ResultClosure)
    
}
