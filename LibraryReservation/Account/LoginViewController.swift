//
//  LoginViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/17.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

enum LoginResult {
    case cancel
    case success(UserAccount)
}

protocol LoginViewDelegate: class {
    func loginResult(result: LoginResult)
}

class LoginViewController: UITableViewController {
    
    @IBOutlet weak var sidLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var sidTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var savePasswordSwitch: UISwitch!
    @IBOutlet weak var autoLoginSwitch: UISwitch!
    
    @IBOutlet weak var loginButton: UIButton!
    
    weak var delegate: LoginViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sidTextField.delegate = self
        passwordTextField.delegate = self
        
        let settings = Settings.shared
        savePasswordSwitch.setOn(settings.savePassword, animated: false)
        autoLoginSwitch.setOn(settings.autoLogin, animated: false)
        
        if let account = AccountManager.shared.currentAccount {
            sidTextField.text = account.username
            passwordTextField.text = account.password
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let settings = Settings.shared
        settings.set(savePassword: savePasswordSwitch.isOn)
        settings.set(autoLogin: autoLoginSwitch.isOn)
    }
    
    @IBAction func login() {
        
        sidTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        let sidState = checkSID()
        let passwordState = checkPassword()
        guard sidState && passwordState else {
            return
        }
        let username = sidTextField.text!
        let password = passwordTextField.text!
        
        let settings = Settings.shared
        settings.set(savePassword: savePasswordSwitch.isOn)
        settings.set(autoLogin: autoLoginSwitch.isOn)
        
        SeatBaseNetworkManager.default.login(username: username, password: password) { (error, loginResponse, failResponse) in
            
            if let loginResponse = loginResponse {
                let account = UserAccount(username: username, password: password, token: loginResponse.data.token)
                AccountManager.shared.login(account: account)
                DispatchQueue.main.async {
                    self.delegate?.loginResult(result: .success(account))
                    self.dismiss(animated: true, completion: nil)
                }
            }else{
                let errorDescription = error?.localizedDescription ?? failResponse?.localizedDescription ?? "Unknown Error".localized
                print(errorDescription)
                let alertController = UIAlertController(title: "Login Failed".localized, message: errorDescription, preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
                alertController.addAction(closeAction)
                DispatchQueue.main.async {
                    self.loginButton.isEnabled = true
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        loginButton.isEnabled = false
        
    }
    
    func checkSID() -> Bool {
        let result = sidTextField.text!.isEmpty
        if result {
            let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                self.sidLabel.textColor = .red
            }
            animator.startAnimation()
        }
        return !result
    }
    
    func checkPassword() -> Bool {
        let result = passwordTextField.text!.isEmpty
        if result {
            let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                self.passwordLabel.textColor = .red
            }
            animator.startAnimation()
        }
        return !result
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelLogin(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.loginResult(result: .cancel)
    }
    
    
    @IBAction func savePasswordSettingChanged(_ sender: UISwitch) {
        if !sender.isOn {
            autoLoginSwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func autoLoginSettingChanged(_ sender: UISwitch) {
        if sender.isOn {
            savePasswordSwitch.setOn(true, animated: true)
        }
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

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == sidTextField {
            let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                self.sidLabel.textColor = .black
            }
            animator.startAnimation()
        }else{
            let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                self.passwordLabel.textColor = .black
            }
            animator.startAnimation()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == sidTextField {
            passwordTextField.becomeFirstResponder()
        }else if savePasswordSwitch.isOn && autoLoginSwitch.isOn {
            login()
        }
        return true
    }
}
