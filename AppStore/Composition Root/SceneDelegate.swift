//
//  SceneDelegate.swift
//  AppStore
//
//  Created by Mohamed Ibrahim on 10/08/2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = BaseTabBarController()
        window?.makeKeyAndVisible()
    }
}

class BaseTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navSearchController = UINavigationController(rootViewController: SearchViewController())
        navSearchController.tabBarItem.title = "Search"
        
        let blueViewController = UIViewController()
        blueViewController.view.backgroundColor = .blue
        
        let purpleViewController = UIViewController()
        purpleViewController.view.backgroundColor = .purple
        
        viewControllers = [
            navSearchController,
            blueViewController,
            purpleViewController
        ]
    }
}
