//
//  UISearchBar+SetFont.swift
//  Cinematic
//
//  Created by AJ Priola on 2/20/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import Foundation
import UIKit

extension UISearchBar {
    
    func setFont(_ font: UIFont?) {
        setFont(self, font: font)
    }
    
    private func setFont(_ view: UIView, font: UIFont?) {
        if let textField = view as? UITextField {
            textField.font = font
        } else {
            for subview in view.subviews {
                setFont(subview, font: font)
            }
        }
    }
    
}
