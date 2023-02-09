//
//  URLSessionHTTPClientTests.swift
//  AppStoreTests
//
//  Created by Mohamed Ibrahim on 08/02/2023.
//

import XCTest
import AppStore

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    
    private let session: HTTPSession
    
    init(session: HTTPSession) {
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
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://any-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url,with: task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount,1)
    }
    
    func test_getFromURL_failsOnClientError() {
        let clientError = NSError(domain: "any error", code: 1)
        let url = URL(string: "https://any-url.com")!
        let session = HTTPSessionSpy()
        session.stub(url: url,error: clientError)
        let sut = URLSessionHTTPClient(session: session)
        
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
    }
    
    // MARK:  Helpers
    
    private class HTTPSessionSpy: HTTPSession {
        
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }
        
        func stub(url: URL,with task: HTTPSessionTask = FakeURLSessionDataTask(),error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else {
                fatalError("couldn't find stub for \(url)")
            }
            
            completionHandler(nil,nil,stub.error)
            return stub.task
        }
    
    }
    
    private class FakeURLSessionDataTask: HTTPSessionTask {
        func resume() {}
    }
    
    private class URLSessionDataTaskSpy: HTTPSessionTask {
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
}
