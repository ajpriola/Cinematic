//
//  CacheTests.swift
//  Cinematic
//
//  Created by AJ Priola on 2/25/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import XCTest
@testable import Cinematic

class CacheTests: XCTestCase {
    
    var cache: MovieCache!
    
    override func setUp() {
        super.setUp()
        
        MovieCache.delete(named: "test")
        
        cache = MovieCache(named: "test")
    }
    
    override func tearDown() {
        
        MovieCache.delete(named: "test")
        
        super.tearDown()
    }
    
    func testExists() {
    
        let exists = MovieCache.exists(named: "test")
        
        XCTAssert(exists)
    
    }
    
    func testClear() {
        
        let movie = Movie()
        
        cache.cache(movie)
        
        cache.clear()
        
        let movies = cache.fetch().value
        
        XCTAssertNotNil(movies)
        
        XCTAssert(movies!.isEmpty)
        
    }
    
    func testDelete() {
        
        _ = MovieCache(named: "test")
        
        MovieCache.delete(named: "test")
        
        let exists = MovieCache.exists(named: "test")
        
        XCTAssert(!exists)
        
    }
    
    func testCacheAndFetch() {
        
        let movie = Movie()
        
        cache.cache(movie)
        
        let fetched = cache.fetch(movie.id).value
        
        XCTAssertNotNil(fetched)
        
        XCTAssert(fetched!.id == movie.id)
        
    }
    
}
