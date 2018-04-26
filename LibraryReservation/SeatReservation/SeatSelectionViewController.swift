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
    @IBOutlet weak var timePickerView: UIPickerView!
    @IBOutlet weak var reserveButton: UIButton!
    
    @IBOutlet weak var displayStyleControl: UISegmentedControl!
    
    var manager: AvailableSeatManager!
    var library: Library!
    var room: Room!
    var date: Date!
    var layoutData: SeatLayoutData?
    var seatTimeManager: SeatReserveManager!
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
    
    var startTimes = [SeatTime]()
    var endTimes = [SeatTime]()
    
    override func viewDidLoad() {
        PKHUD.sharedHUD.dimsBackground = false
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = true
        super.viewDidLoad()
        modalPresentationStyle = .formSheet
        title = room.name
        libraryNameLabel.text = library.rawValue
        floorLabel.text = "\(room.floor)F"
        roomLabel.text = room.name
        scrollView.delegate = self
//        scrollView.setZoomScale(0.6, animated: false)
        manager = AvailableSeatManager(delegate: self)
        manager.check(room: room, date: date)
        seatTimeManager = SeatReserveManager(delegate: self)
        startLoading()
        timePickerView.delegate = self
        timePickerView.dataSource = self
        setupFilter()
        navigationController?.hidesBarsOnSwipe = true
        // Do any additional setup after loading the view.
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
    }
    
    func endLoading() {
        indicatorView.stopAnimating()
    }
    
    @IBAction func refresh(_ sender: Any) {
        if indicatorView.isAnimating {return}
        if let start = timeFilterStart, let end = timeFilterEnd {
            manager.check(library: library, room: room, date: date, start: start, end: end)
        }else{
            manager.check(room: room, date: date)
        }
        startLoading()
    }
    
    @IBAction func displayStyleChanged(_ sender: UISegmentedControl) {
        guard let layoutData = layoutData else {
            manager.check(room: room, date: date)
            startLoading()
            return
        }
        update(layoutData: layoutData)
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
    
    @IBAction func toggleComputer(_ sender: Any) {
        filter.needComputer = !filter.needComputer
        if filter.needComputer {
            computerControl.backgroundColor = #colorLiteral(red: 0, green: 0.5018912177, blue: 1, alpha: 1)
            computerLabel.textColor = .white
            computerImageView.isHighlighted = true
        }else{
            computerControl.backgroundColor = .white
            computerLabel.textColor = #colorLiteral(red: 0, green: 0.5018912177, blue: 1, alpha: 1)
            computerImageView.isHighlighted = false
        }
        reloadData()
    }

    
    @IBAction func toggleWindow(_ sender: Any) {
        filter.needWindow = !filter.needWindow
        if filter.needWindow {
            windowControl.backgroundColor = #colorLiteral(red: 0, green: 0.5018912177, blue: 1, alpha: 1)
            windowLabel.textColor = .white
            windowImageView.isHighlighted = true
        }else{
            windowControl.backgroundColor = .white
            windowLabel.textColor = #colorLiteral(red: 0, green: 0.5018912177, blue: 1, alpha: 1)
            windowImageView.isHighlighted = false
        }
        reloadData()
    }
    
    
    @IBAction func togglePower(_ sender: Any) {
        filter.needPower = !filter.needPower
        if filter.needPower {
            powerControl.backgroundColor = #colorLiteral(red: 0, green: 0.5018912177, blue: 1, alpha: 1)
            powerLabel.textColor = .white
            powerImageView.isHighlighted = true
        }else{
            powerControl.backgroundColor = .white
            powerLabel.textColor = #colorLiteral(red: 0, green: 0.5018912177, blue: 1, alpha: 1)
            powerImageView.isHighlighted = false
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
        seatTimeManager.check(seat: seat, date: date)
    }
    
    func showReserveView() {
        seatLabel.text = "Seat No." + selectedSeat!.name
        dismissControl.isHidden = false
        dismissControl.alpha = 0
        UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.dismissControl.alpha = 0.5
            self.dismissBottomConstraint.isActive = false
            self.view.layoutIfNeeded()
        }.startAnimation()
    }
    
    
    @IBAction func dismissReserveView(_ sender: Any) {
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
        let start = startTimes[timePickerView.selectedRow(inComponent: 0)]
        let end = endTimes[timePickerView.selectedRow(inComponent: 1)]
        print(start)
        print(end)
        seatTimeManager.reserve(seat: selectedSeat!, date: date, start: start, end: end)
    }
    
    // MARK: Time Filter
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
    }
    
    @IBAction func toggleTimeFilter(_ sender: Any) {
        isTimeFilterDisplay = !isTimeFilterDisplay
        if isTimeFilterDisplay {
            //setting time filter
            cleanTimeFilterButton.isEnabled = true
            changeTimeFilterButton.setTitle("Save", for: .normal)
            timeFilterLabel.text = "08:00 - 08:30"
        }else{
            //save time filter
            changeTimeFilterButton.setTitle("Change", for: .normal)
            let (start, end) = timeFilterManager.selectedTimes
            startLoading()
            timeFilterStart = start
            timeFilterEnd = end
            manager.check(library: library, room: room, date: date, start: start, end: end)
        }
    }
    
    @IBAction func cleanTimeFilter(_ sender: Any) {
        if isTimeFilterDisplay == true {
            isTimeFilterDisplay = false
        }
        cleanTimeFilterButton.isEnabled = false
        changeTimeFilterButton.setTitle("Change", for: .normal)
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

extension SeatSelectionViewController: AvailableSeatDelegate {
    
    func updateFailed(error: Error) {
        reserveButton.isEnabled = true
        endLoading()
        let alertController = UIAlertController(title: "Failed To Update", message: error.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func updateFailed(failedResponse: SeatFailedResponse) {
        reserveButton.isEnabled = true
        if failedResponse.code == "12" {
            requireLogin()
            return
        }
        endLoading()
        let alertController = UIAlertController(title: "Failed To Update", message: failedResponse.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
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
        
        let needFilter = filter.isEnabled
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
    
    func update(layoutData: SeatLayoutData) {
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
        let numberPerRow = Int((scrollViewWidth - 16 + 8) / (cellWidth + gap))
        
        let needFilter = filter.isEnabled
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
        let needFilter = filter.isEnabled
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

extension SeatSelectionViewController: SeatReserveDelegate {
    func update(seat: Seat, start: [SeatTime], end: [SeatTime]) {
        guard seat == self.selectedSeat else {return}
        endLoading()
        if start.isEmpty {
            HUD.flash(.label("Not Available Time For This Seat."), delay: 1.0)
            return
        }
        startTimes = start
        endTimes = end
        timePickerView.reloadAllComponents()
        if let filterStart = timeFilterStart, let index = start.index(of: filterStart) {
            timePickerView.selectRow(index, inComponent: 0, animated: false)
            endTimes = seatTimeManager.endTimes(for: index)
            timePickerView.reloadComponent(1)
            if let filterEnd = timeFilterEnd, let endIndex = endTimes.index(of: filterEnd) {
                timePickerView.selectRow(endIndex, inComponent: 1, animated: false)
            }else{
                timePickerView.selectRow(0, inComponent: 1, animated: false)
            }
        }else{
            timePickerView.selectRow(0, inComponent: 0, animated: false)
            timePickerView.selectRow(0, inComponent: 1, animated: false)
        }
        showReserveView()
    }
    
    func reserveSuccess() {
        view.isUserInteractionEnabled = false
        reserveButton.setTitle("Success", for: .disabled)
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
            manager.check(room: room, date: date)
            startLoading()
        }
    }
}

extension SeatSelectionViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return layoutView
    }
}

extension SeatSelectionViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? startTimes.count : endTimes.count
    }
}

extension SeatSelectionViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? startTimes[row].value : endTimes[row].value
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            endTimes = seatTimeManager.endTimes(for: row)
            pickerView.reloadComponent(1)
        }
    }
}

extension SeatSelectionViewController: SeatTimeFilterDelegate {
    func pickerUpdate(start: SeatTime, end: SeatTime) {
        timeFilterLabel.text = start.value + " - " + end.value
    }
}
