//
//  SearchViewController.swift
//  Cinematic
//
//  Created by AJ Priola on 2/20/17.
//  Copyright © 2017 AJ Priola. All rights reserved.
//

import UIKit
import AlamofireImage
import UIImageColors

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    private let reuseIdentifier = "movieCell"
    private let movieCellHeight: CGFloat = 80.0
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var bookmarks: [Movie]?
    
    var filteredBookmarks: [Movie]?
    
    var results: [Movie]?
    
    var showingSearch: Bool {
        return segmentedControl.selectedSegmentIndex == 0
    }
    
    var searchQuery: String = ""
    
    var bookmarkQuery: String = ""
    
    var filterBookmarks: Bool {
        return !bookmarkQuery.isEmpty
    }
    
    lazy var emptyView: UILabel = { [unowned self] in
        let label = UILabel(frame: self.tableView.bounds)
        label.font = Constants.font
        label.textColor = .navy
        label.textAlignment = .center
        label.text = "Search for a movie!"
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndex = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndex, animated: animated)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bookmarks = Movie.bookmarks.fetch().value
        
        if !showingSearch {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        searchBar.setFont(Constants.smallFont)
        
        segmentedControl.setFont(Constants.tinyFont)
        
        searchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func movie(for indexPath: IndexPath) -> Movie? {
        if showingSearch {
            return results?[indexPath.row]
        }
        
        if filterBookmarks {
            return filteredBookmarks?[indexPath.row]
        }
        
        return bookmarks?[indexPath.row]
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.resignFirstResponder()
        
        if let destination = segue.destination as? MovieDetailViewController {
            if let selected = tableView.indexPathForSelectedRow {
                destination.movie = movie(for: selected)
                
                if let cell = tableView.cellForRow(at: selected) as? MovieTableViewCell {
                    destination.placeholderImage = cell.moviePosterImageView.image
                }
            }
        }
    }
    
    //MARK: - UI
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        
        if showingSearch {
            searchBar.text = searchQuery
        } else {
            searchBar.text = bookmarkQuery
        }
        
        tableView.reloadData()
        
    }
    
    //MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text {
            
            if showingSearch {
                searchQuery = query
                
                self.emptyView.text = "Searching..."
                
                Movie.search(query, { (result) in
                    self.results = result.value
                    self.tableView.reloadData()
                })
                
            } else {
                bookmarkQuery = query
                
                filteredBookmarks = bookmarks?.filter({ (movie) -> Bool in
                    return movie.title.lowercased().contains(query.lowercased())
                })
                
                tableView.reloadData()
            }
        }
        
        let searchBarHeight = searchBar.frame.height
        let offset = CGPoint(x: 0.0, y: searchBarHeight)
        tableView.setContentOffset(offset, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            
            if showingSearch {
                searchQuery = searchText
                results = nil
            } else {
                bookmarkQuery = searchText
                tableView.reloadData()
            }
        }
    }
    
    //MARK: - UITableViewDataSource & UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showingSearch {
            
            let count = results?.count ?? 0
            
            if count == 0 {
                emptyView.text = "Search for a movie!"
                tableView.backgroundView = emptyView
                tableView.bounces = false
            } else {
                tableView.backgroundView = nil
                tableView.bounces = true
            }
            
            return count
            
        }
        
        if filterBookmarks {
            return filteredBookmarks?.count ?? 0
        }
        
        let count = bookmarks?.count ?? 0
        
        if count == 0 {
            emptyView.text = "You don't have any bookmarks."
            tableView.backgroundView = emptyView
            tableView.bounces = false
        } else {
            tableView.backgroundView = nil
            tableView.bounces = true
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? MovieTableViewCell {
            if let movie = movie(for: indexPath) {
                cell.movieTitleLabel.text = movie.title
                
                if let releaseYear = movie.releaseYear {
                    cell.movieDetailLabel.text = "\(releaseYear)"
                }
                
                if let url = movie.urlForPoster(ofSize: .tiny) {
                    cell.moviePosterImageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "Cinematic"), filter: nil, progress: { (progress) in
                        //Progress
                    }, progressQueue: .main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false, completion: { (response) in
                        /*
                         if let data = response.data, let image = UIImage(data: data) {
                         
                         }*/
                    })
                } else {
                    cell.moviePosterImageView.image = #imageLiteral(resourceName: "Cinematic")
                }
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? MovieTableViewCell {
            cell.moviePosterImageView.backgroundColor = .navy
            cell.moviePosterImageView.layer.cornerRadius = 2.0
            cell.moviePosterImageView.layer.masksToBounds = true
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return movieCellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

}
