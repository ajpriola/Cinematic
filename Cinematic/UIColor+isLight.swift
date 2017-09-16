//
//  UIColor+isLight.swift
//  Cinematic
//
//  Created by AJ Priola on 2/21/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    var isLight: Bool {
        var white: CGFloat = 0
        getWhite(&white, alpha: nil)
        return white > 0.5
    }
    
}
