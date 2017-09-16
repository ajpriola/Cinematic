//
//  Movie.swift
//  TMDB
//
//  Created by AJ Priola on 2/20/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Movie: NSObject, NSCoding, Searching, Detailed {
    
    private static let get = "https://api.themoviedb.org/3/movie/"
    private static let search = "https://api.themoviedb.org/3/search/movie"
    private static let image = "https://image.tmdb.org/t/p/"
    
    typealias ResultType = Movie
    typealias QueryType = String
    typealias DetailType = MovieDetails
    
    static let bookmarks = MovieCache(named: "bookmarks")
    
    private let data: MovieData
    private var details: MovieDetails?
    
    var id: Int {
        return data.id
    }
    
    var title: String {
        return data.title
    }
    
    var posterPath: String {
        return data.posterPath
    }
    
    var overview: String {
        return data.overview
    }
    
    var releaseDate: Date? {
        return data.releaseDate
    }
    
    var genres: [Genre]? {
        return details?.genres
    }
    
    var homepage: URL? {
        return details?.homepage
    }
    
    var companies: [ProductionCompany]? {
        return details?.companies
    }
    
    var runtime: Int? {
        return details?.runtime
    }
    
    var status: String {
        return details?.status ?? "Status"
    }
    
    var tagline: String? {
        return details?.tagline
    }
    
    var budget: Int? {
        return details?.budget
    }
    
    var revenue: Int? {
        return details?.revenue
    }
    
    var bookmarked: Bool {
        return Movie.bookmarks.contains(id)
    }
    
    var releaseYear: Int? {
        if let date = releaseDate {
            return Calendar.current.component(.year, from: date)
        }
        
        return nil
    }
    
    override init() {
        data = MovieData()
        super.init()

    }
    
    init(movieData: MovieData) {
        data = movieData
    }
    
    init?(json: JSON) {
        
        guard let data = MovieData(json: json) else {
            return nil
        }
        
        self.data = data
        
    }
    
    func unbookmark() {
        _ = Movie.bookmarks.remove(id)
    }
    
    func bookmark() {
        Movie.bookmarks.cache(self)
    }
    
    func urlForPoster(ofSize size: PosterSize) -> URL? {
        return URL(string: "\(Movie.image)\(size.rawValue)\(data.posterPath)")
    }
    
    //MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        if let movieData = aDecoder.decodeObject(forKey: "movieData") as? Data,
            let data = MovieData(json: JSON(movieData)) {
            self.data = data
        } else {
            self.data = MovieData()
        }
        
        if let detailsData = aDecoder.decodeObject(forKey: "detailsData") as? Data {
            
            let json = JSON(detailsData)
            
            self.details = MovieDetails(json: json)
            
        }
    }
    
    func encode(with aCoder: NSCoder) {
        do {
            let movieData = try self.data.json.rawData()
            aCoder.encode(movieData, forKey: "movieData")
        } catch {
            print("Did not encode json: \(error)")
        }
        
        if let detailsData = try? self.details?.json.rawData() {
            aCoder.encode(detailsData, forKey: "detailsData")
        }
    }
    
    //MARK: - Searching
    
    static func search(_ query: String, _ closure: @escaping (Result<[Movie]>) -> Void) {
        guard let key = Bundle.main.infoDictionary?["API Key"] as? String else {
            
            closure(Result(value: nil, error: Errors.noKeyProvided))
            
            return
        }
        
        let params = ["api_key" : key, "query" : query]
        
        request(search, parameters: params).responseJSON { (response) in
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let movies = json["results"].arrayValue.flatMap({ (json) -> Movie? in
                    return Movie(json: json)
                })
                
                closure(Result(value: movies, error: nil))
                
            case .failure(let error):
                print(error)
                closure(Result(value: nil, error: error))
            }
        }
    }
    
    //MARK: - Detailed
    
    func details(_ closure: @escaping (Result<MovieDetails>) -> Void) {
        
        if let details = self.details {
            closure(Result(value: details, error: nil))
            return
        }
        
        guard let key = Bundle.main.infoDictionary?["API Key"] as? String else {
            closure(Result(value: nil, error: Errors.noKeyProvided))
            return
        }
        
        let details = "\(Movie.get)\(id)"
        let params = ["api_key" : key]
        
        request(details, parameters: params).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let details = MovieDetails(json: json)
                
                self.details = details
                
                closure(Result(value: details, error: nil))
                
            case .failure(let error):
                closure(Result(value: nil, error: error))
            }
        }
        
    }
    
}
