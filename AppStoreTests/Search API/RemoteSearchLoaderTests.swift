//
//  RemoteSearchLoaderTests.swift
//  AppStoreTests
//
//  Created by Mohamed Ibrahim on 25/01/2023.
//

import XCTest

protocol HTTPClient {
    func get(from url: URL)
}

class RemoteSearchLoader {
    
    init(url: URL,client: HTTPClient) {
        
    }
}

class RemoteSearchLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestedDataFromURL() {
        let (_,client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
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
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        
        func get(from url: URL) {
            requestedURLs.append(url)
        }
    }
    
}
