//
//  SeatReservation.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

struct SeatReservation: Codable {
    let id: Int
    let date: String
    let begin: String
    let end: String
    let awayBegin: String?
    let awayEnd: String?
    let loc: String
    let stat: String
}
