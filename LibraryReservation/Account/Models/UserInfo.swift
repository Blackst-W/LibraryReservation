//
//  UserInfo.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/19.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
/*
{
    "id": 6956,
    "enabled": true,
    "name": "吴文鉴",
    "username": "2015301200030",
    "username2": null,
    "status": "NORMAL",
    "lastLogin": "2018-04-19T12:07:25.000",
    "checkedIn": false,
    "lastIn": null,
    "lastOut": null,
    "lastInBuildingId": null,
    "lastInBuildingName": null,
    "violationCount": 1
}
*/

struct UserInfo: Codable {
    let id: Int
    let enabled: Bool
    let name: String
    let username: String
    let status: String
    let checkedIn: Bool
    let violationCount: Int
}

typealias UserInfoResponse = SeatAPIResponse<UserInfo>
 
