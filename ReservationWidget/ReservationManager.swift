//
//  ReservationManager.swift
//  ReservationWidget
//
//  Created by Weston Wu on 2018/05/17.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import SeatKit

let GroupID = "group.com.westonwu.ios.whu"

extension UserDefaults {
    class var group: UserDefaults {
        return UserDefaults(suiteName: GroupID)!
    }
}

let GroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GroupID)!


class ReservationManager: NSObject {
    
    var reservation: SeatReservation?
    var manager = SeatHistoryManager()
    
    override init() {
        super.init()
        load()
    }
    
    func load() {
        let path = GroupURL.appendingPathComponent("SeatReservation.archive")
        let decoder = JSONDecoder()
        if let data = try? Data(contentsOf: path),
            let reservation = try? decoder.decode(SeatReservation.self, from: data) {
            self.reservation = reservation
        }
    }
    
    func refresh(callback: SeatHandler<SeatReservation?>?) {
        manager.fetchHistory(page: 0) { (response) in
            switch response {
            case .error(let error):
                callback?(.error(error))
            case .failed(let failedResponse):
                callback?(.failed(failedResponse))
            case .requireLogin:
                callback?(.requireLogin)
            case .success(let reservations):
                for reservation in reservations {
                    if !reservation.isHistory {
                        self.reservation = reservation
                        callback?(.success(reservation))
                        break
                    }
                }
            }
        }
    }
}
