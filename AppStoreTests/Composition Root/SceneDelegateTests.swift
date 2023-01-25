//
//  SceneDelegateTests.swift
//  AppStoreTests
//
//  Created by Mohamed Ibrahim on 10/08/2022.
//

import XCTest
@testable import AppStore

final class SceneDelegateTests: XCTestCase {
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindowSpy()
        let sut = SceneDelegate()
        sut.window = window
        
        sut.configureWindow()
        
        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1,"Expected to make window key and visible")
    }
    
    func test_configureWindow_configuresRootViewController() {
        let window = UIWindowSpy()
        let sut = SceneDelegate()
        sut.window = window
        
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        XCTAssertNotNil(root, "Expected window to have a `rootViewController`")

        let tabBar = root as? BaseTabBarController
        XCTAssertNotNil(tabBar, "Expected rootViewController to be a `BaseTabBarController`")
        XCTAssertEqual(tabBar?.viewControllers?.count, 3,"Expected three tabs in the root 'BaseTabBarController'")
    }
    
    func test_firstTab_isSearchViewController() {
        let window = UIWindowSpy()
        let sut = SceneDelegate()
        sut.window = window
        
        sut.configureWindow()
        
        let tab = sut.tab(at: 0)
        XCTAssertEqual(tab.title, "Search","Expected first tab title is 'Search'")
        XCTAssertTrue(tab.view is SearchViewController,"Expected first tab view to be 'SearchViewController' , got \(String(describing: tab.view)) instead")
    }
    
    //MARK: - Helper
    
    private class UIWindowSpy: UIWindow {
        var makeKeyAndVisibleCallCount = 0
        
        override func makeKeyAndVisible() {
            makeKeyAndVisibleCallCount += 1
        }
    }
}

private extension SceneDelegate {
    func tab(at index: Int) -> (title: String, view: UIViewController) {
        let root = window?.rootViewController
        let tabBar = root as? BaseTabBarController
        let tab = tabBar?.viewControllers?[index] as! UINavigationController
        return (tab.tabBarItem.title!, tab.topViewController!)
    }
}
