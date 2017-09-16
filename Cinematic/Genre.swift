//
//  Genre.swift
//  TMDB
//
//  Created by AJ Priola on 2/21/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Genre {
    
    let id: Int
    let name: String
    
    init?(json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }
        
        guard let name = json["name"].string else {
            return nil
        }
        
        self.id = id
        self.name = name
    }
    
}
