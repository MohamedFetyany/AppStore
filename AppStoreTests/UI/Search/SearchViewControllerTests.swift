//
//  SearchViewControllerTests.swift
//  AppStoreTests
//
//  Created by Mohamed Ibrahim on 10/08/2022.
//

import XCTest

private class SearchViewController: UIViewController, UISearchBarDelegate {
    
    private(set) lazy var searchViewController = UISearchController()
    
    private var loader: SearchViewControllerTests.LoaderSpy?
    
    convenience init(loader: SearchViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchViewController.searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loader?.loadSearch()
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
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
        
        func loadSearch() {
            loadCallCount += 1
        }
    }
}

private extension SearchViewController {
    
    func simulateUserSearch(_ query: String) {
        searchViewController.searchBar.delegate?.searchBar?(searchViewController.searchBar, textDidChange: query)
    }
}
