//
//  SeatResponse.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/22.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

struct SeatHistoryData: Codable {
    let reservations: [SeatReservation]
}

typealias SeatHistoryResponse = SeatAPIResponse<SeatHistoryData>
typealias SeatCurrentReservationResponse = SeatAPIArrayResponse<SeatCurrentReservation>

struct SeatStartTimeData: Codable {
    let startTimes: [SeatTime]
}
typealias SeatStartTimeResponse = SeatAPIResponse<SeatStartTimeData>
