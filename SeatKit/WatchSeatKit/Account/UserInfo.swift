//
//  UserInfo.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/19.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import WatchKit
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

public struct UserInfo: Codable {
    public let id: Int
    public let enabled: Bool
    public let name: String
    public let username: String
    public let status: String
    public let checkedIn: Bool
    public let violationCount: Int
}

public typealias UserInfoResponse = SeatAPIResponse<UserInfo>
 
