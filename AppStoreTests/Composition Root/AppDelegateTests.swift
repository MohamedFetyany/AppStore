//
//  AppDelegateTests.swift
//  AppStoreTests
//
//  Created by Mohamed Ibrahim on 10/08/2022.
//

import XCTest
@testable import AppStore

final class AppDelegateTests: XCTestCase {
    
    func test_canFinishLaunching() {
        let sut = makeSUT()
        
        let finished = sut.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
        
        XCTAssertTrue(finished, "Expected 'didFinishLaunchingWithOptions' to return true")
    }
    
    //MARK: - Helper
    
    private func makeSUT() -> AppDelegate {
        return AppDelegate()
    }
}
