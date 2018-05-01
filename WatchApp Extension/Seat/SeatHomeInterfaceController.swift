//
//  SeatHomeInterfaceController.swift
//  WatchApp Extension
//
//  Created by Weston Wu on 2018/05/01.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import WatchKit
import Foundation
import WatchSeatKit

class SeatHomeInterfaceController: WKInterfaceController {
    
    
    @IBOutlet var notReservationLabel: WKInterfaceLabel!
    @IBOutlet var reservationGroup: WKInterfaceGroup!
    @IBOutlet var stateLabel: WKInterfaceLabel!
    @IBOutlet var stateTimeTimer: WKInterfaceTimer!
    @IBOutlet var libraryLabel: WKInterfaceLabel!
    @IBOutlet var floorLabel: WKInterfaceLabel!
    @IBOutlet var roomLabel: WKInterfaceLabel!
    @IBOutlet var seatLabel: WKInterfaceLabel!
    @IBOutlet var startTimeLabel: WKInterfaceLabel!
    @IBOutlet var endTimeLabel: WKInterfaceLabel!
    
    @IBOutlet var refreshButton: WKInterfaceButton!
    var historyManager: SeatHistoryManager!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        historyManager = SeatHistoryManager(delegate: self)
        historyManager.reload()
        self.updateUI(reservation: ExtensionDelegate.current.currentSeatReservation)
        NotificationCenter.default.addObserver(self, selector: #selector(reservationChanged(notification:)), name: .CurrentSeatReservationChanged, object: nil)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @objc func reservationChanged(notification: Notification) {
        if WKExtension.shared().applicationState == .active {
            DispatchQueue.main.async {
                self.updateUI(reservation: ExtensionDelegate.current.currentSeatReservation)
            }
        }
        historyManager.reload()
    }
    
    func updateUI(reservation: SeatCurrentReservationRepresentable?) {
        if let reservation = reservation {
            notReservationLabel.setHidden(true)
            reservationGroup.setHidden(false)
            stateLabel.setText(reservation.currentState.localizedState)
            if let location = reservation.location {
                libraryLabel.setText(location.library.rawValue.localized)
                roomLabel.setText(location.room)
                seatLabel.setText("No.".localized(arguments: String(location.seat)))
                floorLabel.setText("Floor".localized(arguments: location.floor))
            }
            startTimeLabel.setText(reservation.rawBegin)
            endTimeLabel.setText(reservation.rawEnd)
            switch reservation.currentState {
            case .upcoming(_):
                stateTimeTimer.setDate(reservation.time.start)
            case .ongoing(_), .autoEnd(_):
                stateTimeTimer.setDate(reservation.time.end)
            case .tempAway(let remain):
                let expireDate = Date().addingTimeInterval(TimeInterval(remain * 60))
                stateTimeTimer.setDate(expireDate)
            case .late(let remain):
                let expireDate = Date().addingTimeInterval(TimeInterval(remain * 60))
                stateTimeTimer.setDate(expireDate)
            case .invalid:
                stateTimeTimer.setDate(reservation.time.start)
            }
        }else{
            notReservationLabel.setHidden(false)
            reservationGroup.setHidden(true)
        }
    }
    
    @IBAction func refreshReservation() {
        historyManager.reload()
        refreshButton.setEnabled(false)
        refreshButton.setTitle("Refreshing...".localized)
    }
    
    @IBAction func viewHistory() {
        pushController(withName: "SeatHistoryInterfaceController", context: historyManager.history)
    }
    
}

extension SeatHomeInterfaceController: SeatHistoryManagerDelegate {
    func update(reservations: [SeatReservation]) {
        return
    }
    
    func update(current: SeatCurrentReservationRepresentable?) {
        updateUI(reservation: current)
        refreshButton.setEnabled(true)
        refreshButton.setTitle("Refresh".localized)
    }
    
    func requireLogin() {
        guard let account = AccountManager.shared.currentAccount,
            let password = account.password else {
                DispatchQueue.main.async {
                    let dismissAction = WKAlertAction(title: "Dismiss".localized, style: .cancel, handler: {})
                    self.presentAlert(withTitle: "Login On iPhone".localized, message: "Please login on your iPhone or enable save-password in the iPhone App".localized, preferredStyle: .alert, actions: [dismissAction])
                    self.refreshButton.setEnabled(true)
                    self.refreshButton.setTitle("Refresh".localized)
                }
            return
        }
        SeatBaseNetworkManager.default.login(username: account.username, password: password) { (error, loginResponse, failedResponse) in
            if let error = error {
                DispatchQueue.main.async {
                    self.updateFailed(error: error)
                    return
                }
            }
            if let failResponse = failedResponse {
                DispatchQueue.main.async {
                    self.refreshButton.setEnabled(true)
                    self.refreshButton.setTitle("Refresh".localized)
                    let dismissAction = WKAlertAction(title: "Dismiss".localized, style: .cancel, handler: {})
                    self.presentAlert(withTitle: "Failed To Refresh".localized, message: failResponse.localizedDescription, preferredStyle: .alert, actions: [dismissAction])
                    return
                }
            }
            guard let _ = loginResponse?.data.token else {
                DispatchQueue.main.async {
                    self.refreshButton.setEnabled(true)
                    self.refreshButton.setTitle("Refresh".localized)
                    let dismissAction = WKAlertAction(title: "Dismiss".localized, style: .cancel, handler: {})
                    self.presentAlert(withTitle: "Failed To Refresh".localized, message: SeatAPIError.unknown.localizedDescription, preferredStyle: .alert, actions: [dismissAction])
                    return
                }
                return
            }
            self.historyManager.reload()
        }
    }
    
    func updateFailed(error: Error) {
        refreshButton.setEnabled(true)
        refreshButton.setTitle("Refresh".localized)
        let dismissAction = WKAlertAction(title: "Dismiss".localized, style: .cancel, handler: {})
        presentAlert(withTitle: "Failed To Refresh".localized, message: error.localizedDescription, preferredStyle: .alert, actions: [dismissAction])
    }
    
    func updateFailed(failedResponse: SeatFailedResponse) {
        if failedResponse.code == "12" {
            requireLogin()
            return
        }
        let dismissAction = WKAlertAction(title: "Dismiss".localized, style: .cancel, handler: {})
        presentAlert(withTitle: "Failed To Refresh".localized, message: failedResponse.localizedDescription, preferredStyle: .alert, actions: [dismissAction])
        refreshButton.setEnabled(true)
        refreshButton.setTitle("Refresh".localized)
    }
    
    
}

