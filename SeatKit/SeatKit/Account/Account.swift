//
//  Account.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

public struct UserAccount: Codable {
    public let username: String
    public var password: String?
    public var token: String?
    
    public init(username: String, password: String?, token: String?) {
        self.username = username
        self.password = password
        self.token = token
    }
    
}
