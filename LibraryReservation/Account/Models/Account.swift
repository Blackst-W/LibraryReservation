//
//  Account.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

struct UserAccount: Codable {
    let username: String
    var password: String?
    var token: String?
}
