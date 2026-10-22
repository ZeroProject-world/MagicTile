//
//  SceneDelegate.swift
//  MagicTile
//
//  Scene-based life cycle (required by modern iOS SDKs).
//  Creates the window inside the scene and hosts the game view.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.gameLogic == nil {
            appDelegate.gameLogic = GameLogic()
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView:
            GameView().environmentObject(appDelegate.gameLogic)
        )
        self.window = window
        window.makeKeyAndVisible()
    }
}
