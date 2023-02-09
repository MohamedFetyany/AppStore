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
            } else {
                comletion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL

        let exp = expectation(description: "wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 0.01)
    }
    
    func test_getFromURL_failsOnClientError() {
        let clientError = anyNSError
        URLProtocolStub.stub(data: nil,response: nil,error: clientError)
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        sut.get(from: anyURL) { result in
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
    }
    
    func test_getFromURL_failsOnAllNilValues() {
        URLProtocolStub.stub(data: nil, response: nil, error: nil)
        
        let exp = expectation(description: "wait for completion")
        makeSUT().get(from: anyURL) { result in
            switch result {
            case .failure:
                break
                
            default:
                XCTFail("Expected failure ,got \(result)instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.01)
    }
    
    // MARK:  Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: HTTPURLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?,response: HTTPURLResponse?,error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(_ observer: @escaping ((URLRequest) -> Void)) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
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
