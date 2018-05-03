//
//  SettingTableViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sidLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountChanged()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        NotificationCenter.default.addObserver(self, selector: #selector(accountChanged), name: .AccountChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userInfoChanged), name: .UserInfoUpdated, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func accountChanged() {
        DispatchQueue.main.async {
            if AccountManager.isLogin {
                self.nameLabel.text = AccountManager.shared.userInfo?.name ??  "Loading...".localized
                self.sidLabel.text = AccountManager.shared.currentAccount?.username
            }else{
                self.nameLabel.text = "Tap To Login".localized
                self.sidLabel.text = ""
            }
        }
    }
    
    @objc func userInfoChanged() {
        DispatchQueue.main.async {
            self.nameLabel.text = AccountManager.shared.userInfo?.name ??  "Loading...".localized
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            if AccountManager.isLogin {
                let storyboard = UIStoryboard(name: "SettingsStoryboard", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "AccountDetailViewController")
                navigationController?.pushViewController(viewController, animated: true)
            }else{
                autoLogin(delegate: self)
            }
        case 1:
            break
        default:
            return
        }
        switch indexPath.row {
        case 0:
            return
        case 1:
            tableView.deselectRow(at: indexPath, animated: true)
            let mailController = MFMailComposeViewController()
            mailController.setToRecipients(["feedback@westonwu.com"])
            mailController.setSubject("Feedback For WHU Seat Reservation iOS App")
            mailController.setMessageBody("Please description your feedback here.", isHTML: false)
            mailController.mailComposeDelegate = self
            present(mailController, animated: true, completion: nil)
        default:
            return
        }
    }
    
    @IBAction func pressDoneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    //
    //    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        // #warning Incomplete implementation, return the number of rows
    //        return 0
    //    }
    
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
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension SettingsTableViewController: LoginViewDelegate {
    func loginResult(result: LoginResult) {
        switch result {
        case .cancel:
            return
        case .success(_):
            let storyboard = UIStoryboard(name: "SettingsStoryboard", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "AccountDetailViewController")
            navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
}

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
