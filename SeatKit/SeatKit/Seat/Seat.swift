//
//  Seat.swift
//  SeatKit
//
//  Created by Weston Wu on 2018/05/17.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

/*
     "1029": {
     "id": 8615,
     "name": "127",
     "type": "seat",
     "status": "IN_USE",
     "window": false,
     "power": true,
     "computer": false,
     "local": false
 }
 */

public struct Seat: Codable, Equatable {
    
    public let id: Int
    public let name: String
    public let status: String
    public let hasWindow: Bool
    public let hasPower: Bool
    public let hasComputer: Bool
    public let layout: RoomLayout
    
    public var available: Bool {
        return status == "FREE" || status == "AWAY" || status == "IN_USE"
    }
    
    public var availableNow: Bool {
        return status == "FREE"
    }
    
    init?(layoutKey: String, values: [String: Any]) {
        guard let layout = RoomLayout(key: layoutKey) else {
            return nil
        }
        self.layout = layout
        guard let id = values["id"] as? Int,
            let name = values["name"] as? String,
            let status = values["status"] as? String,
            let window = values["window"] as? Bool,
            let power = values["power"] as? Bool,
            let computer = values["computer"] as? Bool else {
                return nil
        }
        self.id = id
        self.name = name
        self.status = status
        hasWindow = window
        hasPower = power
        hasComputer = computer
    }
    
    public static func==(lhs: Seat, rhs: Seat) -> Bool {
        return lhs.id == rhs.id
    }
    
}
