//
//  SeatResponse.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/22.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

public struct SeatHistoryData: Codable {
    let reservations: [SeatReservation]
}
public typealias SeatHistoryResponse = SeatAPIResponse<SeatHistoryData>

public typealias SeatCurrentReservationResponse = SeatAPIArrayResponse<SeatCurrentReservation>

public typealias SeatLibraryResponse = SeatAPIArrayResponse<Room>

public struct SeatStartTimeData: Codable {
    let startTimes: [SeatTime]
}
public typealias SeatStartTimeResponse = SeatAPIResponse<SeatStartTimeData>


public struct RoomLayoutData: Codable {
    public let roomID: Int
    public let roomName: String
    public let cols: Int
    public let rows: Int
    public let seats: [Seat]
    
    enum CodingKeys: String, CodingKey {
        case roomID = "id"
        case roomName = "name"
        case cols
        case rows
        case layout
        case seats
    }
    
    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        
        init?(intValue: Int) {
            self.init(stringValue: "")
            self.intValue = intValue
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        roomID = try container.decode(Int.self, forKey: .roomID)
        roomName = try container.decode(String.self, forKey: .roomName)
        cols = try container.decode(Int.self, forKey: .cols)
        rows = try container.decode(Int.self, forKey: .rows)
        if let seats = try container.decodeIfPresent([Seat].self, forKey: .seats) {
            self.seats = seats
            return
        }
        var seats = [Seat]()
        let seatDecoder = try container.superDecoder(forKey: .layout)
        let seatContainer = try seatDecoder.container(keyedBy: DynamicCodingKeys.self)
        for key in seatContainer.allKeys {
            if var seat = try? seatContainer.decode(Seat.self, forKey: key) {
                seat.layout = SeatLayout(key: key.stringValue)
                seats.append(seat)
            }
        }
        self.seats = seats
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(roomID, forKey: .roomID)
        try container.encode(roomName, forKey: .roomName)
        try container.encode(cols, forKey: .cols)
        try container.encode(rows, forKey: .rows)
        try container.encode(seats, forKey: .seats)
    }
    
}

public struct SeatTimeFilterResponse: Decodable {
    public let status: Bool
    public let message: String?
    public let seats: [Seat]
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case data
    }
    
    enum SubCodingKeys: String, CodingKey {
        case seats
    }
    
    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int?
        
        init?(intValue: Int) {
            self.init(stringValue: "")
            self.intValue = intValue
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Bool.self, forKey: .status)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        let dataContainer = try container.nestedContainer(keyedBy: SubCodingKeys.self, forKey: .data)
        var seats = [Seat]()
        let seatDecoder = try dataContainer.superDecoder(forKey: .seats)
        let seatContainer = try seatDecoder.container(keyedBy: DynamicCodingKeys.self)
        for key in seatContainer.allKeys {
            if var seat = try? seatContainer.decode(Seat.self, forKey: key) {
                seat.layout = SeatLayout(key: key.stringValue)
                seats.append(seat)
            }
        }
        self.seats = seats
    }
    
}
