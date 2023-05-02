//
//  SearchViewControllerTests.swift
//  AppStoreTests
//
//  Created by Mohamed Ibrahim on 10/08/2022.
//

import XCTest
import AppStore

class SearchViewControllerTests: XCTestCase {
    
    func test_searching_requestsSearchFromLoader() {
        let (sut ,loader) = makeSUT()
        
        XCTAssertEqual(loader.loadSearchCallCount, 0,"Expected no loading requests before view is loaded")
        
        sut.simulateUserSearch(anyQuery)
        XCTAssertEqual(loader.loadSearchCallCount, 1,"Expected a loading request once user searching")
        
        sut.simulateUserSearch(anyQuery)
        XCTAssertEqual(loader.loadSearchCallCount, 2,"Expected another loading request once user searching again")
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
    
    func test_loadSearchCompletion_rendersSuccessfullyLoadedSearch() {
        let search0 = makeSearchItem(id: 1, name: "a name", category: "a category",rate: nil)
        let search1 = makeSearchItem(id: 2, name: "anthor name", category: "anthor category",rate: 5.3)
        let search2 = makeSearchItem(id: 3, name: "any name", category: "any category",rate: 6.8)
        let (sut, loader) =  makeSUT()
        
        XCTAssertEqual(sut.numberOfRenderedSearchView, 0)
        assertThat(sut, isRendering: [])
        
        sut.simulateUserSearch(anyQuery)
        loader.completeSearchLoading(with: [search0], at: 0)
        assertThat(sut, isRendering: [search0])
        
        sut.simulateUserSearch(anyQuery)
        loader.completeSearchLoading(with: [search0,search1,search2], at: 1)
        assertThat(sut, isRendering: [search0,search1,search2])
    }
    
    func test_loadSearchCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let search0 = makeSearchItem(id: 1, name: "a name", category: "a category")
        let (sut, loader) = makeSUT()
        
        sut.simulateUserSearch(anyQuery)
        loader.completeSearchLoading(with: [search0], at: 0)
        assertThat(sut, isRendering: [search0])
        
        sut.simulateUserSearch(anyQuery)
        loader.completeSearchLoadingWithError(at: 1)
        assertThat(sut, isRendering: [search0])
    }
    
    func test_searchIconView_loadsImageURLWhenVisible() {
        let search0 = makeSearchItem(id: 1, name: "", category: "",iconURL: URL(string: "https://url-0.com")!)
        let search1 = makeSearchItem(id: 2, name: "", category: "",iconURL: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateUserSearch(anyQuery)
        loader.completeSearchLoading(with: [search0,search1], at: 0)
        XCTAssertEqual(loader.loadedIconURLs, [],"Expeced no icon URL requsts until views becomes visible")

        sut.simulateSearchViewVisible(at: 0)
        XCTAssertEqual(loader.loadedIconURLs, [search0.urlIcon],"Expected first icon URL request once first view becomes visible")
        
        sut.simulateSearchViewVisible(at: 1)
        XCTAssertEqual(loader.loadedIconURLs, [search0.urlIcon,search1.urlIcon],"Expected second image URL request once second view also becomes visible")
    }
    
    func test_searchIconView_cancelsImageLoadingWhenNotVisibleAnyMore() {
        let search0 = makeSearchItem(id: 1, name: "", category: "",iconURL: URL(string: "https://url-0.com")!)
        let search1 = makeSearchItem(id: 2, name: "", category: "",iconURL: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.simulateUserSearch(anyQuery)
        loader.completeSearchLoading(with: [search0,search1], at: 0)
        XCTAssertEqual(loader.cancelledIconURLs, [],"Expected no cancelled icon URL requests until icon is not visible")

        sut.simulateSearchViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledIconURLs, [search0.urlIcon],"Expected one cancelled image URL request once first icon is not visible anymore")
        
        sut.simulateSearchViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledIconURLs, [search0.urlIcon,search1.urlIcon],"Expected two cancelled icon URL requests once second icon is also not visible anymore")
    }
    
    func test_searchIconViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserSearch(anyQuery)
        loader.completeSearchLoading(with: [makeSearchItem(id: 1, name: "", category: ""),makeSearchItem(id: 2, name: "", category: "")],at: 0)
        
        let view0 = sut.simulateSearchViewVisible(at: 0)
        let view1 = sut.simulateSearchViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingIconLoaderIndicator, true,"Expected loading indicator for first view while loading first icon")
        XCTAssertEqual(view1?.isShowingIconLoaderIndicator, true, "Expected loading indicator for second view while loading second icon")
        
        loader.completeIconLoading(at: 0)
        XCTAssertEqual(view0?.isShowingIconLoaderIndicator, false,"Expected no loading indicator for first icon once icon loading completes successfully")
        XCTAssertEqual(view1?.isShowingIconLoaderIndicator, true, "Expected no loading indicator state change for second view once first icon loading completes successfully")
        
        loader.completeIconLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingIconLoaderIndicator, false,"Expected no loading indicator state change for first view once second icon loading completes with error")
        XCTAssertEqual(view1?.isShowingIconLoaderIndicator, false, "Expected no loading indicator for second view once icon loading completes with error")
    }
    
    func test_searchIconView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserSearch(anyQuery)
        loader.completeSearchLoading(with: [makeSearchItem(id: 1),makeSearchItem(id: 2)], at: 0)
        
        let view0 = sut.simulateSearchViewVisible(at: 0)
        let view1 = sut.simulateSearchViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedIcon, .none,"Expected no icon for first view while loading first image")
        XCTAssertEqual(view1?.renderedIcon, .none, "Expected no icon for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeIconLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedIcon, imageData0,"Expected icon for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedIcon, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .green).pngData()!
        loader.completeIconLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedIcon, imageData0,"Expected no image state change for first view once second icon loading completes successfully")
        XCTAssertEqual(view1?.renderedIcon, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    //MARK: - Helper
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: SearchViewController,loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = SearchViewController(searchLoader: loader, iconLoader: loader)
        sut.loadViewIfNeeded()
        trackForMemoryLeaks(loader,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,loader)
    }
    
    private func assertThat(
        _ sut: SearchViewController,
        isRendering items: [SearchItem],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedSearchView == items.count else {
            return XCTFail("Expected \(items.count) search, got \(sut.numberOfRenderedSearchView) instead",file: file,line: line)
        }
        
        items.enumerated().forEach { index, item in
            assertThat(sut, hasViewConfiguredFor: item, at: index,file: file,line: line)
        }
    }
    
    private func assertThat(
        _ sut: SearchViewController,
        hasViewConfiguredFor search: SearchItem,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let view = sut.searchItemView(at: index)
        
        guard let cell = view as? SearchItemCell else {
            return XCTFail("Expected \(SearchItemCell.self) instance, got \(String(describing: view)) instead",file: file,line: line)
        }
        
        XCTAssertEqual(cell.nameText, search.category,"Expected name text to be \(String(describing: search.category)) for search view at index \(index)",file: file,line: line)
        XCTAssertEqual(cell.categoryText, search.category,"Expected category text to be \(String(describing: search.category)) for search view at index \(index)",file: file,line: line)
        XCTAssertEqual(cell.rateText, search.ratingText,"Expected rating text to be \(String(describing: search.ratingText)) for search view at index \(index)",file: file,line: line)
    }
    
    private func makeSearchItem(
        id: Int,
        name: String = "",
        category: String = "",
        rate: Float? = nil,
        urls: [URL] = [URL(string: "https://url-1.com")!,URL(string: "https://url-2.com")!],
        iconURL: URL = URL(string: "https://url-icon.com")!
    ) -> SearchItem {
        .init(id: id, name: name, category: category,rate: rate, urls: urls, urlIcon: iconURL)
    }
    
    private var anyQuery: String {
        "any query"
    }
    
    private var url1: URL {
        URL(string: "https://url-1.com")!
    }
    
    private var url2: URL {
        URL(string: "https://url-2.com")!
    }
    
    private class LoaderSpy: SearchLoader, SearchIconDataLoader {
        
        // MARK:  SearchLoader

        private var searchRequests = [(SearchLoader.Result) -> Void]()
        
        var loadSearchCallCount: Int {
            searchRequests.count
        }
        
        func load(query: String, completion: @escaping ((SearchLoader.Result) -> Void)) {
            searchRequests.append(completion)
        }
        
        func completeSearchLoading(with items: [SearchItem] = [],at index: Int) {
            searchRequests[index](.success(items))
        }
        
        func completeSearchLoadingWithError(at index: Int) {
            let error = NSError(domain: "any error", code: 0)
            searchRequests[index](.failure(error))
        }
        
        // MARK:  SearchIconDataLoader
        
        private var iconRequests = [(url: URL,completion: ((SearchIconDataLoader.Result) -> Void))]()
       
        var loadedIconURLs:[URL] {
            iconRequests.map { $0.url }
        }
        
        var cancelledIconURLs = [URL]()
        
        func loadIconData(from url: URL,completion: @escaping ((SearchIconDataLoader.Result) -> Void))-> SearchIconDataLoaderTask {
            iconRequests.append((url,completion))
            return TaskSpy { [weak self] in self?.cancelledIconURLs.append(url) }
        }
        
        func completeIconLoading(with iconData: Data = Data() ,at index: Int) {
            iconRequests[index].completion(.success(iconData))
        }
        
        func completeIconLoadingWithError(at index: Int) {
            let error = NSError(domain: "any error", code: 0)
            iconRequests[index].completion(.failure(error))
        }
        
        private struct TaskSpy: SearchIconDataLoaderTask {
            let callback: (() -> Void)
            
            func cancel() {
                callback()
            }
        }
    }
}

private extension SearchViewController {
    
    func simulateSearchViewNotVisible(at row: Int) {
        let view = searchItemView(at: row)
        
        let delegate = collectionView.delegate
        let index = IndexPath(row: row, section: searchSection)
        delegate?.collectionView?(collectionView, didEndDisplaying: view!, forItemAt: index)
    }
    
    @discardableResult
    func simulateSearchViewVisible(at row: Int) -> SearchItemCell? {
        searchItemView(at: row) as? SearchItemCell
    }
    
    func searchItemView(at item: Int) -> UICollectionViewCell? {
        let ds = collectionView.dataSource
        let index = IndexPath(item: item, section: searchSection)
        return ds?.collectionView(collectionView, cellForItemAt: index)
    }
    
    var numberOfRenderedSearchView: Int {
        collectionView.numberOfItems(inSection: searchSection)
    }
    
    private var searchSection: Int {
        0
    }
    
    var isShowLoadingIndicator: Bool {
        loadingIndicator.isAnimating
    }
    
    func simulateUserSearch(_ query: String) {
        searchViewController.searchBar.delegate?.searchBar?(searchViewController.searchBar, textDidChange: query)
    }
}

private extension SearchItemCell {
    
    var renderedIcon: Data? {
        iconImageView.image?.pngData()
    }
    var isShowingIconLoaderIndicator: Bool {
        searchIconContainer.isShimmering
    }
    
    var nameText: String? {
        nameLabel.text
    }
    
    var categoryText: String? {
        categoryLabel.text
    }
    
    var rateText: String? {
        rateLabel.text
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
