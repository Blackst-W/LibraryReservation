//
//  APIResponse.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

public struct SeatBaseResponse: Codable {
    public let status: String
    public let code: String
    public let message: String
    
    public var statusCode: Int? {
        return Int(code)
    }
}

public typealias SeatFailedResponse = SeatBaseResponse

public struct SeatAPIResponse<T: Codable>: Codable {
    public let status: String
    public let code: String
    public let message: String
    public let data: T
}

public struct SeatAPIArrayResponse<T: Codable>: Codable {
    public let status: String
    public let code: String
    public let message: String
    public let data: [T]
}
