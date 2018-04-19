//
//  SeatCurrentReservationDetailTableViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/19.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class SeatCurrentReservationDetailTableViewController: UITableViewController {

    var reservation: SeatCurrentReservation!
    
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
    
    
    var manager: SeatCurrentReservationManager!
    
    class func makeFromStoryboard() -> SeatCurrentReservationDetailTableViewController {
        let storyboard = UIStoryboard(name: "SeatStoryboard", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ReservationDetailViewController") as! SeatCurrentReservationDetailTableViewController
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        updateUI()
        
        manager = SeatCurrentReservationManager(delegate: self)
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
        var title = "Current Reservation"
        switch reservation.currentState {
        case .late(_):
            title = "Lated Reservation"
        case .ongoing(_):
            title = "Ongoing Reservation"
        case .tempAway(_):
            title = "Paused Reservation"
        case .upcoming(_):
            title = "Upcoming Reservation"
        }
        self.title = title
        let cancelTitle = reservation.isStarted ? "Stop Reservation" : "Cancel Reservation"
        cancelButton.setTitle(cancelTitle, for: .normal)
        
    }
    
    func updateLocation() {
        fullLocationLabel.text = reservation.fullLocation
        if let location = reservation.location {
            libraryLabel.text = location.library.rawValue
            floorLabel.text = "\(location.floor)F"
            roomLabel.text = location.room
            seatLabel.text = "No.\(location.seat)"
        }
    }
    
    func updateTime() {
        statusLabel.text = reservation.currentState.localizedState
        timeLabel.text = "\(reservation.rawBegin) - \(reservation.rawEnd)"
        switch reservation.currentState {
        case .upcoming(let next):
            let hour = next / 60
            let min = next % 60
            statusTimeLabel.text = "Start in\(hour == 0 ? "": " \(hour)h") \(min)mins"
        case .ongoing(let remain):
            let hour = remain / 60
            let min = remain % 60
            statusTimeLabel.text = "End in\(hour == 0 ? "": " \(hour)h") \(min)mins"
        case .tempAway(let remain):
            statusTimeLabel.text = "Expire in \(remain)mins"
        case .late(let remain):
            statusTimeLabel.text = "EXpire in \(remain)mins"
        }
        dateLabel.text = reservation.rawDate
        let duration = reservation.duration
        let hour = duration / 60
        let minute = duration % 60
        let hourText = hour == 0 ? "" : "\(hour)h"
        let minuteText = minute == 0 ? "" : "\(minute)mins"
        durationLabel.text = [hourText, minuteText].joined(separator: " ")
        messageLabel.text = reservation.message
    }

    func updateOther() {
        reservationIDLabel.text = String(reservation.id)
        seatIDLabel.text = String(reservation.seatId)
        receiptLabel.text = reservation.receipt
    }
    
    @IBAction func requireCancel(_ sender: Any) {
        let alertController = UIAlertController(title: "Cancel Reservation", message: "Are you sure to cancel this reservation?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { (_) in
            self.manager.cancelReservation()
            self.cancelButton.isEnabled = false
        }
        let cancelAction = UIAlertAction(title: "Back", style: .cancel, handler: nil)
        alertController.addActions([cancelAction, confirmAction])
        present(alertController, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var previewActionItems: [UIPreviewActionItem] {
        
        let copyAction = UIPreviewAction(title: "Copy Location", style: .default) { (_, _) in
            UIPasteboard.general.string = self.reservation.fullLocation
        }
        let confirmCancelAction = UIPreviewAction(title: "Confirm", style: .destructive) { (_, viewController) in
            
//            self.manager.cancelReservation()
            NotificationCenter.default.post(name: .SeatReservationCancel, object: nil, userInfo: nil)
        }
        
        let cancelAction = UIPreviewAction(title: "Back", style: .default) { (_, _) in
            return
        }
        let cancelTitle = reservation.isStarted ? "Stop Reservation" : "Cancel Reservation"
        
        let cancelGroup = UIPreviewActionGroup(title: cancelTitle, style: .destructive, actions: [confirmCancelAction, cancelAction])
        
        return [copyAction, cancelGroup]
    }
    
    @IBAction func refreshStateChanged(_ sender: UIRefreshControl) {
        if sender.isRefreshing {
            manager.update()
        }
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SeatCurrentReservationDetailTableViewController: SeatCurrentReservationManagerDelegate {
    func updateFailed(error: Error) {
        refreshControl?.endRefreshing()
        let alertController = UIAlertController(title: "Failed To Update", message: error.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func updateFailed(failedResponse: SeatFailedResponse) {
        refreshControl?.endRefreshing()
        let alertController = UIAlertController(title: "Failed To Update", message: failedResponse.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func update(reservation: SeatCurrentReservation?) {
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
        autoLogin(delegate: self, force: true)
    }
}

extension SeatCurrentReservationDetailTableViewController: LoginViewDelegate {
    func loginResult(result: LoginResult) {
        switch result {
        case .cancel:
            refreshControl?.endRefreshing()
        case .success(_):
            manager.loginResult(result: result)
        }
    }
}
