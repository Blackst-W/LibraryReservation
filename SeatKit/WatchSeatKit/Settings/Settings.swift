
//
//  Settings.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import WatchKit

public extension Notification.Name {
    public static let PasswordSettingChanged = Notification.Name("kPasswordSettingChangedNotification")
    public static let AutoLoginSettingChanged = Notification.Name("kAutoLoginSettingChangedNotification")
    public static let NotificationSettingsChanged = Notification.Name("kNotificationSettingsChangedNotification")
}

public struct SeatNotificationSettings: Codable {
    public var make: Bool
    public var upcoming: Bool
    public var end: Bool
    public var tempAway: Bool
    
    public static let `default` = SeatNotificationSettings(make: true, upcoming: true, end: true, tempAway: false)
    
    public init(make: Bool, upcoming: Bool, end: Bool, tempAway: Bool) {
        self.make = make
        self.upcoming = upcoming
        self.end = end
        self.tempAway = tempAway
    }
}

public struct MeetingRoomNotificationSettings: Codable {
    
    public var make: Bool
    public var upcoming: Bool
    public var end: Bool
    
    public static let `default` = MeetingRoomNotificationSettings(make: true, upcoming: true, end: true)
    
    public init(make: Bool, upcoming: Bool, end: Bool) {
        self.make = make
        self.upcoming = upcoming
        self.end = end
    }
}

public struct NotificationSettings: Codable {
    
    public var enable: Bool
    public var seat: SeatNotificationSettings
    public var meetingRoom: MeetingRoomNotificationSettings
    
    public static let `default` = NotificationSettings(enable: false, seat: .default, meetingRoom: .default)
    
}

public class Settings: Codable {
    private(set) public var notificationSettings: NotificationSettings {
        didSet {
            NotificationCenter.default.post(name: .NotificationSettingsChanged, object: nil)
        }
    }
    private(set) public var geoFance: Bool
    
    private(set) public var savePassword: Bool {
        didSet {
            NotificationCenter.default.post(name: .PasswordSettingChanged, object: savePassword)
        }
    }
    
    private(set) public var autoLogin: Bool {
        didSet {
            NotificationCenter.default.post(name: .AutoLoginSettingChanged, object: autoLogin)
        }
    }
    
    static private let filePath = "settings.configuration"
    
    public static var shared: Settings = {
        if let settings = Settings.load() {
            return settings
        }else{
            print("Init New Settings")
            let settings = Settings()
            settings.save()
            return settings
        }
    }()
    
    public init() {
        notificationSettings = .default
        geoFance = false
        savePassword = false
        autoLogin = false
    }
    
    func save() {
        let path = GroupURL.appendingPathComponent(Settings.filePath)
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        do {
            try data.write(to: path)
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    public func reload() {
        let fileManager = FileManager.default
        let path = GroupURL.appendingPathComponent(Settings.filePath)
        
        guard let data = try? Data(contentsOf: path) else {
            print("Failed to load data from settings file")
            try? fileManager.removeItem(atPath: path.absoluteString)
            return
        }
        let decoder = JSONDecoder()
        guard let settings = try? decoder.decode(Settings.self, from: data) else {
            print("Failed to load settings from settings file")
            try? fileManager.removeItem(atPath: path.absoluteString)
            return
        }
        notificationSettings = settings.notificationSettings
        savePassword = settings.savePassword
        autoLogin = settings.autoLogin
        geoFance = settings.geoFance
    }
    
    private static func load() -> Settings? {
        let fileManager = FileManager.default
        let path = GroupURL.appendingPathComponent(Settings.filePath)
        
        guard let data = try? Data(contentsOf: path) else {
            print("Failed to load data from settings file")
            try? fileManager.removeItem(atPath: path.absoluteString)
            return nil
        }
        let decoder = JSONDecoder()
        guard let settings = try? decoder.decode(Settings.self, from: data) else {
            print("Failed to load settings from settings file")
            try? fileManager.removeItem(atPath: path.absoluteString)
            return nil
        }
        return settings
    }
    
    public func set(savePassword newValue: Bool) {
        if !newValue {
            autoLogin = false
            savePassword = false
        }else{
            savePassword = true
        }
        save()
    }
    
    public func set(autoLogin newValue: Bool) {
        if newValue {
            savePassword = true
            autoLogin = true
        }else{
            autoLogin = false
        }
        save()
    }
    
    public func enableNotification() {
        notificationSettings.enable = true
        save()
    }
    
    public func disableNotification() {
        notificationSettings.enable = false
        save()
    }
    
    public func update(seatSettings newSettings: SeatNotificationSettings) {
        notificationSettings.seat = newSettings
        save()
    }
    
    public func update(meetingRoomSettings newSettings: MeetingRoomNotificationSettings) {
        notificationSettings.meetingRoom = newSettings
        save()
    }
    
}
