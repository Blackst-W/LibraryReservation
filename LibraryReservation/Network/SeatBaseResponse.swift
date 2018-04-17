//
//  APIResponse.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

struct SeatBaseResponse: Codable {
    let status: String
    let code: String
    let message: String
    
    var localizedDescription: String {
        guard let statusCode = Int(code) else {
            return "Unknown Error\nCode: \(self.code)\nMessage: \(message)"
        }
        switch statusCode {
        case 0:
            return "Success"
        default:
            return "Unknown Error\nCode: \(statusCode)\nMessage: \(message)"
        }
    }
    
}

typealias SeatFailedResponse = SeatBaseResponse

struct SeatAPIResponse<T: Codable>: Codable {
    let status: String
    let code: String
    let message: String
    let data: T
}
