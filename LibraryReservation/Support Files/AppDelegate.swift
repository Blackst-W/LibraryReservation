//
//  AppDelegate.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import UserNotifications

fileprivate let UMCAppKey = "5af0590f8f4a9d1da0000153"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UMConfigure.initWithAppkey(UMCAppKey, channel: nil)
        UMessage.setAutoAlert(false)
        // Push组件基本功能配置
        let entity = UMessageRegisterEntity()
        entity.types = [UMessageAuthorizationOptions.alert, UMessageAuthorizationOptions.sound, UMessageAuthorizationOptions.badge].reduce(0, { (previous, nextOption) -> Int in
            return previous + Int(nextOption.rawValue)
        })
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        UMessage.registerForRemoteNotifications(launchOptions: launchOptions, entity: entity) { (granted, error) in
            if let error = error {
                Settings.shared.disableNotification()
                print(error.localizedDescription)
                return
            }
            if !granted {
                Settings.shared.disableNotification()
            }
        }
        // Override point for customization after application launch.
        window?.backgroundColor = .white
        WatchAppDelegate.shared.setup()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Token: \((deviceToken as NSData).description)")
        UMessage.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.noData)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let host = url.host?.removingPercentEncoding else {
            return false
        }
        switch host {
        case "login":
            presentLoginView()
            return true
        default:
            return false
        }
    }

    func presentLoginView() {
        guard let window = window,
        let rootViewController = window.rootViewController as? UINavigationController,
        let viewController = rootViewController.viewControllers.last else {
            return
        }
        if let presentedViewController = viewController.presentedViewController {
            if !presentedViewController.isKind(of: AccountNavigationController.self) {
                presentedViewController.presentLoginViewController()
            }
        }else{
            rootViewController.presentLoginViewController()
        }
    }
    
}

