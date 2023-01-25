//
//  RemoteSearchLoaderTests.swift
//  AppStoreTests
//
//  Created by Mohamed Ibrahim on 25/01/2023.
//

import XCTest

enum HTTPClientResult {
    case success(HTTPURLResponse)
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
    
    init(url: URL,client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion:@escaping ((Error) -> Void)) {
        client.get(from: url) { result in
            switch result {
            case let .success(response):
                if response.statusCode != 200 {
                    completion(.invalidData)
                } else {
                    completion(.connectivity)
                }
                
            case .failure:
                completion(.connectivity)
            }
            
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
        
        expect(sut, toCompleteWith: .connectivity, when: {
            client.complete(with: anyNSError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT(url: anyURL)
        
        let samples = [199,201,300,400,500]
        
        samples.enumerated().forEach { index,code in
            expect(sut, toCompleteWith: .invalidData, when: {
                client.complete(withStatusCode: code,at: index)
            })
        }
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
    
    private func expect(
        _ sut: RemoteSearchLoader,
        toCompleteWith error: RemoteSearchLoader.Error,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "wait for completion")
        var receievedError:RemoteSearchLoader.Error?
        sut.load {
            receievedError = $0
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.01)
        
        XCTAssertEqual(receievedError , error,file: file,line: line)
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
        
        func complete(withStatusCode code: Int,at index: Int = 0) {
            let response = HTTPURLResponse(url: URL(string: "https://any-given-url.com")!,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(response))
        }
    }
    
}
