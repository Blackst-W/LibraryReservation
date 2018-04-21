//
//  SeatSelectionViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/20.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

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
    
    var manager: AvailableSeatManager!
    var library: Library!
    var room: Room!
    var date: Date!
    var layoutData: SeatLayoutData?
    var seatTimeManager: SeatTimeManager!
    var selectedSeat: Seat? {
        didSet {
            if let oldSeat = oldValue {
                let seatView = layoutView.viewWithTag(oldSeat.id) as! SeatCollectionView
                seatView.reset()
                if filter.fullfill(seat: oldSeat) {
                    seatView.hightlight()
                }
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
        super.viewDidLoad()
        modalPresentationStyle = .formSheet
        title = room.name
        libraryNameLabel.text = library.rawValue
        floorLabel.text = "\(room.floor)F"
        roomLabel.text = room.name
        scrollView.delegate = self
        scrollView.setZoomScale(0.6, animated: false)
        manager = AvailableSeatManager(delegate: self)
        manager.check(room: room, date: date)
        seatTimeManager = SeatTimeManager(delegate: self)
        startLoading()
        timePickerView.delegate = self
        timePickerView.dataSource = self
        setupFilter()
        // Do any additional setup after loading the view.
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
        let seat = sender.seat
        if seat == selectedSeat {
            selectedSeat = nil
            return
        }
        selectedSeat = seat
        startLoading()
        seatTimeManager.check(seat: seat!, date: date)
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
        autoLogin(delegate: self, force: true)
    }
    
    func reloadData() {
        guard let layoutData = self.layoutData else {return}
        
        for seat in layoutData.seats {
            let seatView = layoutView.viewWithTag(seat.id) as! SeatCollectionView
            seatView.reset()
        }
        
        let needFilter = filter.isEnabled
        if let timeFiltedSeats = timeFiltedSeats {
            //Time Filter Enabled
            for seat in timeFiltedSeats {
                let seatView = layoutView.viewWithTag(seat.id) as! SeatCollectionView
                if filter.fullfill(seat: seat) {
                    seatView.hightlight()
                }
            }
        }else{
            //Time Filter Disabled
            if !needFilter {return}
            for seat in layoutData.seats {
                let seatView = layoutView.viewWithTag(seat.id) as! SeatCollectionView
                if filter.fullfill(seat: seat) {
                    seatView.hightlight()
                }
            }
        }
    }
    
    func update(layoutData: SeatLayoutData) {
        self.layoutData = layoutData
        let cellHeight: CGFloat = 80
        let cellWidth: CGFloat = 80
        let gap: CGFloat = 8
        let contentHeight = CGFloat(layoutData.rows) * (cellHeight + gap) + gap
        let contentWidth = CGFloat(layoutData.cols) * (cellWidth + gap) + gap
        layoutViewHeightConstraint.constant = contentHeight
        layoutViewWidthConstraint.constant = contentWidth
        layoutView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        let needFilter = filter.isEnabled
        for seat in layoutData.seats {
            let x = (cellWidth + gap) * CGFloat(seat.layout.col) + gap
            let y = (cellHeight + gap) * CGFloat(seat.layout.row) + gap
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
        endLoading()
    }
    
    func timeFilterUpdate(seats: [Seat]) {
        for view in layoutView.subviews {
            if let seatView = view as? SeatCollectionView {
                seatView.reset()
            }
        }
        timeFiltedSeats = seats
        for seat in seats {
            guard filter.fullfill(seat: seat) else {continue}
            if let seatView = layoutView.viewWithTag(seat.id) as? SeatCollectionView {
                seatView.hightlight()
            }
        }
        endLoading()
    }
    
}

extension SeatSelectionViewController: SeatTimeDelegate {
    func update(start: [SeatTime], end: [SeatTime]) {
        endLoading()
        if start.isEmpty {
            return
        }
        startTimes = start
        endTimes = end
        timePickerView.reloadAllComponents()
        timePickerView.selectRow(0, inComponent: 0, animated: false)
        timePickerView.selectRow(0, inComponent: 1, animated: false)
        showReserveView()
    }
    
    func reserveSuccess() {
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
