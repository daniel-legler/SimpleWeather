//
//  AppDelegate.swift
//  SimpleWeather!
//
//  Created by Daniel Legler on 8/8/17.
//  Copyright © 2017 Daniel Legler. All rights reserved.
//

import UIKit
import Firebase
import Material

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        
        FirebaseApp.configure()
        Coordinator.shared.setup()
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let rootVC = mainStoryboard.instantiateViewController(withIdentifier: "SWNavigationController")
        
        window = UIWindow(frame: Screen.bounds)
        window!.rootViewController = AppFABMenuController(rootViewController: rootVC)
        window!.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}
