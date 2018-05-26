//
//  Constants.swift
//  WatchApp Extension
//
//  Created by Weston Wu on 2018/05/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import Foundation

let GroupID = "group.com.westonwu.ios.whu"

extension UserDefaults {
    class var group: UserDefaults {
        return UserDefaults(suiteName: GroupID)!
    }
}

let GroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GroupID)!
