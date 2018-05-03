//
//  SeatFilterCondition.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/21.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import WatchKit

public struct SeatFilterCondition: Equatable {
    public var needPower: Bool
    public var needWindow: Bool
    public var needComputer: Bool
    public var isEnabled: Bool {
        return self != SeatFilterCondition()
    }
    
    public init(needPower: Bool, needWindow: Bool, needComputer: Bool) {
        self.needPower = needPower
        self.needWindow = needWindow
        self.needComputer = needComputer
    }
    
    public init() {
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
    
    public func fullfill(seat: Seat) -> Bool {
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
