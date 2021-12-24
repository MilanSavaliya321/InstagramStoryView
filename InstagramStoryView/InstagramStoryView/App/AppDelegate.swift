//
//  AppDelegate.swift
//  InstagramStoryView
//
//  Created by Milan Savaliya on 24/12/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navController: NavigationController?
    var loginPageViewController: UserListVC?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {


//        window = UIWindow(frame:UIScreen.main.bounds)
//        loginPageViewController = UserListVC(nibName: "UserListVC", bundle: nil)
//        navController = UINavigationController(rootViewController: loginPageViewController!)
//        window?.rootViewController = navController
//        window?.makeKeyAndVisible()
        window = UIWindow(frame: UIScreen.main.bounds)
        loginPageViewController = UserListVC(nibName: "UserListVC", bundle: nil)
        let navController = NavigationController(rootViewController: loginPageViewController!)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()

        return true
    }

}

