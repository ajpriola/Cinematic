//
//  Detailed.swift
//  TMDB
//
//  Created by AJ Priola on 2/21/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import Foundation

protocol Detailed {
    
    associatedtype DetailType
    
    func details(_ closure: @escaping (Result<DetailType>) -> Void)
    
}
