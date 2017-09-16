//
//  Bookmark.swift
//  TMDB
//
//  Created by AJ Priola on 2/20/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import Foundation

final class MovieCache: Caching {
    
    typealias ValueType = Movie
    typealias KeyType = Int
    
    static let shared: MovieCache = MovieCache(named: "movies")
    
    private(set) var items: [Movie] = []
    
    private let directory: URL
    
    let name: String
    
    init(named name: String) {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first else {
            fatalError("Unable to access documents directory!")
        }
        
        self.name = name
        
        directory = documents.appendingPathComponent(name, isDirectory: true)
        
        if !MovieCache.exists(named: name) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("Unable to create '\(name)' folder!")
            }
        }
    }
    
    func cache(_ object: Movie) {
        
        let hashed = object.id.hashValue
        
        let url = directory.appendingPathComponent("\(hashed).dat")
        
        NSKeyedArchiver.archiveRootObject(object, toFile: url.path)
    }
    
    func remove(_ key: Int) -> Result<Movie> {
        
        let hashed = key.hashValue
        
        let url = directory.appendingPathComponent("\(hashed).dat")
        
        let result = fetch(key)
        
        do {
            try FileManager.default.removeItem(at: url)
            
            return Result(value: result.value, error: nil)
        } catch {
            return Result(value: nil, error: error)
        }
    }
    
    func fetch(_ key: Int) -> Result<Movie> {
        
        let hashed = key.hashValue
        
        let url = directory.appendingPathComponent("\(hashed).dat")
        
        let movie = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? Movie
        
        return Result(value: movie, error: movie == nil ? Errors.fetchError : nil)
    }
    
    func fetch() -> Result<[Movie]> {
        
        guard let files = FileManager.default.enumerator(atPath: directory.path)?.allObjects as? [String] else {
            return Result(value: nil, error: Errors.fetchError)
        }
        
        let movies = files.flatMap { (path) -> Movie? in
            let url = directory.appendingPathComponent(path)
            let movie = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? Movie
            
            return movie
        }.sorted { (first, second) -> Bool in
            return first.title.compare(second.title) == ComparisonResult.orderedAscending
        }
        
        
        
        return Result(value: movies, error: nil)
    }
    
    func contains(_ key: Int) -> Bool {
        let hashed = key.hashValue
        
        let url = directory.appendingPathComponent("\(hashed).dat")
        
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func clear() {
        guard let files = FileManager.default.enumerator(atPath: directory.path)?.allObjects as? [String] else {
            return
        }
        
        let urls = files.flatMap { (path) -> URL? in
            return URL(string: path)
        }
        
        for url in urls {
            do {
                try FileManager.default.removeItem(at: directory.appendingPathComponent(url.path))
            } catch {
                print("Unable to delete \(url): \(error)")
            }
        }
    }
    
    static func exists(named: String) -> Bool {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first else {
            fatalError("Unable to access documents directory!")
        }
        
        let directory = documents.appendingPathComponent(named, isDirectory: true)
        
        return FileManager.default.fileExists(atPath: directory.path)
    }
    
    static func delete(named: String) {
        let cache = MovieCache(named: named)
        
        let directory = cache.directory
        
        try? FileManager.default.removeItem(at: directory)
    }
    
}
