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
    typealias Result = Swift.Result<Data,Error>
    
    func loadIconData(from url: URL,completion: @escaping ((Result) -> Void)) -> SearchIconDataLoaderTask
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
        cell.iconImageRetryButton.isHidden = true
        cell.searchIconContainer.startShimmering()
        
        let loadIcon =  { [weak self,weak cell] in
            guard let self else { return }
            
            self.tasks[indexPath] = self.iconLoader?.loadIconData(from: model.urlIcon) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.iconImageView.image = image
                cell?.iconImageRetryButton.isHidden = (image != nil)
                cell?.searchIconContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadIcon
        
        loadIcon()
        
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
    public private(set) var searchIconContainer = UIView()
    public private(set) var iconImageView = UIImageView()
    public private(set) lazy var iconImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}

extension UIView {
    public var isShimmering: Bool {
        return layer.mask?.animation(forKey: shimmerAnimationKey) != nil
    }

    private var shimmerAnimationKey: String {
        return "shimmer"
    }

    func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.75).cgColor
        let width = bounds.width
        let height = bounds.height

        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        layer.mask = gradient

        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1.25
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmerAnimationKey)
    }

    func stopShimmering() {
        layer.mask = nil
    }
}
