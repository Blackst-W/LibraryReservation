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
    var seatManager: SeatReservationManager!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        seatManager = SeatReservationManager.shared
        self.update(reservation: seatManager.reservation)
        NotificationCenter.default.addObserver(self, selector: #selector(reservationUpdate(notification:)), name: .ReceiveReservationUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accountUpdate(notification:)), name: .ReceiveAccountUpdate, object: nil)
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
    
    func updateUI(reservation: SeatReservation?) {
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
        seatManager.refresh { (response) in
            self.handle(response: response)
        }
        refreshButton.setEnabled(false)
        refreshButton.setTitle("Refreshing...".localized)
    }
    
    @IBAction func viewHistory() {
        pushController(withName: "SeatHistoryInterfaceController", context: seatManager.historys)
    }
    
    @objc func accountUpdate(notification: Notification) {
        guard let _ = notification.object as? UserAccount else {
            updateUI(reservation: nil)
            return
        }
        seatManager.refresh { (response) in
            self.handle(response: response)
        }
    }
    
    @objc func reservationUpdate(notification: Notification) {
        DispatchQueue.main.async {
            self.update(reservation: notification.object as? SeatReservation)
        }
    }
}

extension SeatHomeInterfaceController {
    
    func update(reservation: SeatReservation?) {
        updateUI(reservation: reservation)
        refreshButton.setEnabled(true)
        refreshButton.setTitle("Refresh".localized)
        WKInterfaceDevice.current().play(.success)
    }
    
    func requireLogin() {
        guard let account = AccountManager.shared.currentAccount,
            let password = account.password else {
                DispatchQueue.main.async {
                    let dismissAction = WKAlertAction(title: "Dismiss".localized, style: .cancel, handler: {})
                    self.presentAlert(withTitle: "Login On iPhone".localized, message: "Please login on your iPhone or enable save-password in the iPhone App".localized, preferredStyle: .alert, actions: [dismissAction])
                    self.refreshButton.setEnabled(true)
                    self.refreshButton.setTitle("Refresh".localized)
                    WKInterfaceDevice.current().play(.failure)
                }
            return
        }
        SeatBaseNetworkManager.default.login(username: account.username, password: password) { (response) in
            switch response {
            case .error(let error):
                self.handle(error: error)
            case .failed(let fail):
                self.handle(failedResponse: fail)
            case .requireLogin:
                return
            case .success(let loginResponse):
                let token = loginResponse.data.token
                let account = UserAccount(username: account.username, password: password, token: token)
                AccountManager.shared.login(account: account)
                self.seatManager.refresh() { (response) in
                    self.handle(response: response)
                }
            }
        }
    }
    
    func handle(response: SeatResponse<SeatReservation?>) {
        switch response {
        case .error(let error):
            handle(error: error)
        case .failed(let fail):
            handle(failedResponse: fail)
        case .requireLogin:
            requireLogin()
        case .success(let reservation):
            update(reservation: reservation)
        }
    }
    
    func handle(error: Error) {
        refreshButton.setEnabled(true)
        refreshButton.setTitle("Refresh".localized)
        let dismissAction = WKAlertAction(title: "Dismiss".localized, style: .cancel, handler: {})
        presentAlert(withTitle: "Failed To Refresh".localized, message: error.localizedDescription, preferredStyle: .alert, actions: [dismissAction])
        WKInterfaceDevice.current().play(.failure)
    }
    
    func handle(failedResponse: SeatFailedResponse) {
        let dismissAction = WKAlertAction(title: "Dismiss".localized, style: .cancel, handler: {})
        presentAlert(withTitle: "Failed To Refresh".localized, message: failedResponse.localizedDescription, preferredStyle: .alert, actions: [dismissAction])
        refreshButton.setEnabled(true)
        refreshButton.setTitle("Refresh".localized)
        WKInterfaceDevice.current().play(.failure)
    }
    
    
}

