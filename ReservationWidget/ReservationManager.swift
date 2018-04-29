//
//  ReservationManager.swift
//  ReservationWidget
//
//  Created by Weston Wu on 2018/04/30.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
let GroupID = "group.com.westonwu.ios.whu"
let GroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GroupID)!
extension UserDefaults {
    class var group: UserDefaults {
        return UserDefaults(suiteName: GroupID)!
    }
}

class ReservationManager: NSObject {
    override init() {
        super.init()
    }
    
    func loadAccount() {
        
    }
    
}
