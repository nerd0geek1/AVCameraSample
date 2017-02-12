//
//  AppDelegate.swift
//  AVCameraSample
//
//  Created by Kohei Tabata on 2016/02/14.
//  Copyright © 2016年 Kohei Tabata. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    // MARK: - lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let viewController: ViewController = ViewController()
        window?.rootViewController = viewController

        window?.makeKeyAndVisible()

        return true
    }
}
