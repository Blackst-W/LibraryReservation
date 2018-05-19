//
//  SeatCurrentReservationDetailTableViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/19.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

protocol SeatReservationPreviewDelegate: class {
    func handleCancel(_ previewObject: Any)
    func handle(_ previewObject: Any, cancelResponse: SeatResponse<Void>)
}

class SeatCurrentReservationDetailTableViewController: UITableViewController {

    var reservation: SeatReservation!
    weak var previewDelegate: SeatReservationPreviewDelegate?
    
    @IBOutlet weak var fullLocationLabel: UILabel!
    @IBOutlet weak var libraryLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var seatLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusTimeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var reservationIDLabel: UILabel!
    @IBOutlet weak var seatIDLabel: UILabel!
    @IBOutlet weak var receiptLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet var labels: [UILabel]!
    
    
    var manager: SeatReservationManager!
    
    class func makeFromStoryboard() -> SeatCurrentReservationDetailTableViewController {
        let storyboard = UIStoryboard(name: "SeatStoryboard", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ReservationDetailViewController") as! SeatCurrentReservationDetailTableViewController
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = SeatReservationManager.shared
        reservation = manager.reservation
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTheme()
    }
    
    func updateTheme() {
        let configuration = ThemeConfiguration.current
        labels.forEach { (label) in
            label.textColor = configuration.textColor
        }
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.updateLocation()
            self.updateTime()
            self.updateOther()
            self.updateTitle()
        }
    }
    
    func updateTitle() {
        var title = "Current Reservation".localized
        switch reservation.currentState {
        case .late(_):
            title = "Lated Reservation".localized
        case .ongoing(_):
            title = "Ongoing Reservation".localized
        case .tempAway(_):
            title = "Paused Reservation".localized
        case .upcoming(_):
            title = "Upcoming Reservation".localized
        case .autoEnd(_):
            title = "Ending Reservation".localized
        case .invalid:
            title = "Unknown Reservation".localized
        }
        self.title = title
        let cancelTitle = reservation.isStarted ? "Stop Reservation".localized : "Cancel Reservation".localized
        cancelButton?.setTitle(cancelTitle, for: .normal)
        
    }
    
    func updateLocation() {
        fullLocationLabel.text = reservation.location?.detail ?? reservation.rawLocation
        if let location = reservation.location {
            libraryLabel.text = location.library.rawValue
            floorLabel.text = "Floor".localized(arguments: location.floor)
            roomLabel.text = location.room
            seatLabel.text = "SeatNo".localized(arguments: String(location.seat))
        }
    }
    
    func updateTime() {
        statusLabel.text = reservation.currentState.localizedState
        timeLabel.text = "\(reservation.rawBegin) - \(reservation.rawEnd)"
        switch reservation.currentState {
        case .upcoming(let next):
            let hour = next / 60
            let min = next % 60
            let hourString = hour == 0 ? "" : "h".localized(arguments: hour)
            let minString = "mins".localized(arguments: min)
            statusTimeLabel.text = "Start In".localized(arguments: hourString, minString)
        case .ongoing(let remain):
            let hour = remain / 60
            let min = remain % 60
            let hourString = hour == 0 ? "" : "h".localized(arguments: hour)
            let minString = "mins".localized(arguments: min)
            statusTimeLabel.text = "End In".localized(arguments: hourString, minString)
        case .tempAway(let remain):
            let minString = "mins".localized(arguments: remain)
            statusTimeLabel.text = "Expire In".localized(arguments: minString)
        case .late(let remain):
            let minString = "mins".localized(arguments: remain)
            statusTimeLabel.text = "Expire In".localized(arguments: minString)
        case .autoEnd(let remain):
            let minString = "mins".localized(arguments: remain)
            statusTimeLabel.text = "Auto End In".localized(arguments: minString)
        case .invalid:
            statusTimeLabel.text = "Pull To Refresh".localized
        }
        dateLabel.text = reservation.rawDate
        let duration = reservation.time.duration
        let hour = duration / 60
        let minute = duration % 60
        let hourText = hour == 0 ? "" : "h".localized(arguments: hour)
        let minuteText = minute == 0 ? "" : "mins".localized(arguments: minute)
        durationLabel.text = [hourText, minuteText].joined(separator: " ")
        messageLabel.text = reservation.time.message
    }

    func updateOther() {
        reservationIDLabel.text = String(reservation.id)
        seatIDLabel.text = String(reservation.seatID) ?? "-"
        receiptLabel.text = reservation.receiptID ?? "-"
    }
    
    @IBAction func requireCancel(_ sender: Any) {
        let alertController = UIAlertController(title: "Cancel Reservation".localized, message: "Are you sure to cancel this reservation?".localized, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm".localized, style: .destructive) { (_) in
            self.manager.cancel() { (response) in
                self.handle(cancelResponse: response)
            }
            self.cancelButton.isEnabled = false
        }
        let cancelAction = UIAlertAction(title: "Back".localized, style: .cancel, handler: nil)
        alertController.addActions([cancelAction, confirmAction])
        present(alertController, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var previewActionItems: [UIPreviewActionItem] {
        
        let copyAction = UIPreviewAction(title: "Copy Location".localized, style: .default) { (_, _) in
            UIPasteboard.general.string = self.reservation.rawLocation
        }
        let confirmCancelAction = UIPreviewAction(title: "Confirm".localized, style: .destructive) { (_, viewController) in
            self.previewDelegate?.handleCancel(self)
            self.manager.cancel() { (response) in
                self.previewDelegate?.handle(self, cancelResponse: response)
            }
        }
        
        let cancelAction = UIPreviewAction(title: "Back".localized, style: .default) { (_, _) in
            return
        }
        let cancelTitle = reservation.isStarted ? "Stop Reservation".localized : "Cancel Reservation".localized
        
        let cancelGroup = UIPreviewActionGroup(title: cancelTitle, style: .destructive, actions: [confirmCancelAction, cancelAction])
        
        return [copyAction, cancelGroup]
    }
    
    @IBAction func refreshStateChanged(_ sender: UIRefreshControl) {
        guard sender.isRefreshing else {
            return
        }
        manager.refresh { (response) in
            self.handle(refreshResponse: response)
        }
    }

}

extension SeatCurrentReservationDetailTableViewController {
    
    func handle(cancelResponse: SeatResponse<Void>) {
        switch cancelResponse {
        case .error(let error):
            handle(error: error)
        case .failed(let fail):
            handle(failedResponse: fail)
        case .requireLogin:
            requireLogin()
        case .success(_):
            update(reservation: nil)
        }
    }
    
    func handle(refreshResponse: SeatResponse<SeatReservation?>) {
        switch refreshResponse {
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
        refreshControl?.endRefreshing()
        let alertController = UIAlertController(title: "Failed To Update".localized, message: error.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
        cancelButton.isEnabled = true
    }
    
    func handle(failedResponse: SeatFailedResponse) {
        refreshControl?.endRefreshing()
        let alertController = UIAlertController(title: "Failed To Update".localized, message: failedResponse.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
        cancelButton.isEnabled = true
    }

    func update(reservation: SeatReservation?) {
//        NotificationManager.shared.schedule(reservation: current)
//        WatchAppDelegate.shared.transferSeatReservation()
        refreshControl?.endRefreshing()
        guard let reservation = reservation else {
            //Reservation Not Exist
            navigationController?.popViewController(animated: true)
            return
        }
        self.reservation = reservation
        cancelButton.isEnabled = true
        updateUI()
    }
    
    func requireLogin() {
        autoLogin(delegate: self)
    }
}

extension SeatCurrentReservationDetailTableViewController: LoginViewDelegate {
    func loginResult(result: LoginResult) {
        switch result {
        case .cancel:
            refreshControl?.endRefreshing()
            cancelButton.isEnabled = true
        case .success(_):
            return
        }
    }
}
