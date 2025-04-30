//
//  AppDelegate.swift
//  TesteUIKit
//
//  Created by Matheus Quirino Cardoso on 26/04/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "defcon", sessionRole: connectingSceneSession.role)
    }

}

