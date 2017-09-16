//
//  MovieTests.swift
//  Cinematic
//
//  Created by AJ Priola on 2/25/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import XCTest
@testable import Cinematic

class MovieTests: XCTestCase {
    
    var movie: Movie!
    
    override func setUp() {
        movie = Movie()
        
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testBookmark() {
        movie.unbookmark()
        
        movie.bookmark()
        
        XCTAssert(movie.bookmarked)
    }
    
    func testUnbookmark() {
        movie.bookmark()
        
        movie.unbookmark()
        
        XCTAssert(!movie.bookmarked)
    }
    
    func testUrlForPosterSize() {
        let tiny = URL(string: "https://image.tmdb.org/t/p/w92/nil.jpg")
        
        let small = URL(string: "https://image.tmdb.org/t/p/w154/nil.jpg")
        
        let medium = URL(string: "https://image.tmdb.org/t/p/w500/nil.jpg")
        
        let large = URL(string: "https://image.tmdb.org/t/p/w780/nil.jpg")
        
        let original = URL(string: "https://image.tmdb.org/t/p/original/nil.jpg")
        
        XCTAssert(movie.urlForPoster(ofSize: .tiny) == tiny)
        XCTAssert(movie.urlForPoster(ofSize: .small) == small)
        XCTAssert(movie.urlForPoster(ofSize: .medium) == medium)
        XCTAssert(movie.urlForPoster(ofSize: .large) == large)
        XCTAssert(movie.urlForPoster(ofSize: .original) == original)
    }
    
}
