//
//  SearchViewControllerTests.swift
//  AppStoreTests
//
//  Created by Mohamed Ibrahim on 10/08/2022.
//

import XCTest
import AppStore

private class SearchViewController: UIViewController, UISearchBarDelegate {
    
    private(set) lazy var searchViewController = UISearchController()
    private(set) var loadingView = UIActivityIndicatorView(style: .medium)
    
    private var loader: SearchLoader?
    
    convenience init(loader: SearchLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchViewController.searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadingView.startAnimating()
        loader?.load(query: "", completion: { [weak self] _ in
            self?.loadingView.stopAnimating()
        })
    }
}

class SearchViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadSearch() {
        let (_ ,loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_userTyping_loadsSearch() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserSearch("any query")
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.simulateUserSearch("any query")
        XCTAssertEqual(loader.loadCallCount, 2)
    }
    
    func test_searching_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.simulateUserSearch("any query")
        
        XCTAssertEqual(sut.isShowLoadingIndicator, true)
    }
    
    func test_searching_hidesLoadingIndicatoOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserSearch("any query")
        loader.completeSearchLoading(at: 0)
        
        XCTAssertEqual(sut.isShowLoadingIndicator, false)
    }
    
    //MARK: - Helper
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: SearchViewController,loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = SearchViewController(loader: loader)
        sut.loadViewIfNeeded()
        trackForMemoryLeaks(loader,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,loader)
    }
    
    class LoaderSpy: SearchLoader {
        
        private var completions = [(LoadSearchResult) -> Void]()
        
        var loadCallCount: Int {
            completions.count
        }
        
        func load(query: String, completion: @escaping ((LoadSearchResult) -> Void)) {
            completions.append(completion)
        }
        
        func completeSearchLoading(at index: Int) {
            completions[index](.success([]))
        }
    }
}

private extension SearchViewController {
    
    var isShowLoadingIndicator: Bool {
        loadingView.isAnimating
    }
    
    func simulateUserSearch(_ query: String) {
        searchViewController.searchBar.delegate?.searchBar?(searchViewController.searchBar, textDidChange: query)
    }
}
