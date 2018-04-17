//
//  SeatHomepageViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class SeatHomepageViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reminderView: UIView!
    @IBOutlet weak var reminderHeightConstraint: NSLayoutConstraint!
    var manager: SeatHomepageManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .formSheet
        manager = SeatHomepageManager(delegate: self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = nil
        reminderHeightConstraint.constant = 0
        reminderView.alpha = 0
        let hasUpcomingReservation = true
        if hasUpcomingReservation {
            UIView.animate(withDuration: 1) {
                self.reminderHeightConstraint.constant = 160
                self.reminderView.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
        
        // Do any additional setup after loading the view.
    }

    func hideReminder(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 1) {
                self.reminderHeightConstraint.constant = 0
                self.reminderView.alpha = 0
                self.view.layoutIfNeeded()
            }
        }else{
            reminderHeightConstraint.constant = 0
            reminderView.alpha = 0
        }
    }
    
    func showReminder() {
        UIView.animate(withDuration: 1) {
            self.reminderHeightConstraint.constant = 160
            self.reminderView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension SeatHomepageViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension SeatHomepageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            presentLoginViewController(delegate: self)
        default:
            break
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        return
    }
}

extension SeatHomepageViewController: LoginViewDelegate {
    func loginResult(result: LoginResult) {
        switch  result {
        case .cancel:
            return
        case .success(let account):
            manager.update(account: account)
            return
        }
    }
}

extension SeatHomepageViewController: SeatHomepageManagerDelegate {
    
}
