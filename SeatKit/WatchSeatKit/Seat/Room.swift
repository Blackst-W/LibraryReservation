//
//  Room.swift
//  SeatKit
//
//  Created by Weston Wu on 2018/05/17.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

/*
 {
     "roomId": 39,
     "room": "A1-座位区",
     "floor": 1,
     "reserved": 0,
     "inUse": 0,
     "away": 0,
     "totalSeats": 168,
     "free": 168
 }
 */

public struct Room: Codable {
    public let id: Int
    public let name: String
    public let floor: Int
    public var availableSeats: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "roomId"
        case name = "room"
        case floor
        case availableSeats = "free"
    }
}
