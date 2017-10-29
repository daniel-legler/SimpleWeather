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
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir", size: 18)!,
                                                             NSForegroundColorAttributeName: Theme.primaryNow()],
                                                            for: .normal )
        let navAppearance = UINavigationBar.appearance()
        navAppearance.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir", size: 20)!,
                                             NSForegroundColorAttributeName: Theme.primaryNow()]
        navAppearance.tintColor = Theme.primaryNow()
        navAppearance.backgroundColor = Theme.primaryNow()
        
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
