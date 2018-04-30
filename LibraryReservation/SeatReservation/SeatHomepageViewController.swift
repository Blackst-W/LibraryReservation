//
//  SeatHomepageViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

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
    var isLogining = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = nil
        modalPresentationStyle = .formSheet
        reminderView.alpha = 0
        
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshStateChanged), for: .valueChanged)
        contentScrollView.refreshControl = control
        
        historyManager = SeatHistoryManager(delegate: self)
        reminderViewDisplayConstraint.constant = 0
        view.layoutIfNeeded()
        if let reservation = historyManager.current {
            currentReservationView.update(reservation: reservation)
            showReminder()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(accountChanged(notification:)), name: .AccountChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newReservedSuccess(notification:)), name: .SeatReserved, object: nil)
        // Do any additional setup after loading the view.
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: currentReservationView)
        }
        historyManager.checkCurrent()
    }
    
    @objc func refreshStateChanged() {
        if contentScrollView.refreshControl!.isRefreshing {
            historyManager.reload()
            historyManager.checkCurrent()
        }
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
    
    @objc func newReservedSuccess(notification: Notification) {
        historyManager.reload()
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
        showIndicator()
        autoLogin(delegate: self)
    }
    
    @IBAction func newReservation(_ sender: Any) {
        guard AccountManager.isLogin else {
            autoLogin(delegate: self)
            return
        }
        let storyboard = UIStoryboard(name: "SeatStoryboard", bundle: nil)
        let naviController = storyboard.instantiateViewController(withIdentifier: "SeatReservationNaviViewController") as! UINavigationController
        present(naviController, animated: true, completion: nil)
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

    
    @IBAction func displayDetail(_ sender: UITapGestureRecognizer) {
        guard let reservation = historyManager.current else {
            return
        }
        let viewController = SeatCurrentReservationDetailTableViewController.makeFromStoryboard()
        viewController.reservation = reservation
        viewController.updateTitle()
        navigationController?.pushViewController(viewController, animated: true)
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
        let count = historyManager.history.count
        if count == 0 && AccountManager.isLogin {
            historyEmptyLabel.isHidden = false
        }else if count != 0 {
            historyEmptyLabel.isHidden = true
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCell", for: indexPath) as! SeatHistoryCollectionViewCell
        cell.update(reservation: historyManager.history[indexPath.item])
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: cell)
        }
        return cell
    }
    
}

extension SeatHomepageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let reservation = historyManager.history[indexPath.item]
        let viewController = SeatHistoryDetailViewController.makeFromStoryboard()
        viewController.reservation = reservation
        navigationController?.pushViewController(viewController, animated: true)
        return
    }
}

extension SeatHomepageViewController: LoginViewDelegate {
    func loginResult(result: LoginResult) {
        isLogining = false
        switch result {
        case .cancel:
            showLoginView()
            currentReservationView.endCanceling()
            contentScrollView.refreshControl?.endRefreshing()
        case .success(_):
            showIndicator()
        }
    }
}

extension SeatHomepageViewController: SeatBaseDelegate {
    func requireLogin() {
        if isLogining {
            return
        }
        currentReservationView.endCanceling()
        autoLogin(delegate: self, force: false)
    }
    
    func updateFailed(error: Error) {
        let alertController = UIAlertController(title: "Failed To Update".localized, message: error.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
        contentScrollView.refreshControl?.endRefreshing()
    }
    
    func updateFailed(failedResponse: SeatFailedResponse) {
        if failedResponse.code == "12" && !isLogining {
            currentReservationView.endCanceling()
            autoLogin(delegate: self)
            return
        }
        let alertController = UIAlertController(title: "Failed To Update".localized, message: failedResponse.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
        contentScrollView.refreshControl?.endRefreshing()
    }
}

extension SeatHomepageViewController: SeatHistoryManagerDelegate {
    func update(current: SeatCurrentReservationRepresentable?) {
        NotificationManager.shared.schedule(reservation: current)
        if let reservation = current {
            currentReservationView.update(reservation: reservation)
            showReminder()
        }else{
            if !currentReservationView.showingCancelEffect {
                hideReminder(animated: true)
            }
        }
        contentScrollView.refreshControl?.endRefreshing()
    }
    
    
    func update(reservations: [SeatReservation]) {
        collectionView.reloadData()
        contentScrollView.refreshControl!.endRefreshing()
//        contentScrollView.refreshControl!.perform(#selector(contentScrollView.refreshControl!.endRefreshing), with: nil, afterDelay: 0.5)
    }
}

extension SeatHomepageViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let sourceCell = previewingContext.sourceView as? SeatHistoryCollectionViewCell {
            let indexPath = collectionView.indexPath(for: sourceCell)!
            let reservation = historyManager.history[indexPath.item]
            let viewController = SeatHistoryDetailViewController.makeFromStoryboard()
            viewController.reservation = reservation
            viewController.preferredContentSize = CGSize(width: 0, height: 0)
            return viewController
        }else if let _ = previewingContext.sourceView as? SeatCurrentReservationView {
            guard let reservation = historyManager.current else {
                return nil
            }
            let viewController = SeatCurrentReservationDetailTableViewController.makeFromStoryboard()
            viewController.reservation = reservation
            viewController.updateTitle()
            viewController.previewDelegate = self
            return viewController
        }else{
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let reservationController = viewControllerToCommit as? SeatCurrentReservationDetailTableViewController {
            reservationController.previewDelegate = nil
        }
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

extension SeatHomepageViewController: SeatReservationPreviewDelegate {
    func handle(error: Error) {
        currentReservationView.endCanceling()
        updateFailed(error: error)
    }
    func handle(failedResponse: SeatFailedResponse) {
        currentReservationView.endCanceling()
        updateFailed(failedResponse: failedResponse)
    }
    func handleStartCancel() {
        currentReservationView.startCanceling()
    }
}
