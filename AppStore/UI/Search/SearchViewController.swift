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
    
    public private(set) lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero,collectionViewLayout: UICollectionViewFlowLayout())
        return view
    }()
    
    private var models: [SearchItem] = []
    
    private var loader: SearchLoader?
    
    public convenience init(loader: SearchLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        
        searchViewController.searchBar.delegate = self
    }
    
    private func load(_ query: String) {
        loadingIndicator.startAnimating()
        loader?.load(query: query, completion: { [weak self] result in
            if let models = try? result.get() {
                self?.models = models
                self?.collectionView.reloadData()
            }
            self?.loadingIndicator.stopAnimating()
        })
    }
}

extension SearchViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = SearchItemCell()
        let model = models[indexPath.item]
        cell.nameLabel.text = model.category
        cell.categoryLabel.text =  model.category
        cell.rateLabel.text = model.ratingText
        return cell
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        load("")
    }
}

public class SearchItemCell: UICollectionViewCell {
    public private(set) var nameLabel = UILabel()
    public private(set) var categoryLabel = UILabel()
    public private(set) var rateLabel = UILabel()
}
