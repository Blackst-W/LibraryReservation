//
//  LoginResponse.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

struct LoginData: Codable {
    let token: String
}

typealias LoginResponse = APIResponse<LoginData>
