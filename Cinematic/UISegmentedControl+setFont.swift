//
//  UISegmentedControl+setFont.swift
//  Cinematic
//
//  Created by AJ Priola on 2/22/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import Foundation
import UIKit

extension UISegmentedControl {
    
    func setFont(_ font: UIFont?) {
        setTitleTextAttributes([NSFontAttributeName : font!], for: .normal)
    }
    
}
