//
//  RemoteSearchLoaderTests.swift
//  AppStoreTests
//
//  Created by Mohamed Ibrahim on 25/01/2023.
//

import XCTest
import AppStore

enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

protocol HTTPClient {
    func get(from url: URL,completion:@escaping ((HTTPClientResult) -> Void))
}

class RemoteSearchLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    enum Result {
        case success([SearchItem])
        case failure(Error)
    }
    
    init(url: URL,client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion:@escaping ((Result) -> Void)) {
        client.get(from: url) { [weak self] result in
            
            switch result {
            case let .success(data,response):
                do {
                    let items = try SearchItemsMapper.map(data: data, from: response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }
            
        }
    }
}

final class SearchItemsMapper: Decodable {
    
    private let results: [Item]
    
    var items: [SearchItem] {
        results.map { $0.item }
    }
    
    private struct Item: Decodable {
        let trackId: Int
        let trackName: String
        let primaryGenreName: String
        let averageUserRating: Float?
        let screenshotUrls: [URL]
        let artworkUrl100: URL
        let formattedPrice: String?
        let description: String?
        let releaseNotes: String?
        let artistName: String?
        let collectionName: String?
        
        var item: SearchItem {
            SearchItem(
                trackId: trackId,
                trackName: trackName,
                primaryGenreName: primaryGenreName,
                rate: averageUserRating,
                screenshotUrls: screenshotUrls,
                iconImage: artworkUrl100,
                formattedPrice: formattedPrice,
                description: description,
                releaseNotes: releaseNotes,
                artistName: artistName,
                collectionName: collectionName
            )
        }
    }
    
    static func map(data: Data,from response: HTTPURLResponse) throws -> [SearchItem] {
        guard response.statusCode == 200 ,let root = try? JSONDecoder().decode(SearchItemsMapper.self, from: data) else {
            throw RemoteSearchLoader.Error.invalidData
        }
        
        return root.items
    }
}

class RemoteSearchLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestedDataFromURL() {
        let (_,client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = anyURL
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs,[url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = anyURL
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs,[url,url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT(url: anyURL)
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.complete(with: anyNSError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT(url: anyURL)
        
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach { index,code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code,at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidData = Data("invalid data".utf8)
        let (sut, client) = makeSUT(url: anyURL)
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatusCode: 200,data: invalidData)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let data = makeResultsJson([])
        let (sut, client) = makeSUT(url: anyURL)
        
        expect(sut, toCompleteWith: .success([]), when: {
            client.complete(withStatusCode: 200,data: data)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItemSearch(
            trackId: 1,
            trackName: "a name",
            primaryGenreName: "a primary genre name",
            screenshotUrls: [URL(string: "https:a-url.com")!],
            iconImage: anyURL
        )
        
        let item2 = makeItemSearch(
            trackId: 2,
            trackName: "another name",
            primaryGenreName: "another primary",
            rate: 1.0,
            screenshotUrls: [URL(string: "https:another-url.com")!],
            iconImage: anyURL,
            formattedPrice: "10.20",
            description: "another description",
            releaseNotes: "another release notes",
            artistName: "another artist name",
            collectionName: "another collection name")
        
        let items = [item1.model,item2.model]
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeResultsJson([item1.json,item2.json])
            client.complete(withStatusCode: 200,data: json)
        })
    }
    
    // MARK:  Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) ->(sut: RemoteSearchLoader,client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteSearchLoader(url: url,client: client)
        
        trackForMemoryLeaks(sut,file: file,line: line)
        trackForMemoryLeaks(client,file: file,line: line)
        
        return (sut,client)
    }
    
    private func makeItemSearch(
        trackId: Int,
        trackName: String,
        primaryGenreName: String,
        rate: Float? = nil,
        screenshotUrls: [URL],
        iconImage: URL,
        formattedPrice: String? = nil,
        description: String? = nil,
        releaseNotes: String? = nil,
        artistName: String? = nil,
        collectionName: String? = nil
    ) -> (model: SearchItem,json: [String: Any]) {
        
        let item = SearchItem(
            trackId: trackId,
            trackName: trackName,
            primaryGenreName: primaryGenreName,
            rate: rate,
            screenshotUrls: screenshotUrls,
            iconImage: iconImage,
            formattedPrice: formattedPrice,
            description: description,
            releaseNotes: releaseNotes,
            artistName: artistName,
            collectionName: collectionName
        )
        
        let json = [
            "trackId": trackId,
            "trackName": trackName,
            "primaryGenreName": primaryGenreName,
            "averageUserRating": rate,
            "screenshotUrls": screenshotUrls.map { $0.absoluteString },
            "artworkUrl100": iconImage.absoluteString,
            "formattedPrice": formattedPrice,
            "description": description,
            "releaseNotes": releaseNotes,
            "artistName": artistName,
            "collectionName": collectionName
        ].compactMapValues { $0 }
        
        return (item,json)
    }
    
    private func makeResultsJson(_ items: [[String: Any]]) -> Data {
        let json = ["results": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func failure(_ error: RemoteSearchLoader.Error) -> RemoteSearchLoader.Result {
        .failure(error)
    }
    
    private func expect(
        _ sut: RemoteSearchLoader,
        toCompleteWith expectedResult: RemoteSearchLoader.Result,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "wait for completion")
        
        sut.load { receivedResult in

            switch (receivedResult,expectedResult) {
                
            case let (.success(recievedItems),.success(expectedItems)):
                XCTAssertEqual(recievedItems , expectedItems,file: file,line: line)
                
            case let (.failure(receivedError),.failure(expectedError)):
                XCTAssertEqual(receivedError , expectedError,file: file,line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) but got \(receivedResult) instead",file: file,line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.01)
    }
    
    private var anyURL: URL {
        URL(string: "https://any-given-url.com")!
    }
    
    private var anyNSError: NSError {
        NSError(domain: "any error", code: 1)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private(set) var messages = [(url: URL,completion: (HTTPClientResult) -> Void)]()
       
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL,completion:@escaping ((HTTPClientResult) -> Void)) {
            messages.append((url,completion))
        }
        
        func complete(with error: Error,at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(
            withStatusCode code: Int,
            data: Data = Data(),
            at index: Int = 0
        ) {
            let response = HTTPURLResponse(url: URL(string: "https://any-given-url.com")!,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data,response))
        }
    }
    
}
