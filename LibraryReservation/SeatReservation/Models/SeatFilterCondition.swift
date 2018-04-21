//
//  SeatFilterCondition.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/21.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

struct SeatFilterCondition: Equatable {
    private(set) var begin: Date?
    private(set) var end: Date?
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
    
    mutating func time(begin: Date, end: Date) {
        guard end > begin else {
            return
        }
        self.begin = begin
        self.end = end
    }
    
    mutating func cleanTime() {
        begin = nil
        end = nil
    }
    
    public static func == (lhs: SeatFilterCondition, rhs: SeatFilterCondition) -> Bool {
        guard lhs.begin == rhs.begin,
            lhs.end == rhs.end,
            lhs.needComputer == rhs.needComputer,
            lhs.needPower == rhs.needPower,
            lhs.needWindow == rhs.needWindow else {
                return false
        }
        return true
    }
    
    func fullfill(seat: Seat) -> Bool {
        guard isEnabled else {return false}
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
