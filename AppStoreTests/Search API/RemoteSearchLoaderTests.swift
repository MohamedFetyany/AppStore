//
//  RemoteSearchLoaderTests.swift
//  AppStoreTests
//
//  Created by Mohamed Ibrahim on 25/01/2023.
//

import XCTest

protocol HTTPClient {
    func get(from url: URL,completion:@escaping ((Error) -> Void))
}

class RemoteSearchLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    enum Error: Swift.Error {
        case connectivity
    }
    
    init(url: URL,client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion:@escaping ((Error) -> Void) = { _ in }) {
        client.get(from: url) { _ in
            completion(.connectivity)
        }
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
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs,[url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = anyURL
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs,[url,url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT(url: anyURL)
        
        let exp = expectation(description: "wait for completion")
        var receievedError:RemoteSearchLoader.Error?
        sut.load {
            receievedError = $0
            exp.fulfill()
        }
        
        client.complete(with: anyNSError)
        
        wait(for: [exp], timeout: 0.01)
        
        XCTAssertEqual(receievedError , RemoteSearchLoader.Error.connectivity)
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
    
    private var anyURL: URL {
        URL(string: "https://any-given-url.com")!
    }
    
    private var anyNSError: NSError {
        NSError(domain: "any error", code: 1)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private(set) var messages = [(url: URL,completion: (Error) -> Void)]()
       
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL,completion:@escaping ((Error) -> Void)) {
            messages.append((url,completion))
        }
        
        func complete(with error: Error,at index: Int = 0) {
            messages[index].completion(error)
        }
    }
    
}
