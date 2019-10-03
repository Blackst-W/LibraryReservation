//
//  SeatSelectionViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/20.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import PKHUD

protocol SeatSelectionViewDelegate: class {
    func select(seat: Seat, begin: Date, end: Date)
}

class SeatSelectionViewController: UIViewController {

    @IBOutlet weak var layoutView: UIView!
    @IBOutlet weak var layoutViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var layoutViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var computerControl: UIControl!
    @IBOutlet weak var computerLabel: UILabel!
    @IBOutlet weak var computerImageView: UIImageView!
    
    
    @IBOutlet weak var windowControl: UIControl!
    @IBOutlet weak var windowLabel: UILabel!
    @IBOutlet weak var windowImageView: UIImageView!
    
    @IBOutlet weak var powerControl: UIControl!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var powerImageView: UIImageView!
    
    
    @IBOutlet var dismissBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var dismissControl: UIControl!
    
    @IBOutlet weak var libraryNameLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var seatLabel: UILabel!
    @IBOutlet weak var reserveButton: UIButton!
    
    @IBOutlet weak var displayStyleControl: UISegmentedControl!
    
    var library: Library!
    var room: Room!
    var date: Date!
    var layoutData: RoomLayoutData?
    var manager: SeatReserveManager!
    var selectedSeat: Seat? {
        didSet {
            if let oldSeat = oldValue {
                let seatView = layoutView.viewWithTag(oldSeat.id) as! SeatCollectionView
                seatView.viewed()
            }
            if let newSeat = selectedSeat {
                let seatView = layoutView.viewWithTag(newSeat.id) as! SeatCollectionView
                seatView.selected()
            }
        }
    }
    
    weak var delegate: SeatSelectionViewDelegate?
    var filter = SeatFilterCondition()
    
    override func viewDidLoad() {
        manager = SeatReserveManager()
        PKHUD.sharedHUD.dimsBackground = false
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
        super.viewDidLoad()
        modalPresentationStyle = .formSheet
        title = room.name
        libraryNameLabel.text = library.rawValue
        floorLabel.text = "Floor".localized(arguments: room.floor)
        roomLabel.text = room.name
        scrollView.delegate = self
//        scrollView.setZoomScale(0.6, animated: false)
        manager.check(room: room, date: date) { (response) in
            self.handle(response: response)
        }
        startLoading()
        setupPicker()
        setupFilter()
        navigationController?.hidesBarsOnSwipe = true
        // Do any additional setup after loading the view.
        updateTheme()
    }
    
    var controlDefaultColor: UIColor!
    var controlHighlightColor: UIColor!
    var controlTextDefaultColor: UIColor!
    var controlTextHighlightColor: UIColor!
    
    @IBOutlet var legendViews: [UIView]!
    
    @IBOutlet var legendLabels: [UILabel]!
    
    @IBOutlet weak var reserveView: UIView!
    
    @IBOutlet weak var availableNowLegend: UIView!
    @IBOutlet weak var filterLegend: UIView!
    @IBOutlet weak var unavailableLegend: UIView!
    
    @IBOutlet var reserveLabels: [UILabel]!
    
    func updateTheme() {
        let configuration = ThemeConfiguration.current
        availableNowLegend.backgroundColor = configuration.seatAvailableNowColor
        filterLegend.backgroundColor = configuration.seatFilterColor
        unavailableLegend.backgroundColor = configuration.seatUnavailableColor
        timeFilterLabel.textColor = configuration.textColor
        controlHighlightColor = configuration.tintColor
        controlTextDefaultColor = configuration.tintColor
        controlTextHighlightColor = configuration.highlightTextColor
        controlDefaultColor = configuration.secondaryBackgroundColor
        timeFilterView.backgroundColor = configuration.secondaryBackgroundColor
        reserveView.backgroundColor = configuration.secondaryBackgroundColor
        dismissControl.backgroundColor = configuration.deactiveColor
        reserveButton.backgroundColor = configuration.tintColor
        changeTimeFilterButton.setTitleColor(configuration.tintColor, for: .normal)
        view.backgroundColor = configuration.backgroundColor
        legendViews.forEach { (view) in
            view.backgroundColor = configuration.secondaryBackgroundColor
        }
        legendLabels.forEach { (label) in
            label.textColor = configuration.textColor
        }
        reserveLabels.forEach { (label) in
            label.textColor = configuration.textColor
        }
        
        [computerControl, windowControl, powerControl].forEach { (control) in
            control?.backgroundColor = controlDefaultColor
        }
        
        [computerLabel, windowLabel, powerLabel].forEach { (label) in
            label?.textColor = controlTextDefaultColor
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnSwipe = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startLoading() {
        indicatorView.startAnimating()
        HUD.show(.systemActivity)
    }
    
    func endLoading() {
        DispatchQueue.main.async {
            self.indicatorView.stopAnimating()
        }
        HUD.hide()
    }
    
    @IBAction func refresh(_ sender: Any) {
        if indicatorView.isAnimating {return}
        if let start = timeFilterStart, let end = timeFilterEnd {
            manager.check(library: library, room: room, date: date, start: start, end: end) { (response) in
                self.handle(response: response)
            }
        }else{
            manager.check(room: room, date: date) {self.handle(response: $0)}
        }
        startLoading()
    }
    
    @IBAction func displayStyleChanged(_ sender: UISegmentedControl) {
        guard let layoutData = layoutData else {
            manager.check(room: room, date: date) {self.handle(response: $0)}
            startLoading()
            return
        }
        update(layoutData: layoutData)
        if let _ = timeFiltedSeats {
            reloadData()
        }
        switch sender.selectedSegmentIndex {
        case 0:
            scrollView.setZoomScale(1, animated: false)
            scrollView.minimumZoomScale = 1
            scrollView.maximumZoomScale = 1
        case 1:
            scrollView.minimumZoomScale = 0.4
            scrollView.maximumZoomScale = 2
            scrollView.setZoomScale(0.6, animated: false)
        default:
            return
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard displayStyleControl.selectedSegmentIndex == 0 else {
            return
        }
        coordinator.animate(alongsideTransition: {(_) in}) { (_) in
            self.reloadListDisplayData()
        }
    }
    
    @IBAction func toggleComputer(_ sender: Any) {
        filter.needComputer = !filter.needComputer
        if filter.needComputer {
            computerControl.backgroundColor = controlHighlightColor
            computerLabel.textColor = controlTextHighlightColor
        }else{
            computerControl.backgroundColor = controlDefaultColor
            computerLabel.textColor = controlTextDefaultColor
        }
        reloadData()
    }

    
    @IBAction func toggleWindow(_ sender: Any) {
        filter.needWindow = !filter.needWindow
        if filter.needWindow {
            windowControl.backgroundColor = controlHighlightColor
            windowLabel.textColor = controlTextHighlightColor
        }else{
            windowControl.backgroundColor = controlDefaultColor
            windowLabel.textColor = controlTextDefaultColor
        }
        reloadData()
    }
    
    
    @IBAction func togglePower(_ sender: Any) {
        filter.needPower = !filter.needPower
        if filter.needPower {
            powerControl.backgroundColor = controlHighlightColor
            powerLabel.textColor = controlTextHighlightColor
        }else{
            powerControl.backgroundColor = controlDefaultColor
            powerLabel.textColor = controlTextDefaultColor
        }
        reloadData()
    }
    
    @objc func chooseSeat(_ sender: SeatCollectionView) {
        let seat = sender.seat!
        if seat == selectedSeat,
            indicatorView.isAnimating {
            return
        }
        selectedSeat = seat
        startLoading()
        manager.check(seat: seat, date: date) {
            self.handle(response: $0)
        }
    }
    
    func showReserveView() {
        seatLabel.text = "SeatNo".localized(arguments: selectedSeat!.name)
        dismissControl.isHidden = false
        dismissControl.alpha = 0
        UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.dismissControl.alpha = 0.5
            self.dismissBottomConstraint.isActive = false
            self.view.layoutIfNeeded()
        }.startAnimation()
    }
    
    @IBOutlet weak var timelineView: UIStackView!
    @IBOutlet weak var timelineStartLabel: UILabel!
    @IBOutlet weak var timelineEndLabel: UILabel!
    
    func updateTimeline(start: [SeatTime]) {
        var timelineActiveColor: UIColor!
        var timelineDeactiveColor: UIColor!
        let configuration = ThemeConfiguration.current
        timelineActiveColor = configuration.tintColor
        timelineDeactiveColor = configuration.deactiveColor
        timelineView.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        let allTimes = timeFilterManager.startTimes!
        timelineStartLabel.text = allTimes[0].value
        timelineEndLabel.text = timeFilterManager.endTimes!.last!.value
        var views = [UIView]()
        var heightConstraints = [NSLayoutConstraint]()
        for time in allTimes {
            let view = UIView()
            if start.contains(time) {
                view.backgroundColor = timelineActiveColor
                let constraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
                heightConstraints.append(constraint)
            }else{
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
        views.forEach { (view) in
            timelineView.addArrangedSubview(view)
        }
        NSLayoutConstraint.activate(heightConstraints)
    }
    
    @IBAction func dismissReserveView(_ sender: Any) {
        if !reserveButton.isEnabled {return}
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.dismissControl.alpha = 0
            self.dismissBottomConstraint.isActive = true
            self.view.layoutIfNeeded()
        }
        animator.addCompletion { (_) in
            self.dismissControl.isHidden = true
        }
        animator.startAnimation()
        selectedSeat = nil
    }
    
    @IBAction func reserve(_ sender: Any) {
        reserveButton.isEnabled = false
        guard let (start, end) = timePickerManager.selectedTimes else {
            return
        }
        SeatReservationManager.shared.reserve(seat: selectedSeat!, room: room, library: library, date: date, start: start, end: end, cols: layoutData!.cols, rows: layoutData!.rows, seats: layoutData!.seats) { (response) in
            self.handle(response: response)
        }
    }
    
    // MARK: Time Picker
    @IBOutlet weak var timePickerView: UIPickerView!
    var timePickerManager: SeatTimePicker!
    func setupPicker() {
        timePickerManager = SeatTimePicker(pickerView: timePickerView, delegate: nil)
    }
    
    // MARK: Time Filter

    @IBOutlet weak var timeFilterView: UIView!
    @IBOutlet weak var changeTimeFilterButton: UIButton!
    @IBOutlet weak var cleanTimeFilterButton: UIButton!
    @IBOutlet weak var timeFilterLabel: UILabel!
    @IBOutlet weak var timeFilterPickerView: UIPickerView!
    @IBOutlet weak var timeFilterPickerHeightConstraint: NSLayoutConstraint!
    var isTimeFilterDisplay = false {
        didSet {
            if isTimeFilterDisplay {
                timeFilterPickerView.isHidden = false
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                    self.timeFilterPickerHeightConstraint.constant = 92
                    self.timeFilterPickerView.alpha = 1
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }else{
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                    self.timeFilterPickerHeightConstraint.constant = 8
                    self.timeFilterPickerView.alpha = 0
                    self.view.layoutIfNeeded()
                }) {(_) in
                    self.timeFilterPickerView.isHidden = true
                }
            }
        }
    }
    var timeFiltedSeats: [Seat]?
    var timeFilterManager: SeatTimeFilter!
    var timeFilterStart: SeatTime?
    var timeFilterEnd: SeatTime?
    
    func setupFilter() {
        timeFilterManager = SeatTimeFilter(pickerView: timeFilterPickerView, delegate: self)
        if timeFilterManager.startTimes.isEmpty {
            changeTimeFilterButton.isEnabled = false
        }
    }
    
    @IBAction func toggleTimeFilter(_ sender: Any) {
        isTimeFilterDisplay = !isTimeFilterDisplay
        if isTimeFilterDisplay {
            //setting time filter
            changeTimeFilterButton.setTitle("Save".localized, for: .normal)
            if !cleanTimeFilterButton.isEnabled {
                if let start = timeFilterManager.startTimes.first,
                    let end = timeFilterManager.endTimes.first {
                    pickerUpdate(start: start, end: end)
                }
                cleanTimeFilterButton.isEnabled = true
            }
        }else{
            //save time filter
            guard let (start, end) = timeFilterManager.selectedTimes else {
                cleanTimeFilter(self)
                return
            }
            changeTimeFilterButton.setTitle("Change".localized, for: .normal)
            startLoading()
            timeFilterStart = start
            timeFilterEnd = end
            manager.check(library: library, room: room, date: date, start: start, end: end) { (response) in
                self.handle(response: response)
            }
        }
    }
    
    @IBAction func cleanTimeFilter(_ sender: Any) {
        if isTimeFilterDisplay == true {
            isTimeFilterDisplay = false
        }
        cleanTimeFilterButton.isEnabled = false
        changeTimeFilterButton.setTitle("Time Filter".localized, for: .normal)
        timeFiltedSeats = nil
        timeFilterLabel.text = "--:-- - --:--"
        timeFilterManager.reset()
        timeFilterStart = nil
        timeFilterEnd = nil
        reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Seat Selection View Controller Destroyed")
    }
    
}

extension SeatSelectionViewController {
    
    func handle(response: SeatResponse<RoomLayoutData>) {
        switch response {
        case .error(let error):
            handle(error: error)
        case .failed(let failed):
            handle(failedResponse: failed)
        case .requireLogin:
            requireLogin()
        case .success(let layoutData):
            update(layoutData: layoutData)
        }
    }

    func handle(response: SeatResponse<[Seat]>) {
        switch response {
        case .success(let seats):
            timeFilterUpdate(seats: seats)
        case .error(let error):
            handle(error: error)
        case .failed(let fail):
            handle(failedResponse: fail)
        case .requireLogin:
            requireLogin()
        }
    }
    
    func handle(error: Error) {
        reserveButton.isEnabled = true
        endLoading()
        let alertController = UIAlertController(title: "Failed To Update".localized, message: error.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func handle(failedResponse: SeatFailedResponse) {
        reserveButton.isEnabled = true
        endLoading()
        let alertController = UIAlertController(title: "Failed To Update".localized, message: failedResponse.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func requireLogin() {
        endLoading()
        autoLogin(delegate: self)
    }
    
    func reloadData() {
        switch displayStyleControl.selectedSegmentIndex {
        case 0:
            reloadListDisplayData()
        case 1:
            reloadLayoutDisplayData()
        default:
            return
        }
    }
    
    func reloadListDisplayData() {
        guard let layoutData = self.layoutData else {return}
        if let timeSeats = timeFiltedSeats {
            updateListDisplay(seats: timeSeats)
        }else{
            updateListDisplay(seats: layoutData.seats)
        }
    }
    
    func reloadLayoutDisplayData() {
        guard let layoutData = self.layoutData else {return}
        
        for seat in layoutData.seats {
            guard let seatView = layoutView.viewWithTag(seat.id) as? SeatCollectionView else {continue}
            seatView.reset()
        }
        
        let needFilter = !filter.passDirectly
        if let timeFiltedSeats = timeFiltedSeats {
            //Time Filter Enabled
            for seat in timeFiltedSeats {
                guard let seatView = layoutView.viewWithTag(seat.id) as? SeatCollectionView else {continue}
                if filter.fullfill(seat: seat) {
                    seatView.hightlight()
                }
            }
        }else{
            //Time Filter Disabled
            if !needFilter {return}
            for seat in layoutData.seats {
                guard let seatView = layoutView.viewWithTag(seat.id) as? SeatCollectionView else {continue}
                if filter.fullfill(seat: seat) {
                    seatView.hightlight()
                }
            }
        }
    }
    
    func update(layoutData: RoomLayoutData) {
        self.layoutData = layoutData
        switch displayStyleControl.selectedSegmentIndex {
        case 0:
            updateListDisplay(seats: layoutData.seats)
        case 1:
            updateLayoutDisplay()
        default:
            return
        }
        endLoading()
    }
    
    func updateListDisplay(seats: [Seat]) {
        let cellHeight: CGFloat = 60
        let cellWidth: CGFloat = 60
        let gap: CGFloat = 12
        var scrollViewWidth: CGFloat!
        if #available(iOS 11.0, *) {
            scrollViewWidth = scrollView.frame.width - scrollView.safeAreaInsets.left * 2
        } else {
            scrollViewWidth = scrollView.frame.width
        }
        let tempNum = (scrollViewWidth - 16 + 8) / (cellWidth + gap)
        let numberPerRow = Int(tempNum)
        
        let needFilter = !filter.passDirectly
        let seats = (needFilter ? seats.filter{filter.fullfill(seat: $0)} : seats).sorted {$0.name<$1.name}
        let rows = Int(ceil(Double(seats.count) / Double(numberPerRow)))
        let topOffset: CGFloat = 226
        let contentHeight = CGFloat(rows) * (cellHeight + gap) + gap + topOffset
        let contentWidth = scrollViewWidth!
        layoutViewHeightConstraint.constant = contentHeight
        layoutViewWidthConstraint.constant = contentWidth
        layoutView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        
        var leftOffset: CGFloat!
        if #available(iOS 11.0, *) {
            leftOffset = (scrollViewWidth - 16 + 8 - CGFloat(numberPerRow) * (cellWidth + gap)) / 2 + scrollView.safeAreaInsets.left
        } else {
            leftOffset = (scrollViewWidth - 16 + 8 - CGFloat(numberPerRow) * (cellWidth + gap)) / 2
        }
        for row in 0..<rows {
            for col in 0..<numberPerRow {
                let index = row * numberPerRow + col
                guard index < seats.count else {break}
                let seat = seats[index]
                let x = (cellWidth + gap) * CGFloat(col) + gap + leftOffset
                let y = (cellHeight + gap) * CGFloat(row) + gap + topOffset
                let seatView = SeatCollectionView(frame: CGRect(x: x, y: y, width: cellWidth, height: cellHeight))
                Bundle.main.loadNibNamed("SeatCollectionView", owner: seatView, options: nil)
                seatView.contentView.frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight)
                seatView.update(seat: seat)
                seatView.tag = seat.id
                if needFilter {
                    seatView.hightlight()
                }
                seatView.addTarget(self, action: #selector(chooseSeat(_:)), for: .touchUpInside)
                layoutView.addSubview(seatView)
            }
        }
    }
    
    func updateLayoutDisplay() {
        guard let layoutData = layoutData else {return}
        let cellHeight: CGFloat = 80
        let cellWidth: CGFloat = 80
        let gap: CGFloat = 8
        let topOffset: CGFloat = 226
        let contentHeight = CGFloat(layoutData.rows) * (cellHeight + gap) + gap + topOffset
        let contentWidth = CGFloat(layoutData.cols) * (cellWidth + gap) + gap
        layoutViewHeightConstraint.constant = contentHeight
        layoutViewWidthConstraint.constant = contentWidth
        layoutView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        let needFilter = !filter.passDirectly
        for seat in layoutData.seats {
            let x = (cellWidth + gap) * CGFloat(seat.layout.col) + gap
            let y = (cellHeight + gap) * CGFloat(seat.layout.row) + gap + topOffset
            let seatView = SeatCollectionView(frame: CGRect(x: x, y: y, width: cellWidth, height: cellHeight))
            Bundle.main.loadNibNamed("SeatCollectionView", owner: seatView, options: nil)
            seatView.update(seat: seat)
            seatView.tag = seat.id
            if needFilter && filter.fullfill(seat: seat) {
                seatView.hightlight()
            }
            seatView.addTarget(self, action: #selector(chooseSeat(_:)), for: .touchUpInside)
            layoutView.addSubview(seatView)
        }
    }
    
    func timeFilterUpdate(seats: [Seat]) {
        timeFiltedSeats = seats
        reloadData()
        endLoading()
    }
}

extension SeatSelectionViewController {
    
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
            reserveSuccess()
        }
    }
    
    func update(seat: Seat, start: [SeatTime]) {
        guard seat == self.selectedSeat else {return}
        endLoading()
        if start.isEmpty {
            HUD.flash(.label("Not Available Time For This Seat".localized), delay: 1.0)
            return
        }
        timePickerManager.update(startTimes: start, filterStart: timeFilterStart, filterEnd: timeFilterEnd)
        updateTimeline(start: start)
        showReserveView()
    }
    
    func reserveSuccess() {
        view.isUserInteractionEnabled = false
        reserveButton.setTitle("Reserve Success".localized, for: .disabled)
        reserveButton.backgroundColor = #colorLiteral(red: 0.3882352941, green: 0.8549019608, blue: 0.2196078431, alpha: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension SeatSelectionViewController: LoginViewDelegate {
    
    func loginResult(result: LoginResult) {
        switch result {
        case .cancel:
            endLoading()
            return
        case .success(_):
            manager.check(room: room, date: date) {self.handle(response: $0)}
            startLoading()
        }
    }
}

extension SeatSelectionViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return layoutView
    }
}

extension SeatSelectionViewController: SeatTimeFilterDelegate {
    func pickerUpdate(start: SeatTime, end: SeatTime) {
        timeFilterLabel.text = start.value + " - " + end.value
    }
}
