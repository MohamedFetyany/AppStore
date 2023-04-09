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
    private(set) var loadingIndicator = UIActivityIndicatorView(style: .medium)
    
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
        loadingIndicator.startAnimating()
        loader?.load(query: "", completion: { [weak self] _ in
            self?.loadingIndicator.stopAnimating()
        })
    }
}

class SearchViewControllerTests: XCTestCase {
    
    func test_searching_requestsSearchFromLoader() {
        let (sut ,loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0,"Expected no loading requests before view is loaded")
        
        sut.simulateUserSearch(anyQuery)
        XCTAssertEqual(loader.loadCallCount, 1,"Expected a loading request once user searching")
        
        sut.simulateUserSearch(anyQuery)
        XCTAssertEqual(loader.loadCallCount, 2,"Expected another loading request once user searching again")
    }
    
    func test_loadingSearchIndicator_isVisibleWhileLoadingSearch() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(sut.isShowLoadingIndicator, false,"Expected no loading indicator one load view")
        
        sut.simulateUserSearch(anyQuery)
        XCTAssertEqual(sut.isShowLoadingIndicator, true,"Expected loading indicator once loading search")
        
        loader.completeSearchLoading(at: 0)
        XCTAssertEqual(sut.isShowLoadingIndicator, false,"Expected no loading indicator once requests completes with success")
        
        sut.simulateUserSearch(anyQuery)
        XCTAssertEqual(sut.isShowLoadingIndicator, true,"Expected another loading indicator once loading search again ")
        
        loader.completeSearchLoadingWithError(at: 1)
        XCTAssertEqual(sut.isShowLoadingIndicator, false,"Expected no loading indicator once requests completes with error")
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
    
    private var anyQuery: String {
        "any query"
    }
    
    private class LoaderSpy: SearchLoader {
        
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
        
        func completeSearchLoadingWithError(at index: Int) {
            let error = NSError(domain: "any error", code: 0)
            completions[index](.failure(error))
        }
    }
}

private extension SearchViewController {
    
    var isShowLoadingIndicator: Bool {
        loadingIndicator.isAnimating
    }
    
    func simulateUserSearch(_ query: String) {
        searchViewController.searchBar.delegate?.searchBar?(searchViewController.searchBar, textDidChange: query)
    }
}
