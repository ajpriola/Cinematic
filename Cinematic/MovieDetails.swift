//
//  MovieDetails.swift
//  TMDB
//
//  Created by AJ Priola on 2/20/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import Foundation
import SwiftyJSON

struct MovieDetails {
    
    let id: Int
    let genres: [Genre]
    let homepage: URL?
    let companies: [ProductionCompany]
    let runtime: Int
    let status: String
    let tagline: String
    let budget: Int
    let revenue: Int
    let json: JSON
    
    init?(json: JSON) {
        
        guard let id = json["id"].int else {
            return nil
        }
        
        self.id = id
        self.homepage = URL(string: json["homepage"].stringValue)
        self.runtime = json["runtime"].intValue
        self.status = json["status"].stringValue
        self.tagline = json["tagline"].stringValue
        
        self.genres = json["genres"].arrayValue.flatMap({ (json) -> Genre? in
            return Genre(json: json)
        })
        
        self.companies = json["production_companies"].arrayValue.flatMap({ (json) -> ProductionCompany? in
            return ProductionCompany(json: json)
        })
        
        self.budget = json["budget"].intValue
        self.revenue = json["revenue"].intValue
        
        self.json = json
        
    }
    
}
