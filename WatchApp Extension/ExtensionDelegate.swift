//
//  ExtensionDelegate.swift
//  WatchApp Extension
//
//  Created by Weston Wu on 2018/05/01.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import WatchKit
import WatchConnectivity
import WatchSeatKit

extension Notification.Name {
    static let ReceiveAccountUpdate = Notification.Name("kReceiveAccountUpdateNotification")
    static let ReceiveReservationUpdate = Notification.Name("kReceiveReservationUpdateReservation")
}

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    class var current: ExtensionDelegate {
        return WKExtension.shared().delegate as! ExtensionDelegate
    }
    
    var session: WCSession!
    
    func applicationDidFinishLaunching() {
        session = WCSession.default
        session.delegate = self
        session.activate()
        // Perform any final initialization of your application.
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
}

extension ExtensionDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated, .inactive:
            break
        case .notActivated:
            guard let error = error else {
                return
            }
            print(error.localizedDescription)
            return
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleSettings(message: message)
        handleAccount(message: message)
        handleSeatReservation(message: message)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handleSettings(message: userInfo)
        handleAccount(message: userInfo)
        handleSeatReservation(message: userInfo)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleSettings(message: applicationContext)
        handleAccount(message: applicationContext)
        handleSeatReservation(message: applicationContext)
    }
    
    func handleSettings(message: [String: Any]) {
        guard let _ = message["UpdateSettingsKey"] else {
            return
        }
        
        guard let data = message["UpdateSettingsDataKey"] as? Data else {
            return
        }
        let decoder = JSONDecoder()
        guard let newSettings = try? decoder.decode(Settings.self, from: data) else {
            return
        }
        Settings.shared.set(savePassword: newSettings.savePassword)
        Settings.shared.set(autoLogin: newSettings.autoLogin)
        Settings.shared.updateNotification(settings: newSettings.notificationSettings)
        
    }
    
    func handleAccount(message: [String: Any]) {
        guard let _ = message["UpdateAccountKey"] else {
            return
        }
        
        guard let data = message["UpdateAccountDataKey"] as? Data else {
            AccountManager.shared.logout()
            NotificationCenter.default.post(name: .ReceiveAccountUpdate, object: nil)
            return
        }
        let decoder = JSONDecoder()
        guard let account = try? decoder.decode(UserAccount.self, from: data) else {
            AccountManager.shared.logout()
            NotificationCenter.default.post(name: .ReceiveAccountUpdate, object: nil)
            return
        }
        AccountManager.shared.login(account: account)
        NotificationCenter.default.post(name: .ReceiveAccountUpdate, object: account)
    }
    
    func handleSeatReservation(message: [String: Any]) {
        guard let _ = message["SeatUpdateCurrentReservationKey"] else {
            return
        }
        guard let data = message["SeatUpdateCurrentReservationDataKey"] as? Data else {
            NotificationCenter.default.post(name: .ReceiveReservationUpdate, object: nil)
            return
        }
        let decoder = JSONDecoder()
        if let reservation = try? decoder.decode(SeatReservation.self, from: data) {
            NotificationCenter.default.post(name: .ReceiveReservationUpdate, object: reservation)
        }else{
            print("Failed to decode reservation data")
            NotificationCenter.default.post(name: .ReceiveReservationUpdate, object: nil)
        }
    }
    
}
