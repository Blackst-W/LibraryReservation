//
//  RecentUsedSeat.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/05/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import Foundation

struct ReducedSeat: Codable {
    let id: Int
    let name: String
    let layout: SeatLayout
    
    init(seat: Seat) {
        id = seat.id
        name = seat.name
        layout = seat.layout
    }
}

struct SeatLocationData: Codable {
    let cols: Int
    let rows: Int
    let seats: [ReducedSeat]
}

struct DetailSeat: Codable {
    let seat: Seat
    let room: Room
    let library: Library
    let startTime: SeatTime
    let endTime: SeatTime
    let date: Date
    let location: SeatLocationData
}

extension DetailSeat: Equatable {
    static func==(lhs: DetailSeat, rhs: DetailSeat) -> Bool {
        return lhs.seat == rhs.seat
    }
}
