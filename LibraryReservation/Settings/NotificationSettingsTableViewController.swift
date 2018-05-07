//
//  NotificationSettingsTableViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/27.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationSettingsTableViewController: UITableViewController {

    @IBOutlet weak var notificationSwitch: UISwitch!
    
    @IBOutlet weak var seatReserveSwitch: UISwitch!
    @IBOutlet weak var seatUpcomingSwitch: UISwitch!
    @IBOutlet weak var seatEndSwitch: UISwitch!
    @IBOutlet weak var seatAwaySwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationSettings = Settings.shared.notificationSettings
        notificationSwitch.setOn(notificationSettings.enable, animated: false)
        seatReserveSwitch.setOn(notificationSettings.seat.make, animated: false)
        seatUpcomingSwitch.setOn(notificationSettings.seat.upcoming, animated: false)
        seatEndSwitch.setOn(notificationSettings.seat.end, animated: false)
        seatAwaySwitch.setOn(notificationSettings.seat.tempAway, animated: false)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let newSettings = SeatNotificationSettings(make: seatReserveSwitch.isOn, upcoming: seatUpcomingSwitch.isOn, end: seatEndSwitch.isOn, tempAway: seatAwaySwitch.isOn)
        Settings.shared.update(seatSettings: newSettings)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if Settings.shared.notificationSettings.enable {
            return 2
        }else {
            return 1
        }
        
    }
    
    
    @IBAction func notificationSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                DispatchQueue.main.async {
                    switch settings.authorizationStatus {
                    case .denied, .notDetermined:
                        self.notificationAlert()
                        Settings.shared.disableNotification()
                        sender.setOn(false, animated: true)
                    default:
                        Settings.shared.enableNotification()
                    }
                    self.tableView.reloadData()
                }
            }
        }else{
            Settings.shared.disableNotification()
            tableView.reloadData()
        }
    }
    
    func notificationAlert() {
        let alertController = UIAlertController(title: "Notification Was Disabled".localized, message: "Please go the \"Settings\" App and open the notification for this App".localized, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let setting = UIAlertAction(title: "Settings".localized, style: .default) { (_) in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }
        alertController.addActions([setting, cancel])
        present(alertController, animated: true, completion: nil)
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
