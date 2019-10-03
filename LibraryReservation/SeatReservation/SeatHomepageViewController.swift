//
//  SeatHomepageViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import PKHUD

protocol SeatReserveAgainDelegate {
    func haveTouchReserveAgainButton(historyReservation: SeatReservation)
}

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
    
    @IBOutlet weak var loginShadowView: UIView!
    @IBOutlet weak var loginVisualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var reserveAgainButton: UIButton!
    @IBOutlet weak var dismissControl: UIControl!
    @IBOutlet weak var dismissBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var timePickerView: UIPickerView!
    @IBOutlet weak var timelineView: UIStackView!
    @IBOutlet weak var timeLineStartLabel: UILabel!
    @IBOutlet weak var timeLineEndLabel: UILabel!
    @IBOutlet weak var timeLibraryLabel: UILabel!
    @IBOutlet weak var timeFloorLabel: UILabel!
    @IBOutlet weak var timeRoomLabel: UILabel!
    @IBOutlet weak var timeSeatLabel: UILabel!
    @IBOutlet weak var timeShadowView: UIView!
    
    private let reminderHeight: CGFloat = 168
    
    var isLogining = false
    var historyManager = SeatReservationManager.shared
    
    var seatManager: SeatReserveManager!
    var seatHistoryManager: SeatHistoryManager!
    var timePickerManager: SeatTimePicker!
    var timeFilterManager: SeatTimeFilter!
    var timeFilterPickerView: UIPickerView!
    
    var selectedReservation: SeatReservation?
    var date: Date!
    var seat: Seat?
    var layoutData: RoomLayoutData?
    
    var isShowingTimePickerView: Bool {
        get {
            if dismissControl.alpha != 0 {
                return true
            } else {
                return false
            }
        }
        set {
            if newValue {
                dismissControl.isHidden = false
                dismissControl.alpha = 0
                reserveAgainButton.setTitle("Reserve".localized, for: .normal)
                self.reserveAgainButton.backgroundColor = #colorLiteral(red: 0, green: 0.5019607843, blue: 1, alpha: 1)
                UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
                    self.dismissControl.alpha = 0.5
                    self.timeViewBottomConstraint.constant = 0.0
                    }.startAnimation()
            } else {
                let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
                    self.dismissControl.alpha = 0
                    self.timeViewBottomConstraint.constant = 700.0
                }
                animator.addCompletion { (_) in
                    self.dismissControl.isHidden = true
                }
                animator.startAnimation()
            }
        }
    }
    
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
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: currentReservationView)
        }
        
        updateTheme(false)
        
        collectionView.reloadData()
        historyManager.refresh { (response) in
            self.handle(response: response)
        }
        
        seatManager = SeatReserveManager()
        seatHistoryManager = SeatHistoryManager()
        
        date = Date()
        let calender = Calendar.current
        let hour = calender.component(.hour, from: date)
        let minute = calender.component(.minute, from: date)
        let reserveDateComponents = AppSettings.shared.libraryConfiguration.reserveTimeComponents
        if hour > reserveDateComponents.hour! {
            date = date.addingTimeInterval(24 * 60 * 60)
        } else if hour == reserveDateComponents.hour!,
            minute >= reserveDateComponents.minute! {
            date = date.addingTimeInterval(24 * 60 * 60)
        }
        
        setupPicker()
        setupFilter()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "ViewAllHistory" {
            let dst = segue.destination as! SeatHistoryViewController
            dst.manager = historyManager
        }
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
    
    @IBAction func displayDetail(_ sender: UITapGestureRecognizer) {
        guard let reservation = historyManager.reservation else {
            return
        }
        let viewController = SeatCurrentReservationDetailTableViewController.makeFromStoryboard()
        viewController.reservation = reservation
        viewController.updateTitle()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func dismissReserveView(_ sender: Any) {
        isShowingTimePickerView = false
    }
    
    @IBAction func reserve(_ sender: Any) {
        guard let (start, end) = timePickerManager.selectedTimes else {
            return
        }
        
        self.reserveAgainButton.setTitle("Processing".localized, for: .normal)
        
        if let currentReservation = historyManager.reservation {
            seatHistoryManager.cancel(reservation: currentReservation) { (response) in
                switch response {
                case .error(let error):
                    self.handle(error: error)
                case .failed(let fail):
                    self.handle(failedResponse: fail)
                case .requireLogin:
                    self.requireLogin()
                case .success(_):
                    self.update(reservation: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.seatManager.reserve(seat: self.seat!, date: self.date, start: start, end: end) {
                            (response) in
                            self.handle(response: response)
                        }
                    }
                }
            }
        } else {
            self.seatManager.reserve(seat: self.seat!, date: self.date, start: start, end: end) {
                (response) in
                self.handle(response: response)
            }

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
    
    func refreshAccount() {
        let setting = Settings.shared
        setting.set(savePassword: true)
        setting.set(autoLogin: true)
        autoLogin(delegate: self)
        
    }
    
    func updateTheme(_ animated: Bool) {
        //        contentScrollView.refreshControl?.tintColor = refreshTintColor
        let animation = {
            let configuration = ThemeConfiguration.current
            self.historyLoadingIndicator.tintColor = configuration.tintColor
            self.loginShadowView.backgroundColor = configuration.secondaryBackgroundColor
            self.loginVisualEffectView.effect = configuration.blurEffect
            self.reserveButton.setTitleColor(configuration.highlightTextColor, for: .normal)
            self.reserveButton.backgroundColor = configuration.tintColor
            self.labels.forEach({ (label) in
                label.textColor = configuration.textColor
            })
            self.buttons.forEach({ (button) in
                button.tintColor = configuration.tintColor
            })
            self.view.backgroundColor = configuration.backgroundColor
            let textAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: configuration.textColor]
            
            self.reserveAgainButton.setTitleColor(configuration.highlightTextColor, for: .normal)
            self.reserveAgainButton.backgroundColor = configuration.tintColor
            self.dismissControl.backgroundColor = configuration.deactiveColor
            self.timeShadowView.backgroundColor = configuration.secondaryBackgroundColor
            self.timePickerManager?.updateTheme()
//            self.timePickerView.tintColor = configuration.textColor
            
            self.navigationController?.navigationBar.barTintColor = configuration.barTintColor
            self.navigationController?.navigationBar.tintColor = configuration.tintColor
            self.navigationController?.navigationBar.barStyle = configuration.statusBarStyle
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
    
    func showIndicator() {
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
            self.loginButton.alpha = 0
        }
        animator.addCompletion { (_) in
            self.historyLoadingIndicator.startAnimating()
        }
        animator.startAnimation()
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
        cell.delegate = self
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

//Add by Morty
extension SeatHomepageViewController {
    func setupPicker() {
        timePickerManager = SeatTimePicker(pickerView: timePickerView, delegate: nil)
    }
    
    func setupFilter() {
        timeFilterManager = SeatTimeFilter()
    }
    
    func update(seat: Seat, start: [SeatTime]) {
        if start.isEmpty {
            HUD.flash(.label("Not Available Time For This Seat".localized), delay: 1.0)
            return
        }
        
        var totalStart: [SeatTime]!             //this Start will contain SeatTimes of the reservation you have reserved
        
        if selectedReservation?.id == historyManager.reservation?.id {
            let currentSeatTimes: [SeatTime] = historyManager.reservation!.seatTimes
            //the seatTime property will give the available time instead of the history data
            
            totalStart = start
            if !currentSeatTimes.isEmpty && !start.isEmpty {
                var index: Int = 0
                
                //sort function has a problem (about nil). so, use the insert function
                for seatTime in start {
                    let seatTimeId: Int!
                    if seatTime.id == "now" {
                        seatTimeId = 0
                    } else {
                        seatTimeId = seatTime.minutes!
                    }
                    
                    if seatTimeId < currentSeatTimes[0].minutes! {
                        if start.count == index + 1 {
                            totalStart += currentSeatTimes
                            break
                        } else if Int(start[index + 1].id)! > currentSeatTimes[0].minutes! {
                            totalStart.insert(contentsOf: currentSeatTimes, at: index + 1)
                            break
                        } else {
                            index += 1
                        }
                    } else {
                        totalStart = currentSeatTimes + start
                    }
                }
            }
        } else {
            totalStart = start
        }
        
        timePickerManager.update(startTimes: totalStart, filterStart: nil, filterEnd: nil)
        updateTimeViewLabels()
        updateTimeline(start: totalStart)
        isShowingTimePickerView = true
    }
    
    func updateTimeline(start: [SeatTime]) {
        var timelineActiveColor: UIColor!
        var timelineDeactiveColor: UIColor!
        let configuration = ThemeConfiguration.current
        timelineActiveColor = configuration.tintColor
        timelineDeactiveColor = configuration.deactiveColor
        timelineView.arrangedSubviews.forEach{ (view) in
            view.removeFromSuperview()}
        
        let allTimes = timeFilterManager.startTimes!
        timeLineStartLabel.text = allTimes[0].value
        timeLineEndLabel.text = timeFilterManager.endTimes!.last!.value
        var views = [UIView]()
        var heightConstraints = [NSLayoutConstraint]()
        for time in allTimes {
            let view = UIView()
            if start.contains(time) {
                view.backgroundColor = timelineActiveColor
                let constraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
                heightConstraints.append(constraint)
            } else {
                view.backgroundColor = timelineDeactiveColor
                let constraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15)
                heightConstraints.append(constraint)
            }
            views.append(view)
        }
        if start.first?.id == "now" {
            views.first?.backgroundColor = timelineActiveColor
            heightConstraints[0].constant = 30
        }
        views.forEach{ (view) in
            timelineView.addArrangedSubview(view)
        }
        NSLayoutConstraint.activate(heightConstraints)
    }
}

extension SeatHomepageViewController: SeatReserveAgainDelegate {

    func haveTouchReserveAgainButton(historyReservation: SeatReservation) {
        self.startLoading()
        selectedReservation = historyReservation
        fetchInformation(from: historyReservation)
    }
    
    func fetchInformation(from reservation: SeatReservation) {
        if let location = reservation.location {
            let room: Room!
            
            let libraryManager = SeatLibraryManager()
            let roomData = libraryManager.libraryData[location.library]
            
            if let roomIndex = roomData.firstIndex(where: {return $0.name == location.room}){
                room = roomData[roomIndex]
                seatManager.check(room: room, date: date) {
                    self.handle(response: $0)
                    //get the seat information in the handle if success
                }
            }
        }
    }
    
    func fetchSeatInfo(from layoutData: RoomLayoutData) {
        for seat in layoutData.seats {
            if Int(seat.name) == selectedReservation?.location?.seat {
                self.seat = seat
                seatManager.check(seat: seat, date: date) {
                    self.handle(response: $0)
                }
                break
            }
        }
    }
    
    func reserveAgainSuccess() {
        self.view.isUserInteractionEnabled = false
        
        UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.reserveAgainButton.setTitle("Reserve Success".localized, for: .normal)
            self.reserveAgainButton.backgroundColor = #colorLiteral(red: 0.3882352941, green: 0.8549019608, blue: 0.2196078431, alpha: 1)
        }.startAnimation()
        
        self.refreshStateChanged()
        self.historyManager.refresh() { (response) in
            self.handle(response: response)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isShowingTimePickerView = false
            self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func handle(response: SeatResponse<(seat: Seat, start: [SeatTime])>) {
        switch response {
        case .error(let error):
            handle(error: error)
        case .failed(let fail):
            handle(failedResponse: fail)
        case .requireLogin:
            requireLogin()
        case .success(let data):
            update(seat: data.seat, start: data.start)
        }
        self.endLoading()
    }
    
    func handle(response: SeatResponse<RoomLayoutData>) {
        switch response {
        case .error(let error):
            let alertController = UIAlertController(title: "Failed To Update".localized, message: error.localizedDescription, preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
            alertController.addAction(closeAction)
            present(alertController, animated: true, completion: nil)
        case .failed(let failed):
            let alertController = UIAlertController(title: "Failed To Update".localized, message: failed.localizedDescription, preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
            alertController.addAction(closeAction)
            present(alertController, animated: true, completion: nil)
        case .requireLogin:
            requireLogin()
        case .success(let layoutData):
            self.layoutData = layoutData
            self.fetchSeatInfo(from: layoutData)
        }
    }
    
    func handle(response: SeatResponse<Void>) {
        switch response {
        case .error(let error):
            handle(error: error)
        case .failed(let fail):
            handle(failedResponse: fail)
        case .requireLogin:
            requireLogin()
        case .success(_):
            reserveAgainSuccess()
        }
    }
}

extension SeatHomepageViewController {
    func updateTimeViewLabels() {
        timeLibraryLabel.text = selectedReservation?.location?.library.rawValue
        timeRoomLabel.text = selectedReservation?.location?.room
        timeFloorLabel.text = "Floor".localized(arguments: (selectedReservation?.location!.floor)!)
        timeSeatLabel.text = "SeatNo".localized(arguments: seat!.name)
    }
}

extension SeatHomepageViewController {
    func startLoading() {
        HUD.show(.systemActivity)
    }
    
    func endLoading() {
        HUD.hide()
    }
}
