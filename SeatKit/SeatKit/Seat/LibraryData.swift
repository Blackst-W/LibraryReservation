//
//  SeatData.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/20.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

public struct RoomLayout: Codable {
    public let col: Int
    public let row: Int
    
    init?(key: String) {
        guard let value = Int(key) else {
            return nil
        }
        row = value / 1000
        col = value % 1000
    }
}

public class LibraryData: NSObject {
    
    public private(set) var rooms: [[Room]]
    public let roomIndex: [Int: (Int, Int)]
    public subscript(library: Library) -> [Room] {
        get {
            return rooms[library.areaID - 1]
        }
        set {
            rooms[library.areaID - 1] = newValue
        }
    }
    
    override init() {
        let roomDataFilePath = Bundle(for: LibraryData.self).url(forResource: "RoomData", withExtension: ".json")!
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
