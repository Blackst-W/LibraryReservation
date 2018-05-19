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
//    case colorful
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
        updateAppearance()
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
        let filePath = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("ThemeSettings.archive")
        let data = try! encoder.encode(self)
        do {
            try data.write(to: filePath)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func updateAppearance() {
        var backgroundColor: UIColor!
        var cellBackgroundColor: UIColor!
        var seperateColor: UIColor!
        var navigationBarTintColor: UIColor?
        var navigationTintColor: UIColor?
        var navigationTitleColor: UIColor!
        var statusBarStyle: UIBarStyle!
        var windowColor: UIColor!
        var keyboard: UIKeyboardAppearance!
        switch theme {
        case .black:
            windowColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1137254902, alpha: 1)
            backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1137254902, alpha: 1)
            cellBackgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
            seperateColor = #colorLiteral(red: 0.2078431373, green: 0.2078431373, blue: 0.2156862745, alpha: 1)
            navigationBarTintColor = .black
            navigationTintColor = #colorLiteral(red: 0.9019607843, green: 0.5803921569, blue: 0.137254902, alpha: 1)
            navigationTitleColor = .white
            statusBarStyle = .black
            keyboard = .dark
        case .standard:
            windowColor = .white
            backgroundColor = .groupTableViewBackground
            cellBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            seperateColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8, alpha: 1)
            navigationBarTintColor = nil
            navigationTintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            navigationTitleColor = .black
            statusBarStyle = .default
            keyboard = .default
        }
        
        //MARK: NavigationBar
        let barAppearance = UINavigationBar.appearance()
        barAppearance.barTintColor = navigationBarTintColor
        barAppearance.tintColor = navigationTintColor
        barAppearance.barStyle = statusBarStyle
        let textAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: navigationTitleColor]
        barAppearance.titleTextAttributes = textAttributes
        
        if #available(iOS 11.0, *) {
            barAppearance.largeTitleTextAttributes = textAttributes
        }
        
        //MARK: TableView
        let tableViewAppearance = UITableView.appearance()
        tableViewAppearance.backgroundColor = backgroundColor
        tableViewAppearance.separatorColor = seperateColor
        let cellAppearance = UITableViewCell.appearance()
        cellAppearance.backgroundColor = cellBackgroundColor
        
        //MARK: TextField
        let textFieldAppearance = UITextField.appearance()
        textFieldAppearance.keyboardAppearance = keyboard
        
        //MARK: UIWindow
        UIApplication.shared.delegate!.window!!.backgroundColor = windowColor
        
        SeatRoomTableViewCell.updateAppearance(theme: theme)
    }
    
}
