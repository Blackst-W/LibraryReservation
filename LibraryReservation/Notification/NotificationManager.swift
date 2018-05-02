//
//  NotificationManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/27.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import UserNotifications

extension String {
    fileprivate static let SeatReserveNotificationIdentifier = "com.westonwu.ios.SeatReservation.notification.seat.reserve"
    fileprivate static let SeatUpcomingNotificationIdentifier = "com.westonwu.ios.SeatReservation.notification.seat.upcoming"
    fileprivate static let SeatEndNotificationIdentifier = "com.westonwu.ios.SeatReservation.notification.seat.end"
    fileprivate static let SeatAwayStartNotificationIdentifier = "com.westonwu.ios.SeatReservation.notification.seat.awayStart"
    fileprivate static let SeatAwayEndNotificationIdentifier = "com.westonwu.ios.SeatReservation.notification.seat.awayEnd"
    fileprivate static let SeatLateNotificationIdentifier = "com.westonwu.ios.SeatReservation.notification.seat.late"
}

class NotificationManager: NSObject {
    
    static var shared = NotificationManager()
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationSettings(notification:)), name: .NotificationSettingsChanged, object: nil)
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .notDetermined, .denied:
                Settings.shared.disableNotification()
            default:
                return
            }
        }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    @objc func updateNotificationSettings(notification: Notification) {
        let notificationSettings = Settings.shared.notificationSettings
        guard notificationSettings.enable else {
            removeAllNotifications()
            return
        }
        updateSeatNotification()
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func updateSeatNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        if Settings.shared.notificationSettings.seat.make {
            let content = UNMutableNotificationContent()
            content.badge = 1
            content.sound = UNNotificationSound.default()
            content.title = "Reserve Reminder".localized
            content.body = "Seat reservation for the next day is about to open.".localized
            var dateComponents = DateComponents()
            dateComponents.hour = 22
            dateComponents.minute = 40
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: .SeatReserveNotificationIdentifier, content: content, trigger: trigger)
            notificationCenter.add(request, withCompletionHandler: nil)
        }else{
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [.SeatReserveNotificationIdentifier])
        }
        guard let currentReservation = SeatHistoryManager(delegate: nil).current else {
            removeAllSeatNotifications()
            return
        }
        schedule(reservation: currentReservation)
    }
    
    func schedule(reservation: SeatCurrentReservationRepresentable?) {
        guard let reservation = reservation else {
            removeAllSeatNotifications()
            return
        }
        let seatSettings = Settings.shared.notificationSettings.seat
        let notificationCenter = UNUserNotificationCenter.current()
        if seatSettings.upcoming && !reservation.isStarted {
            let content = UNMutableNotificationContent()
            content.userInfo = ["SeatReservationData": reservation.jsonData]
            content.categoryIdentifier = "SeatUpcomingReservationCategory"
            content.badge = 1
            content.sound = UNNotificationSound.default()
            content.title = "Upcoming Seat Reservation In 10mins".localized
            if let message = reservation.time.message {
                content.body = reservation.rawLocation + "\n" + message
            }else{
                content.body = reservation.rawLocation
            }
            let calender = Calendar.current
//            let dateComponents = calender.dateComponents([.hour, .minute, .day], from: reservation.time.start.addingTimeInterval(-10 * 60))
            let dateComponents = calender.dateComponents([.hour, .minute, .second, .day], from: Date().addingTimeInterval(10))
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: .SeatUpcomingNotificationIdentifier, content: content, trigger: trigger)
            notificationCenter.add(request, withCompletionHandler: nil)
        }else if !seatSettings.upcoming {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [.SeatUpcomingNotificationIdentifier])
        }
        
        if seatSettings.end {
            let content = UNMutableNotificationContent()
            content.userInfo = ["SeatReservationData": reservation.jsonData]
            content.categoryIdentifier = "SeatReservationCategory"
            content.badge = 1
            content.sound = UNNotificationSound.default()
            content.title = "Reservation Complete".localized
            content.body = "Make sure to take all your belongings before leave.".localized
            let calender = Calendar.current
            let dateComponents = calender.dateComponents([.hour, .minute, .day], from: reservation.time.end)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: .SeatEndNotificationIdentifier, content: content, trigger: trigger)
            notificationCenter.add(request, withCompletionHandler: nil)
        }else {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [.SeatEndNotificationIdentifier])
        }
        
        if seatSettings.tempAway,
            case .tempAway(_) = reservation.currentState,
            let leftDate = reservation.awayStart {
//            notificationCenter.getPendingNotificationRequests { (requests) in
//                if requests.contains(where: {$0.identifier == .SeatAwayEndNotificationIdentifier}) {
//                }
//            }
            let content = UNMutableNotificationContent()
            content.userInfo = ["SeatReservationData": reservation.jsonData]
            content.categoryIdentifier = "SeatReservationCategory"
            content.badge = 1
            content.sound = UNNotificationSound.default()
            content.title = "Reservation Expire Alert".localized
            content.body = "Reservation is about to expire in 10mins, back to library or cancel the reservation to avoid violation.".localized
            let calender = Calendar.current
            let hour = calender.component(.hour, from: leftDate)
            var awayTime = 30 - 10
            switch hour {
            case 11, 12, 17, 18:
                awayTime = 60 - 10
            default:
                break
            }
            let dateComponents = calender.dateComponents([.hour, .minute, .day], from: leftDate.addingTimeInterval(Double(awayTime) * 60))
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: .SeatAwayEndNotificationIdentifier, content: content, trigger: trigger)
            notificationCenter.add(request, withCompletionHandler: nil)
        }else if !seatSettings.tempAway {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [.SeatAwayStartNotificationIdentifier, .SeatAwayEndNotificationIdentifier])
        }else{
            //already return to the seat
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [.SeatAwayEndNotificationIdentifier])
        }
    }
    
    func removeAllSeatNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [.SeatUpcomingNotificationIdentifier, .SeatEndNotificationIdentifier, .SeatAwayEndNotificationIdentifier, .SeatAwayStartNotificationIdentifier])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .alert])
    }
    
}
