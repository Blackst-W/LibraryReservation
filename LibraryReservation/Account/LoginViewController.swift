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
    var sidEditable = false
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
            if !sidEditable {
                sidTextField.isUserInteractionEnabled = false
            }
            if account.password == nil {
                passwordTextField.becomeFirstResponder()
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTheme()
    }
    @IBOutlet var labels: [UILabel]!
    
    func updateTheme() {
        let configuration = ThemeConfiguration.current
        loginButton.tintColor = configuration.tintColor
        loginButton.setTitleColor(configuration.highlightTextColor, for: .normal)
        loginButton.backgroundColor = configuration.tintColor
        if sidTextField.isUserInteractionEnabled {
            sidTextField.textColor = configuration.textColor
        }else{
            sidTextField.textColor = configuration.deactiveColor
        }
        passwordTextField.textColor = configuration.textColor
        sidTextField.attributedPlaceholder = NSAttributedString(string: sidTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : configuration.deactiveColor])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : configuration.deactiveColor])
        labels.forEach { (label) in
            label.textColor = configuration.textColor
        }
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
        
        SeatBaseNetworkManager.default.login(username: username, password: password) { (response) in
            var errorDescription = "Unknown Error".localized
            switch response {
            case .success(let loginResponse):
                let account = UserAccount(username: username, password: password, token: loginResponse.data.token)
                AccountManager.shared.login(account: account)
                DispatchQueue.main.async {
                    self.delegate?.loginResult(result: .success(account))
                    self.dismiss(animated: true, completion: nil)
                }
                return
            case .error(let error):
                errorDescription = error.localizedDescription
            case .failed(let fail):
                errorDescription = fail.localizedDescription
            case .requireLogin:
                fatalError()
            }
            let alertController = UIAlertController(title: "Login Failed".localized, message: errorDescription, preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
            alertController.addAction(closeAction)
            DispatchQueue.main.async {
                self.loginButton.isEnabled = true
                self.present(alertController, animated: true, completion: nil)
            }
        }
        loginButton.isEnabled = false
    }
    
    func checkSID() -> Bool {
        let result = sidTextField.text!.isEmpty
        if result {
            let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                self.sidLabel.textColor = ThemeConfiguration.current.warnColor
            }
            animator.startAnimation()
        }
        return !result
    }
    
    func checkPassword() -> Bool {
        let result = passwordTextField.text!.isEmpty
        if result {
            let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                self.passwordLabel.textColor = ThemeConfiguration.current.warnColor
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
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == sidTextField {
            let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                self.sidLabel.textColor = ThemeConfiguration.current.textColor
            }
            animator.startAnimation()
        }else{
            let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
                self.passwordLabel.textColor = ThemeConfiguration.current.textColor
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
