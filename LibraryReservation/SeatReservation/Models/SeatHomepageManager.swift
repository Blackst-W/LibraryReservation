//
//  SeatHomepageManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/17.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

protocol SeatHomepageManagerDelegate: class {
    
}

class SeatHomepageManager: NSObject {
    private(set) var account: UserAccount?
    weak var delegate: SeatHomepageManagerDelegate?
    
    init(delegate: SeatHomepageManagerDelegate?) {
        self.delegate = delegate
        account = AccountManager.shared.currentAccount
    }
    
    func update(account: UserAccount) {
        self.account = account
    }
    
}
