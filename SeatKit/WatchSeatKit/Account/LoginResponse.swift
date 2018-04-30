//
//  LoginResponse.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import WatchKit

public struct SeatLoginData: Codable {
    public let token: String
}

public typealias SeatLoginResponse = SeatAPIResponse<SeatLoginData>
