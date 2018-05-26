//
//  RecentUsedSeat.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/05/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import Foundation

public struct ReducedSeat: Codable {
    public let id: Int
    public let name: String
    public let layout: SeatLayout
    
    public init(seat: Seat) {
        id = seat.id
        name = seat.name
        layout = seat.layout
    }
}

public struct SeatLocationData: Codable {
    public let cols: Int
    public let rows: Int
    public let seats: [ReducedSeat]
    
    public init(cols: Int, rows: Int, seats: [ReducedSeat]) {
        self.cols = cols
        self.rows = rows
        self.seats = seats
    }
    
}

public struct DetailSeat: Codable {
    public let seat: Seat
    public let room: Room
    public let library: Library
    public let startTime: SeatTime
    public let endTime: SeatTime
    public let date: Date
    public let location: SeatLocationData
    
    public init(seat: Seat, room: Room, library: Library, startTime: SeatTime, endTime: SeatTime, date: Date, location: SeatLocationData) {
        self.seat = seat
        self.room = room
        self.library = library
        self.startTime = startTime
        self.endTime = endTime
        self.date = date
        self.location = location
    }
    
}

extension DetailSeat: Equatable {
    public static func==(lhs: DetailSeat, rhs: DetailSeat) -> Bool {
        return lhs.seat == rhs.seat
    }
}
