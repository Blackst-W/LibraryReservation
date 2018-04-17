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
}
