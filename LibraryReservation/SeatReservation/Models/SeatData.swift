//
//  SeatData.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/20.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import SwiftyJSON

enum Library: String {
    case main = "总馆"
    case engineering = "工学分馆"
    case info = "信息科学分馆"
    case medicine = "医学分馆"
    
    var areaID: Int {
        switch self {
        case .main:
            return 4
        case .engineering:
            return 2
        case .info:
            return 1
        case .medicine:
            return 3
        }
    }
    
    var localizedValue: String {
        return rawValue.localized
    }
    
}

struct Room: Codable {
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
    let id: Int
    let name: String
    let floor: Int
    var availableSeat: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "roomId"
        case name = "room"
        case floor
        case availableSeat = "free"
    }
}

struct SeatLayout: Codable {
    let col: Int
    let row: Int
    
    init?(key: String) {
        guard let value = Int(key) else {
            return nil
        }
        row = value / 1000
        col = value % 1000
    }
    
}

struct Seat: Codable, Equatable {
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
    let id: Int
    let name: String
    let status: String
    let hasWindow: Bool
    let hasPower: Bool
    let hasComputer: Bool
    let layout: SeatLayout
    
    var available: Bool {
        return status == "FREE" || status == "AWAY" || status == "IN_USE"
    }
    
    var availableNow: Bool {
        return status == "FREE"
    }
    
    init?(layoutKey: String, json: [String:JSON]) {
        guard let layout = SeatLayout(key: layoutKey) else {
            return nil
        }
        self.layout = layout
        guard let id = json["id"]?.int,
            let name = json["name"]?.string,
            let status = json["status"]?.string,
            let window = json["window"]?.bool,
            let power = json["power"]?.bool,
            let computer = json["computer"]?.bool else {
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

class LibraryData: NSObject {
    
    var rooms: [[Room]]
    let roomIndex: [Int: (Int, Int)]
    subscript(library: Library) -> [Room] {
        get {
            return rooms[library.areaID - 1]
        }
        set {
            rooms[library.areaID - 1] = newValue
        }
    }
    
    override init() {
        let roomDataFilePath = Bundle.main.url(forResource: "RoomData", withExtension: ".json")!
        let data = try! Data(contentsOf: roomDataFilePath)
        let decoder = JSONDecoder()
        rooms = try! decoder.decode([[Room]].self, from: data)
        var roomIndex = [Int: (Int, Int)]()
        for (firstIndex, roomForLibrary) in rooms.enumerated() {
            for (secoundIndex, room) in roomForLibrary.enumerated() {
                roomIndex[room.id] = (firstIndex, secoundIndex)
            }
        }
        self.roomIndex = roomIndex
        super.init()
    }
}
