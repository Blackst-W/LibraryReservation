//
//  Settings.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

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

struct Settings: Codable {
    private(set) var notificationSettings: NotificationSettings
    private(set) var geoFance: Bool
    private(set) var savePassword: Bool
    private(set) var autoLogin: Bool
    static private let filePath = "settings.configuration"
    
    static let `default` = Settings(notificationSettings: .default, geoFance: false, savePassword: false, autoLogin: false)
    
    func save() {
        let fileManager = FileManager.default
        var path = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dictPath =  path.appendingPathComponent(Bundle.main.bundleIdentifier!, isDirectory: true)
        if !fileManager.fileExists(atPath: dictPath.absoluteString) {
            do {
                try fileManager.createDirectory(at: dictPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                fatalError()
            }
        }
        path.appendPathComponent("\(Bundle.main.bundleIdentifier!)/\(Settings.filePath)")
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self)
        do {
            try data.write(to: path)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func load() -> Settings? {
        let fileManager = FileManager.default
        var path = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dictPath =  path.appendingPathComponent(Bundle.main.bundleIdentifier!, isDirectory: true)
        var dictExist = false
        let pointer = UnsafePointer<Bool>()
        fileManager.fileExists(atPath: dictPath, isDirectory: pointer)
        path = dictPath.appendingPathComponent(Settings.filePath)
        do {
            try fileManager.createDirectory(at: dictPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
            fatalError()
        }
        
        
        guard fileManager.fileExists(atPath: path.absoluteString) else {
            print("Settings not found")
            return nil
        }
        guard let data = try? Data(contentsOf: path) else {
            print("Failed to load data from settings file")
            try? fileManager.removeItem(at: path)
            return nil
        }
        let decoder = JSONDecoder()
        guard let settings = try? decoder.decode(Settings.self, from: data) else {
            print("Failed to load settings from settings file")
            try? fileManager.removeItem(at: path)
            return nil
        }
        return settings
    }
    
}
