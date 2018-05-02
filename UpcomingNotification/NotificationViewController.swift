//
//  NotificationViewController.swift
//  UpcomingNotification
//
//  Created by Weston Wu on 2018/05/02.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import SeatKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var libraryLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var seatLabel: UILabel!
    @IBOutlet weak var stateTimeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        guard let data = notification.request.content.userInfo["SeatReservationData"] as? Data else{
            //                completionHandler(.default)
            return
        }
        let decoder = JSONDecoder()
        if let reservation = try? decoder.decode(SeatCurrentReservation.self, from: data) {
            stateLabel.text = reservation.currentState.localizedState
            if let location = reservation.location {
                libraryLabel.text = location.library.rawValue.localized
                roomLabel.text = location.room
                seatLabel.text = "No.".localized(arguments: String(location.seat))
                floorLabel.text = "Floor".localized(arguments: location.floor)
            }
            timeLabel.text = "\(reservation.rawBegin) - \(reservation.rawEnd)"
            switch reservation.currentState {
            case .upcoming(let next):
                let hour = next / 60
                let min = next % 60
                let hourString = hour == 0 ? "": "h".localized(arguments: hour)
                let minString = "mins".localized(arguments: min)
                stateTimeLabel.text = "Start In".localized(arguments: hourString, minString)
            default:
//                completionHandler(.default)
                return
            }
        }else if let reservation = try? decoder.decode(SeatReservation.self, from: data) {
            stateLabel.text = reservation.currentState.localizedState
            if let location = reservation.location {
                libraryLabel.text = location.library.rawValue.localized
                roomLabel.text = location.room
                seatLabel.text = "No.".localized(arguments: String(location.seat))
                floorLabel.text = "Floor".localized(arguments: location.floor)
            }
            timeLabel.text = "\(reservation.rawBegin) - \(reservation.rawEnd)"
            switch reservation.currentState {
            case .upcoming(let next):
                let hour = next / 60
                let min = next % 60
                let hourString = hour == 0 ? "": "h".localized(arguments: hour)
                let minString = "mins".localized(arguments: min)
                stateTimeLabel.text = "Start In".localized(arguments: hourString, minString)
            default:
//                completionHandler(.default)
                return
            }
        }else{
//            completionHandler(.default)
            return
        }
//    completionHandler(.custom)
    }

}
