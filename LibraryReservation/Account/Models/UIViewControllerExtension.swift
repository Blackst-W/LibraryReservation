//
//  UIViewControllerExtension.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/17.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentLoginViewController(delegate: LoginViewDelegate? = nil) {
        let storyboard = UIStoryboard(name: "AccountStoryboard", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! UINavigationController
        viewController.modalPresentationStyle = .formSheet
        let loginViewController = viewController.viewControllers.first! as! LoginViewController
        loginViewController.delegate = delegate
        present(viewController, animated: true, completion: nil)
    }
    
    
    /// Perform auto login silently in the background
    /// if both account and password found and Auto-Login is on
    ///
    /// - Parameters:
    ///   - delegate: receive login result
    ///   - force: Login anyway even if account or password is not found,
    ///            will present login view
    func autoLogin(delegate: LoginViewDelegate?, force: Bool = true) {
        guard let account = AccountManager.shared.currentAccount,
            let password = account.password,
            Settings.shared.autoLogin else {
                //display login view even if not login or password not saved or Auto-Login is disable.
                if force {
                    presentLoginViewController(delegate: delegate)
                } else {
                    delegate?.loginResult(result: .cancel)
                }
                
                return
        }
        //Silence login with found username and password
        let username = account.username
        SeatBaseNetworkManager.default.login(username: username, password: password) { (response) in
            switch response {
            case .error(_), .failed(_), .requireLogin:
                DispatchQueue.main.async {
                    self.presentLoginViewController(delegate: delegate)
                }
            case .success(let login):
                let account = UserAccount(username: username, password: password, token: login.data.token)
                AccountManager.shared.login(account: account)
                DispatchQueue.main.async {
                    delegate?.loginResult(result: .success(account))
                }
            }
        }
    }
    
}
