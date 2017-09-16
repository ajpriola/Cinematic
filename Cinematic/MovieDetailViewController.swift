//
//  MovieDetailViewController.swift
//  Cinematic
//
//  Created by AJ Priola on 2/21/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import UIKit
import MXParallaxHeader
import UIImageColors

class MovieDetailViewController: UIViewController, UIScrollViewDelegate, UIViewControllerTransitioningDelegate, FullscreenTransitionSource {

    private let aspectRatio: CGFloat = 0.675
    
    lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    //For coloring
    
    @IBOutlet var primaryLabels: [UILabel]!
    @IBOutlet var secondaryLabels: [UILabel]!
    @IBOutlet var detailLabels: [UILabel]!
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    @IBOutlet weak var productionLabel: UILabel!
    
    var movie: Movie?
    var colors: UIImageColors?
    var placeholderImage: UIImage?
    
    var bookmarked: Bool = false {
        didSet {
            if bookmarked {
                bookmarkButton.setImage(#imageLiteral(resourceName: "bookmark-filled").withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                bookmarkButton.setImage(#imageLiteral(resourceName: "bookmark").withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
    }
    
    let fullscreenTransition = FullscreenTransition()
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    lazy var headerView: UIImageView = { [unowned self] in
        let bounds = UIScreen.main.bounds
        let headerSize = CGSize(width: bounds.width, height: bounds.width / self.aspectRatio)
        let headerView = UIImageView(frame: CGRect(origin: .zero, size: headerSize))
        headerView.contentMode = .scaleAspectFill
        headerView.backgroundColor = .navy
        headerView.isUserInteractionEnabled = true
        return headerView
    }()
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
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
        
        titleLabel.text = movie?.title
        titleLabel.adjustsFontSizeToFitWidth = true
        tagLabel.adjustsFontSizeToFitWidth = true
        
        bookmarked = movie?.bookmarked ?? false
        
        backButton.setImage(#imageLiteral(resourceName: "back").withRenderingMode(.alwaysTemplate), for: .normal)
        
        fullscreenTransition.source = self
        
        let bounds = UIScreen.main.bounds
        scrollView.parallaxHeader.view = headerView
        scrollView.parallaxHeader.height = bounds.width / aspectRatio
        scrollView.parallaxHeader.mode = .fill
        scrollView.parallaxHeader.minimumHeight = 0.0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MovieDetailViewController.headerViewTapped(_:)))
        scrollView.parallaxHeader.view?.addGestureRecognizer(tapGesture)
        
        if let url = movie?.urlForPoster(ofSize: .original) {
            headerView.af_setImage(withURL: url, placeholderImage: placeholderImage, filter: nil, progress: { (progress) in
                //Progress
            }, progressQueue: .main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false, completion: { (response) in
                
                if let image = response.result.value {
                    image.getColors(completionHandler: { (colors) in
                        self.setColors(colors)
                    })
                }
                
            })
        }
        
        /*
        movie?.details({ (movie, error) in
            if let error = error {
                print(error)
            } else {
                self.setMovieDetails()
            }
        })*/
        
        movie?.details({ (result) in
            if let error = result.error {
                print(error)
            } else {
                self.setMovieDetails()
            }
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FullscreenImageViewController {
            destination.image = headerView.image
            destination.colors = colors
            fullscreenTransition.destination = destination
            destination.transitioningDelegate = self
        }
    }
    
    //MARK: - UI
    
    @IBAction func backButtonTapped(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func bookmarkButtonTapped(_ sender: Any) {
        if bookmarked {
            movie?.unbookmark()
        } else {
            movie?.bookmark()
        }
        
        if let bookmarked = movie?.bookmarked {
            self.bookmarked = bookmarked
        }
    }
    
    func headerViewTapped(_ sender: Any) {
        let yOffset = abs(scrollView.contentOffset.y)
        
        if floor(yOffset) == floor(scrollView.parallaxHeader.height) {
            performSegue(withIdentifier: "showFullscreenImage", sender: self)
        } else {
            let offset = CGPoint(x: 0.0, y: -scrollView.parallaxHeader.height)
            scrollView.setContentOffset(offset, animated: true)
        }
    }
    
    @IBAction func titleLabelTapped(_ sender: Any) {
        scrollView.setContentOffset(.zero, animated: true)
    }
    
    func setMovieDetails() {
        tagLabel.text = movie?.tagline
        overviewTextView.text = movie?.overview
        
        genresLabel.text = movie?.genres?.reduce("", { (result, genre) -> String in
            return result.isEmpty ? genre.name : "\(result), \(genre.name)"
        })
        
        productionLabel.text = movie?.companies?.reduce("", { (result, company) -> String in
            return result.isEmpty ? company.name : "\(result), \(company.name)"
        })
        
        statusTitleLabel.text = movie?.status
        
        if let releaseDate = movie?.releaseDate {
            statusLabel.text = dateFormatter.string(from: releaseDate)
        }
        
        if let runtime = movie?.runtime {
            runLabel.text = "\(runtime) minutes"
        }
        
        if let budget = movie?.budget {
            let number = NSNumber(integerLiteral: budget)
            budgetLabel.text = currencyFormatter.string(from: number)
        }
        
        if let revenue = movie?.revenue {
            let number = NSNumber(integerLiteral: revenue)
            revenueLabel.text = currencyFormatter.string(from: number)
        }
    }
    
    func setColors(_ colors: UIImageColors) {
        self.colors = colors
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: { 
            self.contentView.backgroundColor = colors.backgroundColor
            self.view.backgroundColor = colors.backgroundColor
            self.titleView.backgroundColor = colors.backgroundColor
            self.backButton.tintColor = colors.primaryColor
            self.bookmarkButton.tintColor = colors.primaryColor
            self.overviewTextView.textColor = colors.secondaryColor
            self.overviewTextView.tintColor = colors.primaryColor
            
            for label in self.primaryLabels {
                label.textColor = colors.primaryColor
            }
            
            for label in self.secondaryLabels {
                label.textColor = colors.secondaryColor
            }
            
            for label in self.detailLabels {
                label.textColor = colors.detailColor
            }
            
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    //MARK: - FullscreenTransitionSource
    
    func sourceFrame(_ forTransition: FullscreenTransition) -> CGRect {
        return headerView.convert(headerView.frame, to: view)
    }
    
    func sourceImage(_ forTransition: FullscreenTransition) -> UIImage? {
        return headerView.image
    }
    
    func sourceColor(_ forTransition: FullscreenTransition) -> UIColor? {
        return colors?.backgroundColor
    }
    
    //MARK: - UIViewControllerTransitioningDelegate
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return fullscreenTransition
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return fullscreenTransition
    }
    
    //MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0.0 {
            //scrollView.contentOffset.y = 0.0
            
            titleView.frame.origin.y = scrollView.contentOffset.y
        }
        
        /*
        if scrollView.contentOffset.y > -backButton.frame.height {
            let delta = (backButton.frame.height + scrollView.contentOffset.y) / backButton.frame.height
            backButton.alpha = delta
            bookmarkButton.alpha = delta
        } else {
            backButton.alpha = 0.0
            bookmarkButton.alpha = 0.0
        }*/
    }

}
