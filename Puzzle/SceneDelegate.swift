//
//  SceneDelegate.swift
//  Puzzle
//
//  Created by roman on 1/13/25.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let mainMenuVC = MainMenuViewController()
        let navigationController = UINavigationController(rootViewController: mainMenuVC)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}

