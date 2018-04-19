//
//  SeatHomepageViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import MJRefresh

class SeatHomepageViewController: UIViewController {

    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var historyLoadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var historyEmptyLabel: UILabel!
    
    @IBOutlet weak var currentReservationView: SeatCurrentReservationView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reminderView: UIView!
    @IBOutlet weak var reminderViewDisplayConstraint: NSLayoutConstraint!
    
    private let reminderHeight: CGFloat = 168
    
    var historyManager: SeatHistoryManager!
    var reservationManager: SeatCurrentReservationManager!
    var isLogining = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = nil
        modalPresentationStyle = .formSheet
        reminderView.alpha = 0
        historyManager = SeatHistoryManager(delegate: self)
        reservationManager = SeatCurrentReservationManager(delegate: self)
        reminderViewDisplayConstraint.constant = 0
        view.layoutIfNeeded()
        if let reservation = reservationManager.reservation {
            currentReservationView.update(reservation: reservation)
            showReminder()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(accountChanged(notification:)), name: .AccountChanged, object: nil)
        // Do any additional setup after loading the view.
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))!
        header.lastUpdatedTimeLabel.isHidden = true
        header.stateLabel.isHidden = true
        contentScrollView.mj_header = header
        contentScrollView.mj_header.beginRefreshing()
    }
    
    @objc func refresh() {
        historyManager.update()
        reservationManager.update()
    }

    @objc func accountChanged(notification: Notification) {
        DispatchQueue.main.async {
            guard AccountManager.isLogin else {
                self.showLoginView()
                self.hideReminder(animated: false)
                return
            }
            self.showIndicator()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        historyManager.delegate = self
    }
    
    func hideReminder(animated: Bool) {
        if reminderView.isHidden {
            return
        }
        if animated {
            UIView.animate(withDuration: 1, animations: {
                self.reminderViewDisplayConstraint.constant = 0
                self.reminderView.alpha = 0
                self.view.layoutIfNeeded()
            }) { (_) in
                self.reminderView.isHidden = true
            }
        }else{
            reminderViewDisplayConstraint.constant = 0
            reminderView.alpha = 0
            reminderView.isHidden = true
        }
    }
    
    func showReminder() {
        
        if reminderViewDisplayConstraint.constant == reminderHeight {
            return
        }
        
        reminderView.isHidden = false
        reminderView.alpha = 0
        UIView.animate(withDuration: 1) {
            self.reminderViewDisplayConstraint.constant = self.reminderHeight
            self.reminderView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    func showLoginView() {
        self.collectionView.isHidden = true
        self.loginView.isHidden = false
        historyLoadingIndicator.stopAnimating()
        loginButton.alpha = 1
        let animator = UIViewPropertyAnimator(duration: 1, curve: .easeOut) {
            self.loginButton.alpha = 1
            self.loginView.alpha = 1
        }
        animator.startAnimation()
    }
    
    func showIndicator() {
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
            self.loginButton.alpha = 0
        }
        animator.addCompletion { (_) in
            self.historyLoadingIndicator.startAnimating()
        }
        animator.startAnimation()
    }
    
    func hideLoginView() {
        self.collectionView.isHidden = false
        self.historyLoadingIndicator.stopAnimating()
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            self.loginView.alpha = 0
        }
        animator.addCompletion { (_) in
            self.loginView.isHidden = true
        }
        animator.startAnimation()
    }
    
    
    
    @IBAction func login(_ sender: Any) {
        isLogining = true
        let settings = Settings.shared
        if settings.savePassword && settings.autoLogin {
            showIndicator()
            autoLogin(delegate: self, force: true)
        }else{
            showIndicator()
            presentLoginViewController(delegate: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "ViewAllHistory" {
            let dst = segue.destination as! SeatHistoryViewController
            dst.manager = historyManager
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

extension SeatHomepageViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if historyLoadingIndicator.isAnimating {
            hideLoginView()
        }
        return historyManager.validReservations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCell", for: indexPath) as! SeatHistoryCollectionViewCell
        cell.update(reservation: historyManager.validReservations[indexPath.item])
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: cell)
        }
        return cell
    }
    
}

extension SeatHomepageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let reservation = historyManager.reservations[indexPath.item]
        let viewController = SeatHistoryDetailViewController.makeFromStoryboard()
        viewController.reservation = reservation
        navigationController?.pushViewController(viewController, animated: true)
        return
    }
}

extension SeatHomepageViewController: LoginViewDelegate {
    func loginResult(result: LoginResult) {
        isLogining = false
        switch  result {
        case .cancel:
            showLoginView()
        case .success(_):
            showIndicator()
        }
        historyManager.loginResult(result: result)
        reservationManager.loginResult(result: result)
    }
}

extension SeatHomepageViewController: SeatBaseDelegate {
    func requireLogin() {
        if isLogining {
            return
        }
        let settings = Settings.shared
        if settings.savePassword && settings.autoLogin {
            //perform auto login
            if isLogining {
                return
            }
            isLogining = true
            autoLogin(delegate: self)
        }else{
            if historyManager.reservations.isEmpty {
                hideReminder(animated: false)
                showLoginView()
                contentScrollView.mj_header.endRefreshing()
            }
        }
    }
    
    func updateFailed(error: Error) {
        let alertController = UIAlertController(title: "Failed To Update", message: error.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
        contentScrollView.mj_header.endRefreshing()
    }
    
    func updateFailed(failedResponse: SeatFailedResponse) {
        if failedResponse.code == "12" && !isLogining {
            autoLogin(delegate: self, force: true)
            return
        }
        let alertController = UIAlertController(title: "Failed To Update", message: failedResponse.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
        contentScrollView.mj_header.endRefreshing()
    }
}

extension SeatHomepageViewController: SeatCurrentReservationManagerDelegate {
    func update(reservation: SeatCurrentReservation?) {
        if let reservation = reservation {
            currentReservationView.update(reservation: reservation)
            showReminder()
        }else{
            hideReminder(animated: true)
        }
        contentScrollView.mj_header?.endRefreshing()
    }
}

extension SeatHomepageViewController: SeatHistoryManagerDelegate {
    
    func update(reservations: [SeatHistoryReservation]) {
        if reservations.isEmpty && AccountManager.isLogin {
            historyEmptyLabel.isHidden = false
        }else if !reservations.isEmpty {
            historyEmptyLabel.isHidden = true
        }
        collectionView.reloadData()
        contentScrollView.mj_header?.endRefreshing()
    }
    
    func loadMore() {
        collectionView.reloadData()
    }
    
}

extension SeatHomepageViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let sourceCell = previewingContext.sourceView as? SeatHistoryCollectionViewCell {
            let indexPath = collectionView.indexPath(for: sourceCell)!
            let reservation = historyManager.reservations[indexPath.item]
            let viewController = SeatHistoryDetailViewController.makeFromStoryboard()
            viewController.reservation = reservation
            viewController.preferredContentSize = CGSize(width: 0, height: 0)
            return viewController
        }else{
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
