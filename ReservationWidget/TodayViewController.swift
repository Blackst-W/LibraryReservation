//
//  TodayViewController.swift
//  ReservationWidget
//
//  Created by Weston Wu on 2018/04/30.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import SeatKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var loginButton: UIButton!
    var historyManager: SeatHistoryManager!
    
    @IBOutlet weak var reservationView: UIView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateInfoLabel: UILabel!
    @IBOutlet weak var libraryLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var seatLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertBody: UILabel!
    @IBOutlet weak var alertButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        historyManager = SeatHistoryManager(delegate: self)
        historyManager.reload()
        refreshButton.isEnabled = false
        if let reservation = historyManager.current {
            updateUI(reservation: reservation)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        Settings.shared.reload()
        AccountManager.shared.reload()
        historyManager.checkCurrent()
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func updateUI(reservation: SeatCurrentReservationRepresentable) {
        loginButton.isHidden = true
        alertView.isHidden = true
        reservationView.isHidden = false
        if let location = reservation.location {
            libraryLabel.text = location.library.rawValue
            roomLabel.text = location.room
            seatLabel.text = "SeatNo".localized(arguments: String(location.seat))
            floorLabel.text = "Floor".localized(arguments: location.floor)
        }
        timeLabel.text = "\(reservation.rawBegin) - \(reservation.rawEnd)"
        stateLabel.text = reservation.currentState.localizedState
        switch reservation.currentState {
        case .upcoming(let next):
            let hour = next / 60
            let min = next % 60
            let hourString = hour == 0 ? "": "h".localized(arguments: hour)
            let minString = "mins".localized(arguments: min)
            stateInfoLabel.text = "Start In".localized(arguments: hourString, minString)
        case .ongoing(let remain):
            let hour = remain / 60
            let min = remain % 60
            let hourString = hour == 0 ? "": "\("h".localized(arguments: hour))"
            let minString = " \("mins".localized(arguments: min))"
            stateInfoLabel.text = "End In".localized(arguments: hourString, minString)
        case .tempAway(let remain):
            let minString = " \("mins".localized(arguments: remain))"
            stateInfoLabel.text = "Expire In".localized(arguments: minString)
        case .late(let remain):
            let minString = " \("mins".localized(arguments: remain))"
            stateInfoLabel.text = "Expire In".localized(arguments: minString)
        case .autoEnd(let remain):
            let minString = " \("mins".localized(arguments: remain))"
            stateInfoLabel.text = "Auto End In".localized(arguments: minString)
        case .invalid:
            stateInfoLabel.text = "Please Refresh First".localized
        }
        refreshButton.setTitle("Refresh".localized, for: .normal)
    }
    
    @IBAction func login(_ sender: Any) {
        extensionContext?.open(URL(string: "whuseat://login")!, completionHandler: nil)
    }
    
    @IBAction func refresh(_ sender: Any) {
        historyManager.checkCurrent()
        refreshButton.isEnabled = false
    }
    
    @IBAction func retryButton(_ sender: Any) {
        if alertButton.tag == 10 {
            extensionContext?.open(URL(string: "whuseat://")!, completionHandler: nil)
            return
        }else{
            historyManager.checkCurrent()
            alertButton.isEnabled = false
        }
    }
    
    var canLogin: Bool {
        guard let account = AccountManager.shared.currentAccount,
           let _ = account.password else {
            return false
        }
        return true
    }
    
    func autoLogin() {
        guard let account = AccountManager.shared.currentAccount,
            let password = account.password else {
                refreshButton.isEnabled = true
                alertButton.isEnabled = true
                loginButton.isHidden = false
                alertView.isHidden = true
                reservationView.isHidden = true
                return
        }
        let username = account.username
        SeatBaseNetworkManager.default.login(username: username, password: password) { (error, loginResponse, failResponse) in
            if let loginResponse = loginResponse {
                let account = UserAccount(username: username, password: password, token: loginResponse.data.token)
                AccountManager.shared.login(account: account)
                self.historyManager.reload()
            }else{
                DispatchQueue.main.async {
                    self.refreshButton.isEnabled = true
                    self.alertButton.isEnabled = true
                    self.loginButton.isHidden = false
                    self.alertView.isHidden = true
                    self.reservationView.isHidden = true
                }
            }
        }

    }
    
}

extension TodayViewController: SeatHistoryManagerDelegate {
    func requireLogin() {
        if canLogin {
            autoLogin()
            return
        }
        refreshButton.isEnabled = true
        alertButton.isEnabled = true
        loginButton.isHidden = false
        alertView.isHidden = true
        reservationView.isHidden = true
        return
    }
    
    func updateFailed(error: Error) {
        refreshButton.isEnabled = true
        alertButton.isEnabled = true
        alertButton.tag = 0
        alertBody.text = error.localizedDescription
        loginButton.isHidden = true
        alertView.isHidden = false
        reservationView.isHidden = true
        return
    }
    
    func updateFailed(failedResponse: SeatFailedResponse) {
        if failedResponse.code == "12" {
            requireLogin()
            return
        }
        refreshButton.isEnabled = true
        alertButton.isEnabled = true
        alertButton.tag = 0
        alertBody.text = failedResponse.localizedDescription
        loginButton.isHidden = true
        alertView.isHidden = false
        reservationView.isHidden = true
        return
    }
    
    func update(reservations: [SeatReservation]) {
        refreshButton.isEnabled = true
        alertButton.isEnabled = true
        return
    }
    
    func update(current: SeatCurrentReservationRepresentable?) {
        refreshButton.isEnabled = true
        alertButton.isEnabled = true
        guard let reservation = current else {
            alertTitle.text = "Not Reservation Found".localized
            alertBody.text = "Go make a reservation in the app and check back later.".localized
            alertButton.setTitle("Reserve".localized, for: .normal)
            alertButton.tag = 10
            reservationView.isHidden = true
            alertView.isHidden = false
            loginButton.isHidden = true
            return
        }
        updateUI(reservation: reservation)
        return
    }
}


