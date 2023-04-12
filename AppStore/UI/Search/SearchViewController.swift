//
//  ViewController.swift
//  AppStore
//
//  Created by Mohamed Ibrahim on 10/08/2022.
//

import UIKit

public protocol SearchIconDataLoaderTask {
    func cancel()
}

public protocol SearchIconDataLoader {
    func loadIconData(from url: URL) -> SearchIconDataLoaderTask
}

public final class SearchViewController: UIViewController {
    
    public private(set) lazy var searchViewController = UISearchController()
    public private(set) var loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    public private(set) lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero,collectionViewLayout: UICollectionViewFlowLayout())
        return view
    }()
    
    private var models: [SearchItem] = []
    private var tasks = [IndexPath: SearchIconDataLoaderTask]()
    
    private var searchLoader: SearchLoader?
    private var iconLoader: SearchIconDataLoader?
    
    public convenience init(searchLoader: SearchLoader,iconLoader: SearchIconDataLoader) {
        self.init()
        self.searchLoader = searchLoader
        self.iconLoader = iconLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchViewController.searchBar.delegate = self
    }
    
    private func load(_ query: String) {
        loadingIndicator.startAnimating()
        searchLoader?.load(query: query, completion: { [weak self] result in
            switch result {
            case let .success(models):
                self?.models = models
                self?.collectionView.reloadData()
            case .failure: break
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
        tasks[indexPath] = iconLoader?.loadIconData(from: model.urlIcon)
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
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
