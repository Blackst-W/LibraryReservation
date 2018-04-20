//
//  SeatData.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/20.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

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
}

struct Room: Codable {
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

class LibraryData: NSObject {
    
    var rooms: [[Room]]
    let roomIndex: [Int: (Int, Int)]
    subscript(library: Library) -> [Room] {
        get {
            return rooms[library.areaID - 1]
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
