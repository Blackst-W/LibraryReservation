//
//  WatchAppDelegate.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/05/01.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import WatchConnectivity

class WatchAppDelegate: NSObject {
    var session: WCSession?
    static let shared = WatchAppDelegate()
    override private init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(accountLogin(notification:)), name: .AccountLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accountLogout), name: .AccountLogout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(settingsChanged), name: .SettingsChanged, object: nil)
    }
    
    func setup() {
        guard WCSession.isSupported() else {
            return
        }
        session = WCSession.default
        session!.delegate = self
        session!.activate()
    }
    
    @objc func settingsChanged() {
        transferSettings()
    }
    
    @objc func accountLogout() {
        transfer(account: nil)
    }
    
    @objc func accountLogin(notification: Notification) {
        guard let account = notification.userInfo?["NewAccount"] as? UserAccount else {
            transfer(account: nil)
            return
        }
        transfer(account: account)
    }
    
    func transfer(reservation: SeatReservation?) {
        guard let session = session, session.isPaired, session.isWatchAppInstalled else {
            return
        }
        
        if session.isReachable {
            var context: [String: Any] = [:]
            context["SeatUpdateCurrentReservationKey"] = true
            context["SeatUpdateCurrentReservationDataKey"] = reservation?.jsonData
            session.sendMessage(context, replyHandler: nil) { error in
                print(error.localizedDescription)
            }
        }else{
            do {
                var previousContext = session.applicationContext
                previousContext["SeatUpdateCurrentReservationKey"] = true
                previousContext["SeatUpdateCurrentReservationKey"] = reservation?.jsonData
                try session.updateApplicationContext(previousContext)
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    func transferSettings() {
        guard let session = session, session.isPaired, session.isWatchAppInstalled else {
            return
        }
        let settings = Settings.shared
        let data = try? JSONEncoder().encode(settings)
        if session.isReachable {
            var context: [String: Any] = [:]
            context["UpdateSettingsKey"] = true
            context["UpdateSettingsDataKey"] = data
            session.sendMessage(context, replyHandler: nil) { error in
                print(error.localizedDescription)
            }
        }else{
            do {
                var previousContext = session.applicationContext
                previousContext["UpdateSettingsKey"] = true
                previousContext["UpdateSettingsDataKey"] = data
                try session.updateApplicationContext(previousContext)
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    func transfer(account: UserAccount?) {
        guard let session = session, session.isPaired, session.isWatchAppInstalled else {
            return
        }
        if session.isReachable {
            var context: [String: Any] = [:]
            context["UpdateAccountKey"] = true
            if let account = account {
                context["UpdateAccountDataKey"] = try? JSONEncoder().encode(account)
            }else{
                context["UpdateAccountDataKey"] = nil
            }
            session.sendMessage(context, replyHandler: nil) { error in
                print(error.localizedDescription)
            }
        }else{
            do {
                var previousContext = session.applicationContext
                previousContext["UpdateAccountKey"] = true
                if let account = account {
                    previousContext["UpdateAccountDataKey"] = try? JSONEncoder().encode(account)
                }else{
                    previousContext["UpdateAccountDataKey"] = nil
                }
                try session.updateApplicationContext(previousContext)
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
}

extension WatchAppDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated, .inactive:
            break
        case .notActivated:
            print(error!.localizedDescription)
            return
        }
        transferSettings()
        transfer(account: AccountManager.shared.currentAccount)
        transfer(reservation: SeatReservationManager.shared.reservation)
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        return
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        return
    }
    
}
