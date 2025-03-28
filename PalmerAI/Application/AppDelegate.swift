//
//  AppDelegate.swift
//  PalmerAI
//
//  Created by Bekzat Batyrkhanov on 07.02.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainCoordinator: MainCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()

        mainCoordinator = MainCoordinator(navigationController: navigationController)
        mainCoordinator?.start()

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}

