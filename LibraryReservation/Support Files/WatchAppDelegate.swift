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
        NotificationCenter.default.addObserver(self, selector: #selector(accountChanged), name: .AccountChanged, object: nil)
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
    
    @objc func accountChanged() {
        transferAccount()
    }
    
    func transferSeatReservation() {
        guard let session = session, session.isPaired, session.isWatchAppInstalled else {
            return
        }
        
        let historyManager = SeatHistoryManager(delegate: nil)
        if session.isReachable {
            var context: [String: Any] = [:]
            context["SeatUpdateCurrentReservationKey"] = true
            context["SeatUpdateCurrentReservationDataKey"] = historyManager.current?.jsonData
            session.sendMessage(context, replyHandler: nil) { error in
                print(error.localizedDescription)
            }
        }else{
            do {
                var previousContext = session.applicationContext
                previousContext["SeatUpdateCurrentReservationKey"] = true
                previousContext["SeatUpdateCurrentReservationKey"] = historyManager.current?.jsonData
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
    
    func transferAccount() {
        guard let session = session, session.isPaired, session.isWatchAppInstalled else {
            return
        }
        let account = AccountManager.shared.currentAccount
        if session.isReachable {
            var context: [String: Any] = [:]
            context["UpdateAccountKey"] = true
            context["UpdateAccountDataKey"] = try? JSONEncoder().encode(account)
            session.sendMessage(context, replyHandler: nil) { error in
                print(error.localizedDescription)
            }
        }else{
            do {
                var previousContext = session.applicationContext
                previousContext["UpdateAccountKey"] = true
                previousContext["UpdateAccountDataKey"] = try? JSONEncoder().encode(account)
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
        transferAccount()
        transferSeatReservation()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        return
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        return
    }
    
}
