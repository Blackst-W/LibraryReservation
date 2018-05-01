//
//  NotificationController.swift
//  WatchApp Extension
//
//  Created by Weston Wu on 2018/05/01.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications
import WatchSeatKit

extension String {
    fileprivate static let SeatReserveNotificationIdentifier = "com.westonwu.ios.SeatReservation.notification.seat.reserve"
    fileprivate static let SeatUpcomingNotificationIdentifier = "com.westonwu.ios.SeatReservation.notification.seat.upcoming"
    fileprivate static let SeatEndNotificationIdentifier = "com.westonwu.ios.SeatReservation.notification.seat.end"
    fileprivate static let SeatAwayStartNotificationIdentifier = "com.westonwu.ios.SeatReservation.notification.seat.awayStart"
    fileprivate static let SeatAwayEndNotificationIdentifier = "com.westonwu.ios.SeatReservation.notification.seat.awayEnd"
    fileprivate static let SeatLateNotificationIdentifier = "com.westonwu.ios.SeatReservation.notification.seat.late"
}

class NotificationController: WKUserNotificationInterfaceController {
    
    
    @IBOutlet var stateLabel: WKInterfaceLabel!
    @IBOutlet var stateTimeTimer: WKInterfaceTimer!
    @IBOutlet var libraryLabel: WKInterfaceLabel!
    @IBOutlet var floorLabel: WKInterfaceLabel!
    @IBOutlet var roomLabel: WKInterfaceLabel!
    @IBOutlet var seatLabel: WKInterfaceLabel!
    @IBOutlet var startLabel: WKInterfaceLabel!
    @IBOutlet var endLabel: WKInterfaceLabel!
    
    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
    override func didReceive(_ notification: UNNotification, withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Swift.Void) {
        // This method is called when a notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        switch notification.request.identifier {
        case .SeatUpcomingNotificationIdentifier:
            guard let data = notification.request.content.userInfo["SeatReservationData"] as? Data else{
                completionHandler(.default)
                return
            }
            let decoder = JSONDecoder()
            if let reservation = try? decoder.decode(SeatCurrentReservation.self, from: data) {
                stateLabel.setText(reservation.currentState.localizedState)
                if let location = reservation.location {
                    libraryLabel.setText(location.library.rawValue.localized)
                    roomLabel.setText(location.room)
                    seatLabel.setText("No.".localized(arguments: String(location.seat)))
                    floorLabel.setText("Floor".localized(arguments: location.floor))
                }
                startLabel.setText(reservation.rawBegin)
                endLabel.setText(reservation.rawEnd)
                switch reservation.currentState {
                case .upcoming(_):
                    stateTimeTimer.setDate(reservation.time.start)
                default:
                    completionHandler(.default)
                    return
                }
            }else if let reservation = try? decoder.decode(SeatReservation.self, from: data) {
                stateLabel.setText(reservation.currentState.localizedState)
                if let location = reservation.location {
                    libraryLabel.setText(location.library.rawValue.localized)
                    roomLabel.setText(location.room)
                    seatLabel.setText("No.".localized(arguments: String(location.seat)))
                    floorLabel.setText("Floor".localized(arguments: location.floor))
                }
                startLabel.setText(reservation.rawBegin)
                endLabel.setText(reservation.rawEnd)
                switch reservation.currentState {
                case .upcoming(_):
                    stateTimeTimer.setDate(reservation.time.start)
                default:
                    completionHandler(.default)
                    return
                }
            }else{
                completionHandler(.default)
                return
            }
        default:
            completionHandler(.default)
            return
        }
        completionHandler(.custom)
    }

}
