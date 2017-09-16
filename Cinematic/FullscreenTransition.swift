//
//  FullscreenImagePresentation.swift
//  Cinematic
//
//  Created by AJ Priola on 2/22/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import Foundation
import UIKit

protocol FullscreenTransitionSource: class {
    func sourceFrame(_ forTransition: FullscreenTransition) -> CGRect
    func sourceImage(_ forTransition: FullscreenTransition) -> UIImage?
    func sourceColor(_ forTransition: FullscreenTransition) -> UIColor?
}

protocol FullscreenTransitionDestination: class {
    func destinationFrame(_ forTransition: FullscreenTransition) -> CGRect
}

class FullscreenTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    weak var source: FullscreenTransitionSource?
    weak var destination: FullscreenTransitionDestination?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let to = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(true)
            return
        }
        
        let forward = to is FullscreenTransitionDestination
        
        let containerView = transitionContext.containerView
        containerView.backgroundColor = source?.sourceColor(self) ?? .black
        
        let coloredView = UIView(frame: UIScreen.main.bounds)
        coloredView.backgroundColor = source?.sourceColor(self) ?? .black
        containerView.addSubview(coloredView)
        
        var sourceFrame: CGRect = .zero
        var destinationFrame: CGRect = .zero
        
        if forward {
            sourceFrame = source?.sourceFrame(self) ?? .zero
            destinationFrame = destination?.destinationFrame(self) ?? .zero
            containerView.addSubview(to.view)
        } else {
            sourceFrame = destination?.destinationFrame(self) ?? .zero
            destinationFrame = source?.sourceFrame(self) ?? .zero
            containerView.insertSubview(to.view, at: 0)
        }
        
        let imageTransitionView = UIImageView(frame: sourceFrame)
        imageTransitionView.contentMode = .scaleAspectFit
        imageTransitionView.image = source?.sourceImage(self)
        
        containerView.addSubview(imageTransitionView)
        
        to.view.alpha = 0.0
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: .curveEaseInOut, animations: {
            
            imageTransitionView.frame = destinationFrame
        }) { (completed) in
            to.view.alpha = 1.0
            transitionContext.completeTransition(true)
        }
        
    }
    
}
