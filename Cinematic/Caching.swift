//
//  Caching.swift
//  TMDB
//
//  Created by AJ Priola on 2/20/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import Foundation

protocol Caching {
    
    associatedtype ValueType: NSCoding
    associatedtype KeyType: Hashable
    
    static var shared: Self { get }
    
    func cache(_ object: ValueType)
    
    func remove(_ key: KeyType) -> Result<ValueType>
    
    func fetch(_ key: KeyType) -> Result<ValueType>
    
    func fetch() -> Result<[ValueType]>
    
    func contains(_ key: KeyType) -> Bool

    func clear()
    
    static func exists(named: String) -> Bool
    
    static func delete(named: String)
}
