//
//  URLSessionHTTPClientTests.swift
//  AppStoreTests
//
//  Created by Mohamed Ibrahim on 08/02/2023.
//

import XCTest
import AppStore

class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL,comletion: @escaping ((HTTPClientResult) -> Void)) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                comletion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_failsOnClientError() {
        URLProtocolStub.startInterceptingRequests()
        let clientError = NSError(domain: "any error", code: 1)
        let url = URL(string: "https://any-url.com")!
        URLProtocolStub.stub(data: nil,response: nil,error: clientError)
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, clientError.domain)
                XCTAssertEqual(receivedError.code, clientError.code)
                
            default:
                XCTFail("Expected failure with error \(clientError), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.01)
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    // MARK:  Helpers
    
    private class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub?
        
        private struct Stub {
            let data: Data?
            let response: HTTPURLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?,response: HTTPURLResponse?,error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            URLProtocolStub.stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
