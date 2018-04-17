//
//  Utilities.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

extension String {
    var urlQueryEncoded: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}

let SeatAPIURL = URL(string: "https://seat.lib.whu.edu.cn:8443/rest/")
