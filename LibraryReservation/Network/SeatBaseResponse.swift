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
    
    var statusCode: Int? {
        return Int(code)
    }
    
    var localizedDescription: String {
        guard let statusCode = statusCode else {
            return "SeatBaseResponse.unknownError".localized(arguments: code, message)
        }
        switch statusCode {
        case 0:
            return "SeatBaseResponse.success".localized
        default:
            return "SeatBaseResponse.unknownError".localized(arguments: code, message)
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

struct SeatAPIArrayResponse<T: Codable>: Codable {
    let status: String
    let code: String
    let message: String
    let data: [T]
}
