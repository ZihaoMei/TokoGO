//
//  SceneDelegate.swift
//  Tokoapp_D
//
//  Created by 梅子豪 on 2025/09/09.
//

import UIKit
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        // ✅ 修复：在启动时加载数据
        let routes = BusDataLoader.loadRoutes()
        // ✅ 修复：将数据传递给 RootViewController
        window.rootViewController = RootViewController(routes: routes)
        self.window = window
        window.makeKeyAndVisible()
    }
}
