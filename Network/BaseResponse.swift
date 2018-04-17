//
//  APIResponse.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

struct BaseResponse: Codable {
    let status: String
    let code: String
    let message: String
}

struct APIResponse<T: Codable>: Codable {
    let status: String
    let code: String
    let message: String
    let data: T
}
