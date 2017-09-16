//
//  MovieData.swift
//  TMDB
//
//  Created by AJ Priola on 2/20/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import Foundation
import SwiftyJSON

struct MovieData {
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    let id: Int
    let title: String
    let posterPath: String
    let overview: String
    let releaseDate: Date?
    let backdropPath: String
    let json: JSON
    
    init() {
        id = 313369
        title = "Title"
        posterPath = "/nil.jpg"
        overview = ""
        releaseDate = nil
        backdropPath = ""
        json = JSON("")
    }
    
    init?(json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }
        
        guard let title = json["title"].string else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.posterPath = json["poster_path"].stringValue
        self.overview = json["overview"].stringValue
        self.releaseDate = dateFormatter.date(from: json["release_date"].stringValue)
        self.backdropPath = json["backdrop_path"].stringValue
        
        self.json = json
    }
    
}
