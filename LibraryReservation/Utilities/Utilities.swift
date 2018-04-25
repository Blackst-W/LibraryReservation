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

extension UIAlertController {
    func addActions(_ actions: [UIAlertAction]) {
        actions.forEach { (action) in
            self.addAction(action)
        }
    }
}

extension String {
    init?(_ intValue: Int?) {
        guard let intValue = intValue else {return nil}
        self = String(intValue)
    }
}

let CommonHeader: [String: String] = ["Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
                                      "User-Agent": "doSingle/11 CFNetwork/897.15 Darwin/17.5.0",
                                      "Accept-Encoding":"gzip, deflate"]
