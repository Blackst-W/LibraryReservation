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
