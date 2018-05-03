//
//  Utilities.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

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
    
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    func localized(comment: String) -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    func localized(arguments: CVarArg...) -> String {
        let localizedTemplate = NSLocalizedString(self, comment: self)
        return withVaList(arguments) { (params) -> String in
            return NSString(format: localizedTemplate, arguments: params) as String
        }
    }
}

func LocalizedString(_ key: String, comment: String, arguments: CVarArg...) -> String {
    return String(format: NSLocalizedString(key, comment: comment), arguments)
}

let TestRoomData: Data? = {
    let roomDataFilePath = Bundle.main.url(forResource: "TestRoomData", withExtension: ".json")!
    let data = try? Data(contentsOf: roomDataFilePath)
    return data
}()

let GroupID = "group.com.westonwu.ios.whu"

extension UserDefaults {
    class var group: UserDefaults {
        return UserDefaults(suiteName: GroupID)!
    }
}

let GroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GroupID)!
