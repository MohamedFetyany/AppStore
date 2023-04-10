//
//  ViewController.swift
//  AppStore
//
//  Created by Mohamed Ibrahim on 10/08/2022.
//

import UIKit

public final class SearchViewController: UIViewController {
    
    public private(set) lazy var searchViewController = UISearchController()
    public private(set) var loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private var loader: SearchLoader?
    
    public convenience init(loader: SearchLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        searchViewController.searchBar.delegate = self
    }
    
    private func load(_ query: String) {
        loadingIndicator.startAnimating()
        loader?.load(query: query, completion: { [weak self] _ in
            self?.loadingIndicator.stopAnimating()
        })
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        load("")
    }
}
