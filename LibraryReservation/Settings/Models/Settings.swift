
//
//  Settings.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let PasswordSettingChanged = Notification.Name("kPasswordSettingChangedNotification")
    static let AutoLoginSettingChanged = Notification.Name("kAutoLoginSettingChangedNotification")
    static let NotificationSettingsChanged = Notification.Name("kNotificationSettingsChangedNotification")
}

struct SeatNotificationSettings: Codable {
    let make: Bool
    let upcoming: Bool
    let end: Bool
    let tempAway: Bool
    
    static let `default` = SeatNotificationSettings(make: true, upcoming: true, end: true, tempAway: false)
    
}

struct MeetingRoomNotificationSettings: Codable {
    
    let make: Bool
    let upcoming: Bool
    let end: Bool
    
    static let `default` = MeetingRoomNotificationSettings(make: true, upcoming: true, end: true)
    
}

struct NotificationSettings: Codable {
    
    let enable: Bool
    let seat: SeatNotificationSettings
    let meetingRoom: MeetingRoomNotificationSettings
    
    static let `default` = NotificationSettings(enable: false, seat: .default, meetingRoom: .default)
    
}

class Settings: Codable {
    private(set) var notificationSettings: NotificationSettings
    private(set) var geoFance: Bool
    
    private(set) var savePassword: Bool {
        didSet {
            NotificationCenter.default.post(name: .PasswordSettingChanged, object: savePassword)
        }
    }
    
    private(set) var autoLogin: Bool {
        didSet {
            NotificationCenter.default.post(name: .AutoLoginSettingChanged, object: autoLogin)
        }
    }
    
    static private let filePath = "settings.configuration"
    
    static var shared: Settings = {
        if let settings = Settings.load() {
            return settings
        }else{
            print("Init New Settings")
            let settings = Settings()
            settings.save()
            return settings
        }
    }()
    
    init() {
        notificationSettings = .default
        geoFance = false
        savePassword = false
        autoLogin = false
    }
    
    func save() {
        let fileManager = FileManager.default
        var path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        let dirPath = path + "/\(Bundle.main.bundleIdentifier!)"
        if !fileManager.fileExists(atPath: dirPath) {
            do {
                try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                fatalError()
            }
        }

        path = dirPath + "/\(Settings.filePath)"
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        do {
            try data.write(to: URL(fileURLWithPath: path))
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private static func load() -> Settings? {
        let fileManager = FileManager.default
        
        var path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        let dirPath =  path + "/\(Bundle.main.bundleIdentifier!)"
        path = dirPath + "/\(Settings.filePath)"
        
        guard fileManager.fileExists(atPath: path) else {
            print("Settings not found")
            return nil
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            print("Failed to load data from settings file")
            try? fileManager.removeItem(atPath: path)
            return nil
        }
        let decoder = JSONDecoder()
        guard let settings = try? decoder.decode(Settings.self, from: data) else {
            print("Failed to load settings from settings file")
            try? fileManager.removeItem(atPath: path)
            return nil
        }
        return settings
    }
    
    func deletePassword() {
        guard savePassword else {
            return
        }
        savePassword = false
        autoLogin = false
        save()
    }
    
}
