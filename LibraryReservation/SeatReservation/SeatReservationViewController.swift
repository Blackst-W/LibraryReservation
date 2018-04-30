//
//  SeatReservationViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/20.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class SeatReservationViewController: UIViewController {

    @IBOutlet weak var libraryView: SeatLibraryView!
    @IBOutlet weak var roomTableView: UITableView!
    @IBOutlet weak var roomTableViewHeightConstraint: NSLayoutConstraint!
    
    var date: Date!
    var roomData: [Room] = []
    var libraryManager: SeatLibraryManager!
    
    var selectedLibrary: Library? {
        didSet {
            if let library = selectedLibrary {
                roomData = libraryManager.libraryData[library]
                libraryManager.check(library: library)
            }else{
                roomData = []
            }
            resizeRoomTableView()
            roomTableView.reloadSections(IndexSet(integer: 0), with: .fade)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        date = Date()
        let calender = Calendar.current
        var dayTitle = "(Today)".localized
        if calender.component(.hour, from: date) >= 22 || (calender.component(.hour, from: date) == 21 && calender.component(.minute, from: date) >= 30) {
            date = date.addingTimeInterval(4 * 60 * 60)
            dayTitle = "(Tomorrow)".localized
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        title = dateFormatter.string(from: date) + " " + dayTitle
        roomTableView.dataSource = self
        roomTableView.delegate = self
        roomTableView.contentInset = UIEdgeInsets(top: -34, left: 0, bottom: 0, right: 0)
        libraryView.delegate = self
        libraryManager = SeatLibraryManager(delegate: self)
        // Do any additional setup after loading the view.
    }
    
    func resizeRoomTableView(_ height: CGFloat? = nil) {
        let numberOfRow = CGFloat(tableView(roomTableView, numberOfRowsInSection: 0))
        let cellHeight = tableView(roomTableView, heightForRowAt: IndexPath(row: 0, section: 0))
        let contentHeight = height ?? numberOfRow * cellHeight
        UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            self.roomTableViewHeightConstraint.constant = contentHeight
            self.view.layoutIfNeeded()
        }.startAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func roomSelected(_ sender: UIControl) {
        let index = sender.tag
        let selectedRoom = roomData[index]
        let storyboard = UIStoryboard(name: "SeatStoryboard", bundle: nil)
        let layoutViewController = storyboard.instantiateViewController(withIdentifier: "SeatLayoutController") as! SeatSelectionViewController
        layoutViewController.navigationItem.prompt = selectedRoom.name
        layoutViewController.library = selectedLibrary!
        layoutViewController.room = selectedRoom
        layoutViewController.date = date
        navigationController?.pushViewController(layoutViewController, animated: true)
    }
    
    @IBAction func cancelReservation(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("Seat Reservaton View Controller Destroy")
    }
}

extension SeatReservationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (roomData.count + 1) / 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let leftIndex = indexPath.row * 2
        let rightIndex = leftIndex + 1
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath) as! SeatRoomTableViewCell
        let left = roomData[leftIndex]
        var right: Room? = nil
        if rightIndex < roomData.count {
            right = roomData[rightIndex]
        }
        cell.update(left: left, right: right)
        cell.leftRoomView.tag = leftIndex
        cell.leftRoomView.addTarget(self, action: #selector(roomSelected(_:)), for: .touchUpInside)
        cell.rightRoomView.tag = rightIndex
        cell.rightRoomView.addTarget(self, action: #selector(roomSelected(_:)), for: .touchUpInside)
        return cell
    }
}

extension SeatReservationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

extension SeatReservationViewController: SeatLibraryViewDelegate {
    func select(library: Library?) {
        selectedLibrary = library
    }
}

extension SeatReservationViewController: SeatLibraryDelegate {
    func requireLogin() {
        return
    }
    
    func updateFailed(error: Error) {
        let alertController = UIAlertController(title: "Failed To Update".localized, message: error.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func updateFailed(failedResponse: SeatFailedResponse) {
        if failedResponse.code == "12" {
            autoLogin(delegate: self, force: false)
            return
        }
        let alertController = UIAlertController(title: "Failed To Update".localized, message: failedResponse.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func update(rooms: [Room], for library: Library) {
        if library == selectedLibrary {
            roomData = rooms
            roomTableView.reloadData()
        }
    }
}

extension SeatReservationViewController: LoginViewDelegate {
    func loginResult(result: LoginResult) {
        switch result {
        case .cancel:
            return
        case .success(_):
            if let library = selectedLibrary {
                libraryManager.check(library: library)
            }
        }
    }
}
