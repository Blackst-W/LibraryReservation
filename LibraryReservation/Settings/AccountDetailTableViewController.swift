//
//  AccountDetailTableViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class AccountDetailTableViewController: UITableViewController {

    var account: UserAccount! {
        didSet {
            sidLabel.text = account.username
            tokenLabel.text = account.token ?? "-"
            view.layoutIfNeeded()
        }
    }
    
    @IBOutlet weak var sidLabel: UILabel!
    
    @IBOutlet weak var tokenLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var violationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var signoutButton: UIButton!
    
    @IBOutlet weak var savePasswordSwitch: UISwitch!
    
    @IBOutlet weak var autoLoginSwitch: UISwitch!
    
    @IBOutlet var labels: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        account = AccountManager.shared.currentAccount!
        let settings = Settings.shared
        savePasswordSwitch.isOn = settings.savePassword
        autoLoginSwitch.isOn = settings.autoLogin
        userInfoUpdated()
        NotificationCenter.default.addObserver(self, selector: #selector(userInfoUpdated), name: .UserInfoUpdated, object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        refreshButton.tintColor = configuration.tintColor
        refreshButton.backgroundColor = configuration.tintColor
        refreshButton.setTitleColor(configuration.highlightTextColor, for: .normal)
        signoutButton.tintColor = configuration.warnColor
        signoutButton.backgroundColor = configuration.warnColor
        signoutButton.setTitleColor(configuration.highlightTextColor, for: .normal)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func userInfoUpdated() {
        DispatchQueue.main.async {
            let userInfo = AccountManager.shared.userInfo
            self.nameLabel.text = userInfo?.name ?? "-"
            self.statusLabel.text = userInfo?.status ?? "-"
            if let violationCount = userInfo?.violationCount {
                self.violationLabel.text = String(violationCount)
            }else{
                self.violationLabel.text = "-"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let settings = Settings.shared
        settings.set(savePassword: savePasswordSwitch.isOn)
        settings.set(autoLogin: autoLoginSwitch.isOn)
    }
    
    @IBAction func savePasswordSettingsChanged(_ sender: UISwitch) {
        if !sender.isOn {
            autoLoginSwitch.setOn(false, animated: true)
        }else if account.password == nil {
            let settings = Settings.shared
            settings.set(savePassword: savePasswordSwitch.isOn)
            settings.set(autoLogin: autoLoginSwitch.isOn)
            autoLogin(delegate: self)
        }
    }
    
    @IBAction func autoLoginSettingsChanged(_ sender: UISwitch) {
        if sender.isOn {
            savePasswordSwitch.setOn(true, animated: true)
            savePasswordSettingsChanged(savePasswordSwitch)
        }
    }
    
    @IBAction func refreshAccount(_ sender: Any) {
        let settings = Settings.shared
        settings.set(savePassword: savePasswordSwitch.isOn)
        settings.set(autoLogin: autoLoginSwitch.isOn)
        autoLogin(delegate: self)
        refreshButton.isEnabled = false
    }
    
    @IBAction func logoutAccount(_ sender: Any) {
        let alertController = UIAlertController(title: "Confirm Sign Out".localized, message: "Are you sure to sign out?\nAll data related to this account would be erased.".localized, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Sign Out".localized, style: .destructive) { (_) in
            AccountManager.shared.logout()
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        alertController.addActions([cancelAction, confirmAction])
        present(alertController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AccountDetailTableViewController: LoginViewDelegate {
    func loginResult(result: LoginResult) {
        refreshButton.isEnabled = true
        let settings = Settings.shared
        savePasswordSwitch.isOn = settings.savePassword
        autoLoginSwitch.isOn = settings.autoLogin
        switch result {
        case .cancel:
            if account.password == nil {
                savePasswordSwitch.setOn(false, animated: true)
                savePasswordSettingsChanged(savePasswordSwitch)
            }
            return
        case .success(let account):
            self.account = account
        }
    }
}
