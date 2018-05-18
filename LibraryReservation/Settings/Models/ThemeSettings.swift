//
//  ThemeSettings.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/05/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

enum Theme: Int, Codable {
    case standard
    case black
    case colorful
}

extension Notification.Name {
    static let ThemeChanged = Notification.Name("ThemeChangedNotification")
}

class ThemeSettings: NSObject, Codable {
    
    private(set) var theme = Theme.standard
    
    static let shared = {
        return ThemeSettings.load() ?? ThemeSettings()
    }()
    
    private override init() {
        super.init()
    }
    
    func update(theme: Theme) {
        self.theme = theme
        NotificationCenter.default.post(name: .ThemeChanged, object: theme)
        save()
    }
    
    private static func load() -> ThemeSettings? {
        let filePath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! + "/ThemeSettings.archive"
        let fileManager = FileManager.default
        let decoder = JSONDecoder()
        guard fileManager.fileExists(atPath: filePath),
            let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
            let newSettings = try? decoder.decode(ThemeSettings.self, from: data) else {
                try? fileManager.removeItem(atPath: filePath)
                return nil
        }
        return newSettings
    }
    
    
    private func save() {
        let encoder = JSONEncoder()
        let filePath = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("AppSettings.archive")
        let data = try! encoder.encode(self)
        do {
            try data.write(to: filePath)
        }catch{
            print(error.localizedDescription)
        }
    }
    
}
