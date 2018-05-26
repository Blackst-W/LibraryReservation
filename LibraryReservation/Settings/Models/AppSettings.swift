//
//  AppSettings.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/05/09.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import CoreLocation

extension Notification.Name {
    static let LibraryConfigurationChanged = Notification.Name("LibraryConfigurationChangedNotification")
    static let LibraryInfosChanged = Notification.Name("LibraryInfosChanged")
}

struct LibraryData: Codable {
    let librarys: [LibraryInfo]
}

struct LibraryInfo: Codable {
    let name: String
    let ID: Int
    let location: CLLocation
    
    enum CodingKeys: String, CodingKey {
        case name
        case ID = "libraryID"
        case latitude
        case longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        ID = try container.decode(Int.self, forKey: .ID)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        location = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(ID, forKey: .ID)
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    init(name: String, ID: Int, location: CLLocation) {
        self.name = name
        self.ID = ID
        self.location = location
    }
    
    init(name: String, ID: Int, latitude: Double, longitude: Double) {
        self.name = name
        self.ID = ID
        location = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    static let defaultAll: [LibraryInfo] = [
        LibraryInfo(name: "信息学部", ID: 1, latitude: 30.529123110644477, longitude: 114.36136153521954),
        LibraryInfo(name: "工学分馆", ID: 2, latitude: 30.54373, longitude: 114.361489),
        LibraryInfo(name: "医学分馆", ID: 3, latitude: 30.554546, longitude: 114.356915),
        LibraryInfo(name: "总馆", ID: 4, latitude: 30.535002, longitude: 114.36285)
    ]
    
}

struct LibraryConfiguration: Codable {
    let startTime: String
    var startMinutes: Int {
        let timeComponents = startTime.split(separator: ":")
        let hour = Int(timeComponents[0])!
        let minute = Int(timeComponents[1])!
        return hour * 60 + minute
    }
    
    let endTime: String
    var endMinutes: Int {
        let timeComponents = endTime.split(separator: ":")
        let hour = Int(timeComponents[0])!
        let minute = Int(timeComponents[1])!
        return hour * 60 + minute
    }
    
    let reserveTime: String
    var reserveTimeComponents: DateComponents {
        let timeComponents = endTime.split(separator: ":")
        let hour = Int(timeComponents[0])!
        let minute = Int(timeComponents[1])!
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return components
    }
    
    let version: Int
    let updateNote: String
    
    init() {
        startTime = "8:00"
        endTime = "22:30"
        reserveTime = "22:45"
        version = 1
        updateNote = ""
    }
}

class AppSettings: NSObject, Codable {
    
    static let shared: AppSettings = {
        let shared = AppSettings.load() ?? AppSettings()
        shared.refresh()
        return shared
    }()
    
    private(set) var libraryConfiguration = LibraryConfiguration()
    private(set) var librarys = LibraryInfo.defaultAll
    private(set) var needDisplayInfo = false
    
    private override init() {
        super.init()
    }
    
    private static func load() -> AppSettings? {
        let filePath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! + "/AppSettings.archive"
        let fileManager = FileManager.default
        let decoder = JSONDecoder()
        guard fileManager.fileExists(atPath: filePath),
            let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
            let newSettings = try? decoder.decode(AppSettings.self, from: data) else {
                try? fileManager.removeItem(atPath: filePath)
                return nil
        }
        return newSettings
    }
    
    func refresh() {
        let session = URLSession.shared
        let hostURL = URL(string: "https://ios.westonwu.com/swiftseat/api")!
        let configurationURL = hostURL.appendingPathComponent("configuration")
        let librarysURL = hostURL.appendingPathComponent("library")
        session.dataTask(with: configurationURL) { (data, response, error) in
            guard let data = data else {
                return
            }
            let decoder = JSONDecoder()
            do {
                let newConfiguration = try decoder.decode(LibraryConfiguration.self, from: data)
                self.update(configuration: newConfiguration)
            }catch{
                print(error.localizedDescription)
                return
            }
        }.resume()
        session.dataTask(with: librarysURL) { (data, response, error) in
            guard let data = data else {
                return
            }
            let decoder = JSONDecoder()
            do {
                let libraryData = try decoder.decode(LibraryData.self, from: data)
                self.update(librarys: libraryData.librarys)
            }catch{
                print(error.localizedDescription)
                return
            }
        }.resume()
    }
    
    func update(configuration: LibraryConfiguration) {
        guard libraryConfiguration.version < configuration.version else {
            return
        }
        libraryConfiguration = configuration
        if configuration.updateNote != "" {
            needDisplayInfo = true
        }
        save()
        NotificationCenter.default.post(name: .LibraryConfigurationChanged, object: nil)
    }
    
    func update(librarys: [LibraryInfo]) {
        self.librarys = librarys
        save()
        NotificationCenter.default.post(name: .LibraryInfosChanged, object: nil)
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
