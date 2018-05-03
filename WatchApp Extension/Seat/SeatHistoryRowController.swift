//
//  SeatHistoryRowController.swift
//  WatchApp Extension
//
//  Created by Weston Wu on 2018/05/01.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import WatchKit
import WatchSeatKit

extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

class SeatHistoryRowController: NSObject {

    @IBOutlet var dateLabel: WKInterfaceLabel!
    @IBOutlet var libraryLabel: WKInterfaceLabel!
    @IBOutlet var floorLabel: WKInterfaceLabel!
    @IBOutlet var roomLabel: WKInterfaceLabel!
    @IBOutlet var seatLabel: WKInterfaceLabel!
    @IBOutlet var startLabel: WKInterfaceLabel!
    @IBOutlet var endLabel: WKInterfaceLabel!
    
    func update(reservation: SeatReservation) {
        
        dateLabel.setText(reservation.time.date.string(format: "MM-dd"))
        if let location = reservation.location {
            libraryLabel.setText(location.library.rawValue.localized)
            floorLabel.setText("Floor".localized(arguments: location.floor))
            roomLabel.setText(location.room)
            seatLabel.setText("No.".localized(arguments: String(location.seat)))
        }
        startLabel.setText(reservation.rawBegin)
        endLabel.setText(reservation.rawEnd)
    }
    
}
