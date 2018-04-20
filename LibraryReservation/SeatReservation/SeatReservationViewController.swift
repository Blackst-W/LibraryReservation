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
    
    var selectedLibrary: Library? {
        didSet {
            if let library = selectedLibrary {
                roomData = libraryData[library]
            }else{
                roomData = []
            }
            selectedRoom = nil
            resizeRoomTableView()
            roomTableView.reloadSections(IndexSet(integer: 0), with: .fade)
        }
    }
    
    var selectedRoom: Room? {
        didSet {
            if let _ = selectedRoom {
                
            }else{
                
            }
        }
    }
    
    var libraryData = LibraryData()
    var roomData: [Room] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomTableView.dataSource = self
        roomTableView.delegate = self
        roomTableView.contentInset = UIEdgeInsets(top: -34, left: 0, bottom: 0, right: 0)
        libraryView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func resizeRoomTableView(_ height: CGFloat? = nil) {
        let numberOfRow = CGFloat(tableView(roomTableView, numberOfRowsInSection: 0))
        let cellHeight = tableView(roomTableView, heightForRowAt: IndexPath(row: 0, section: 0))
        let contentHeight = height ?? numberOfRow * cellHeight
        UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
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
        
        let currentRoom = selectedRoom ?? roomData[index]
        
        let selectedRow = libraryData.roomIndex[currentRoom.id]!.1 / 2
        let totalRowNumber = (roomData.count + 1) / 2
        var indexPaths = [IndexPath]()
        for row in 0 ..< totalRowNumber {
            if row == selectedRow {continue}
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        if let _ = selectedRoom {
            selectedRoom = nil
            UIView.animate(withDuration: 0.5) {
                self.roomTableView.beginUpdates()
                self.roomTableView.insertRows(at: indexPaths, with: .fade)
                self.roomTableView.endUpdates()
            }
        }else{
            selectedRoom = currentRoom
            UIView.animate(withDuration: 0.5) {
                self.roomTableView.beginUpdates()
                self.roomTableView.deleteRows(at: indexPaths, with: .fade)
                self.roomTableView.endUpdates()
            }
        }
        resizeRoomTableView()
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

extension SeatReservationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedRoom != nil {
            return 1
        }
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
//        cell.roomSelected(selection: selection)
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
