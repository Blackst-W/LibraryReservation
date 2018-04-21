//
//  SeatFilterCondition.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/21.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

struct SeatFilterCondition: Equatable {
    var needPower: Bool
    var needWindow: Bool
    var needComputer: Bool
    var isEnabled: Bool {
        return self != SeatFilterCondition()
    }
    
    init(needPower: Bool, needWindow: Bool, needComputer: Bool) {
        self.needPower = needPower
        self.needWindow = needWindow
        self.needComputer = needComputer
    }
    
    init() {
        needComputer = false
        needWindow = false
        needPower = false
    }
    
    public static func == (lhs: SeatFilterCondition, rhs: SeatFilterCondition) -> Bool {
        guard lhs.needComputer == rhs.needComputer,
            lhs.needPower == rhs.needPower,
            lhs.needWindow == rhs.needWindow else {
                return false
        }
        return true
    }
    
    func fullfill(seat: Seat) -> Bool {
        guard isEnabled else {return true}
        if needComputer && !seat.hasComputer {
            return false
        }
        if needWindow && !seat.hasWindow {
            return false
        }
        if needPower && !seat.hasPower {
            return false
        }
        return true
    }
    
}
