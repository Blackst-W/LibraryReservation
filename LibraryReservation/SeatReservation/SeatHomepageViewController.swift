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
    
    @IBOutlet weak var reserveButton: UIButton!
    
    @IBOutlet var labels: [UILabel]!
    
    @IBOutlet var buttons: [UIButton]!
    
    private let reminderHeight: CGFloat = 168
    
    var historyManager = SeatReservationManager.shared
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
        
        reminderViewDisplayConstraint.constant = 0
        view.layoutIfNeeded()
        if let reservation = historyManager.reservation {
            currentReservationView.update(reservation: reservation)
            showReminder()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(accountChanged(notification:)), name: .AccountLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accountChanged(notification:)), name: .AccountLogout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reserveSuccess(notification:)), name: .ReserveSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleThemeChanged), name: .ThemeChanged, object: nil)
        // Do any additional setup after loading the view.
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: currentReservationView)
        }
        updateTheme(false)
        collectionView.reloadData()
        historyManager.refresh { (response) in
            self.handle(response: response)
        }
    }
    
    @objc func handleThemeChanged() {
        updateTheme(true)
        collectionView.visibleCells.forEach { (cell) in
            guard let cell = cell as? SeatHistoryCollectionViewCell else {
                return
            }
            cell.updateTheme(true)
        }
    }
    
    @IBOutlet weak var loginShadowView: UIView!
    
    func updateTheme(_ animated: Bool) {
        let theme = ThemeSettings.shared.theme
        var backgroundColor: UIColor!
        var navigationBarTintColor: UIColor?
        var navigationTintColor: UIColor?
        var navigationTitleColor: UIColor!
//        var refreshTintColor: UIColor!
        var labelColor: UIColor!
        var buttonTintColor: UIColor!
        var reserveButtonColor: UIColor!
        var statusBarStyle: UIBarStyle!
        var indicatorColor: UIColor!
        var loginShadowViewColor: UIColor!
        switch theme {
        case .black:
            labelColor = .white
            backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1137254902, alpha: 1)
            navigationBarTintColor = .black
            navigationTintColor = #colorLiteral(red: 0.9019607843, green: 0.5803921569, blue: 0.137254902, alpha: 1)
//            refreshTintColor = #colorLiteral(red: 0.9019607843, green: 0.5803921569, blue: 0.137254902, alpha: 1)
            buttonTintColor = #colorLiteral(red: 0.9019607843, green: 0.5803921569, blue: 0.137254902, alpha: 1)
            reserveButtonColor = #colorLiteral(red: 0.9019607843, green: 0.5803921569, blue: 0.137254902, alpha: 1)
            indicatorColor = #colorLiteral(red: 0.9019607843, green: 0.5803921569, blue: 0.137254902, alpha: 1)
            navigationTitleColor = .white
            statusBarStyle = .black
            loginShadowViewColor = .black
        case .standard:
            labelColor = .black
            backgroundColor = .white
            navigationBarTintColor = nil
            navigationTintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
//            refreshTintColor = #colorLiteral(red: 0.4274509804, green: 0.4274509804, blue: 0.4470588235, alpha: 1)
            buttonTintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            reserveButtonColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            indicatorColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            navigationTitleColor = .black
            statusBarStyle = .default
            loginShadowViewColor = .white
        }
//        contentScrollView.refreshControl?.tintColor = refreshTintColor
        
        let animation = {
            self.historyLoadingIndicator.tintColor = indicatorColor
            self.loginShadowView.backgroundColor = loginShadowViewColor
            self.reserveButton.backgroundColor = reserveButtonColor
            self.labels.forEach({ (label) in
                label.textColor = labelColor
            })
            self.buttons.forEach({ (button) in
                button.tintColor = buttonTintColor
            })
            self.view.backgroundColor = backgroundColor
            let textAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: navigationTitleColor]
            
            self.navigationController?.navigationBar.barTintColor = navigationBarTintColor
            self.navigationController?.navigationBar.tintColor = navigationTintColor
            self.navigationController?.navigationBar.barStyle = statusBarStyle
            self.navigationController?.navigationBar.titleTextAttributes = textAttributes
            if #available(iOS 11.0, *) {
                self.navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
            }
            self.navigationController?.navigationBar.layoutIfNeeded()
        }
        if animated {
            UIViewPropertyAnimator(duration: 1, curve: .linear, animations: animation).startAnimation()
        }else{
            animation()
        }
    }
    
    @objc func refreshStateChanged() {
        if contentScrollView.refreshControl!.isRefreshing {
            historyManager.refresh { (response) in
                self.handle(response: response)
            }
        }
    }
    
    @objc func reserveSuccess(notification: Notification) {
        historyManager.refresh { (response) in
            self.handle(response: response)
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
            self.historyManager.refresh(callback: { (response) in
                self.handle(response: response)
            })
        }
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
        guard let reservation = historyManager.reservation else {
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
        let count = historyManager.historys.count
        if count == 0 && AccountManager.isLogin {
            historyEmptyLabel.isHidden = false
        }else if count != 0 {
            historyEmptyLabel.isHidden = true
        }
        return min(count, 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCell", for: indexPath) as! SeatHistoryCollectionViewCell
        cell.update(reservation: historyManager.historys[indexPath.item])
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: cell)
        }
        return cell
    }
    
}

extension SeatHomepageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let reservation = historyManager.historys[indexPath.item]
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

extension SeatHomepageViewController {
    func requireLogin() {
        if isLogining {
            return
        }
        currentReservationView.endCanceling()
        autoLogin(delegate: self, force: false)
    }
    
    func handle(error: Error) {
        let alertController = UIAlertController(title: "Failed To Update".localized, message: error.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
        contentScrollView.refreshControl?.endRefreshing()
    }
    
    func handle(failedResponse: SeatFailedResponse) {
        let alertController = UIAlertController(title: "Failed To Update".localized, message: failedResponse.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
        contentScrollView.refreshControl?.endRefreshing()
    }
}

extension SeatHomepageViewController {
    
    func handle(response: SeatResponse<SeatReservation?>) {
        switch response {
        case .success(let reservation):
            hideLoginView()
            update(reservation: reservation)
            update(reservations: historyManager.historys)
        case .error(let error):
            handle(error: error)
        case .failed(let fail):
            handle(failedResponse: fail)
        case .requireLogin:
            requireLogin()
        }
    }
    
    func update(reservation: SeatReservation?) {
        if let reservation = reservation {
            currentReservationView.update(reservation: reservation)
            showReminder()
        }else{
            hideReminder(animated: true)
        }
        contentScrollView.refreshControl?.endRefreshing()
    }
    
    func update(reservations: [SeatReservation]) {
        collectionView.reloadData()
        contentScrollView.refreshControl!.endRefreshing()
    }
}

extension SeatHomepageViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let sourceCell = previewingContext.sourceView as? SeatHistoryCollectionViewCell {
            let indexPath = collectionView.indexPath(for: sourceCell)!
            let reservation = historyManager.historys[indexPath.item]
            let viewController = SeatHistoryDetailViewController.makeFromStoryboard()
            viewController.reservation = reservation
            viewController.preferredContentSize = CGSize(width: 0, height: 0)
            return viewController
        }else if let _ = previewingContext.sourceView as? SeatCurrentReservationView {
            guard let reservation = historyManager.reservation else {
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
    func handle(_ previewObject: Any, cancelResponse response: SeatResponse<Void>) {
        switch response {
        case .error(let error):
            currentReservationView.endCanceling()
            handle(error: error)
        case .failed(let fail):
            handle(failedResponse: fail)
            currentReservationView.endCanceling()
        case .requireLogin:
            currentReservationView.endCanceling()
            requireLogin()
        case .success(_):
            currentReservationView.showCancelEffect()
            break
        }
    }
    
    func handleCancel(_ previewObject: Any) {
        currentReservationView.startCanceling()
    }
}
