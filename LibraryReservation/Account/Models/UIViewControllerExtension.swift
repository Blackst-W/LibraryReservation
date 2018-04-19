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
    /// if both account and password found
    ///
    /// - Parameters:
    ///   - delegate: receive login result
    ///   - force: Login anyway even if account or password is not found,
    ///            will present login view
    func autoLogin(delegate: LoginViewDelegate?, force: Bool = false) {
        guard let account = AccountManager.shared.currentAccount,
            let password = account.password else {
                if force {
                    //display login view even if not login or password not saved.
                    presentLoginViewController(delegate: delegate)
                }else{
                    //Cancel login if not account or password found
                    delegate?.loginResult(result: .cancel)
                }
                return
        }
        //Silence login with found username and password
        let username = account.username
        SeatBaseNetworkManager.default.login(username: username, password: password) { (error, loginResponse, failResponse) in
            if let loginResponse = loginResponse {
                let account = UserAccount(username: username, password: password, token: loginResponse.data.token)
                AccountManager.shared.login(account: account)
                DispatchQueue.main.async {
                    delegate?.loginResult(result: .success(account))
                }
            }else{
                DispatchQueue.main.async {
                    self.presentLoginViewController(delegate: delegate)
                }
            }
        }
    }
    
}
