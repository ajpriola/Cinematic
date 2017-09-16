//
//  FullscreenImageViewController.swift
//  Cinematic
//
//  Created by AJ Priola on 2/22/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import UIKit
import UIImageColors

class FullscreenImageViewController: UIViewController, FullscreenTransitionDestination {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    
    var image: UIImage?
    var colors: UIImageColors?
    
    var showingControls: Bool = true {
        didSet {
            fadeControls()
        }
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return !showingControls
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let color = view.backgroundColor {
            if color.isLight {
                return .default
            }
        }
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        downloadButton.setImage(#imageLiteral(resourceName: "download").withRenderingMode(.alwaysTemplate), for: .normal)
        
        imageView.image = image
        
        if let colors = colors {
            setColors(colors)
        } else {
            image?.getColors(completionHandler: { (colors) in
                self.setColors(colors)
            })
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
            self.showingControls = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - UI

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadButtonTapped(_ sender: Any) {
        let savingAlert = UIAlertController(title: "Saving", message: nil, preferredStyle: .alert)
        
        present(savingAlert, animated: true, completion: nil)
        
        image?.saveToPhotos({ (success) in
            savingAlert.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func imageViewTapped(_ sender: Any) {
        showingControls = !showingControls
    }
    
    func fadeControls() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.closeButton.alpha = self.showingControls ? 1.0 : 0.0
            self.downloadButton.alpha = self.showingControls ? 1.0 : 0.0
            self.view.backgroundColor = self.showingControls ? self.colors?.backgroundColor : .black
            self.imageView.backgroundColor = self.showingControls ? self.colors?.backgroundColor : .black
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    func setColors(_ colors: UIImageColors) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.closeButton.tintColor = colors.primaryColor
            self.downloadButton.tintColor = colors.primaryColor
            self.view.backgroundColor = colors.backgroundColor
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    //MARK: - FullscreenTransitionDestination
    
    func destinationFrame(_ forTransition: FullscreenTransition) -> CGRect {
        return imageView.frame
    }
    
}
