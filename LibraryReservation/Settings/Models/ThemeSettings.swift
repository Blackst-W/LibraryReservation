//
//  ThemeSettings.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/05/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

extension UIColor {
    var contrastTextColor: UIColor {
        let redPointer = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        let greenPointer = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        let bluePointer = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        guard getRed(redPointer, green: greenPointer, blue: bluePointer, alpha: nil) else {
            fatalError()
        }
        if redPointer.pointee + greenPointer.pointee + bluePointer.pointee >= 1.5 {
            return .black
        }else{
            return .white
        }
    }
}

enum Theme: String, Codable {
    case standard = "Standard"
    case dark = "Dark"
//    case colorful
}

class ThemeConfiguration: NSObject {
    
    private(set) var theme: Theme
    private(set) var backgroundColor: UIColor!
    private(set) var secondaryBackgroundColor: UIColor!
    private(set) var shadowColor: UIColor!
    private(set) var tintColor: UIColor!
    private(set) var textColor: UIColor!
    private(set) var highlightTextColor: UIColor!
    private(set) var secondaryTextColor: UIColor!
    private(set) var barTintColor: UIColor!
    private(set) var tableViewSeperatorColor: UIColor!
    private(set) var deactiveColor: UIColor!
    private(set) var warnColor: UIColor!
    
    private(set) var seatAvailableNowColor: UIColor!
    private(set) var seatAvailableColor: UIColor!
    private(set) var seatFilterColor: UIColor!
    private(set) var seatUnavailableColor: UIColor!
    private(set) var seatHighlightColor: UIColor!
    private(set) var seatViewedColor: UIColor!
    
    private(set) var seatAvailableNowTextColor: UIColor!
    private(set) var seatAvailableTextColor: UIColor!
    private(set) var seatFilterTextColor: UIColor!
    private(set) var seatUnavailableTextColor: UIColor!
    private(set) var seatHighlightTextColor: UIColor!
    private(set) var seatViewedTextColor: UIColor!
    
    private(set) var keyboardAppearance: UIKeyboardAppearance!
    private(set) var statusBarStyle: UIBarStyle!
    private(set) var blurEffect: UIBlurEffect!
    
    static let current = ThemeConfiguration(theme: .standard)
    
    init(theme: Theme) {
        self.theme = theme
        super.init()
        update(theme: theme)
    }
    
    func update(theme: Theme) {
        if #available(iOS 11.0, *) {
            backgroundColor = UIColor(named: "\(theme.rawValue)BackgroundColor")!
            shadowColor = UIColor(named: "\(theme.rawValue)ShadowColor")!
            tintColor = UIColor(named: "\(theme.rawValue)TintColor")!
            textColor = UIColor(named: "\(theme.rawValue)TextColor")!
            highlightTextColor = UIColor(named: "\(theme.rawValue)HighlightTextColor")!
            secondaryTextColor = UIColor(named: "\(theme.rawValue)SecondaryTextColor")!
            barTintColor = UIColor(named: "\(theme.rawValue)BarTintColor")!
            tableViewSeperatorColor = UIColor(named: "\(theme.rawValue)TableViewSeperatorColor")!
            secondaryBackgroundColor = UIColor(named: "\(theme.rawValue)SecondaryBackgroundColor")!
            deactiveColor = UIColor(named: "\(theme.rawValue)DeactiveColor")!
            warnColor = UIColor(named: "\(theme.rawValue)WarnColor")!
            seatFilterColor = UIColor(named: "\(theme.rawValue)SeatFilterColor")!
            seatViewedColor = UIColor(named: "\(theme.rawValue)SeatViewedColor")!
            seatAvailableNowColor = UIColor(named: "\(theme.rawValue)SeatAvailableNowColor")!
            seatAvailableColor = UIColor(named: "\(theme.rawValue)SeatAvailableColor")!
            seatHighlightColor = UIColor(named: "\(theme.rawValue)SeatHighlightColor")!
            seatUnavailableColor = UIColor(named: "\(theme.rawValue)SeatUnavailableColor")!
            
            seatFilterTextColor = UIColor(named: "\(theme.rawValue)SeatFilterTextColor")!
            seatViewedTextColor = UIColor(named: "\(theme.rawValue)SeatViewedTextColor")!
            seatAvailableNowTextColor = UIColor(named: "\(theme.rawValue)SeatAvailableNowTextColor")!
            seatAvailableTextColor = UIColor(named: "\(theme.rawValue)SeatAvailableTextColor")!
            seatHighlightTextColor = UIColor(named: "\(theme.rawValue)SeatHighlightTextColor")!
            seatUnavailableTextColor = UIColor(named: "\(theme.rawValue)SeatUnavailableTextColor")!

        } else {
            switch theme {
            case .dark:
                backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1137254902, alpha: 1)
                shadowColor = .white
                tintColor = #colorLiteral(red: 0.9019607843, green: 0.5803921569, blue: 0.137254902, alpha: 1)
                textColor = .white
                highlightTextColor = .black
                secondaryTextColor = .lightGray
                barTintColor = .black
                tableViewSeperatorColor = #colorLiteral(red: 0.2078431373, green: 0.2078431373, blue: 0.2156862745, alpha: 1)
                secondaryBackgroundColor = #colorLiteral(red: 0.1882352941, green: 0.1882352941, blue: 0.1882352941, alpha: 1)
                deactiveColor = .darkGray
                warnColor = .red
                
                seatFilterColor = #colorLiteral(red: 0.7960784314, green: 0, blue: 0.937254902, alpha: 1)
                seatViewedColor = #colorLiteral(red: 0.5583756345, green: 0.002555139019, blue: 0.3713010098, alpha: 1)
                seatAvailableNowColor = #colorLiteral(red: 0.9019607843, green: 0.5803921569, blue: 0.137254902, alpha: 1)
                seatAvailableColor = #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
                seatHighlightColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
                seatUnavailableColor = .black
                seatAvailableNowTextColor = .white
                seatAvailableTextColor = #colorLiteral(red: 0.9019607843, green: 0.5803921569, blue: 0.137254902, alpha: 1)
                seatFilterTextColor = .white
                seatUnavailableTextColor = .lightGray
                seatHighlightTextColor = .white
                seatViewedTextColor = .white
            case .standard:
                backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.9372549057, blue: 0.9568627477, alpha: 1)
                shadowColor = .black
                tintColor = #colorLiteral(red: 0.2588235294, green: 0.4666666667, blue: 0.9568627451, alpha: 1)
                textColor = .black
                highlightTextColor = .white
                secondaryTextColor = .darkGray
                barTintColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.968627451, alpha: 1)
                tableViewSeperatorColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8, alpha: 1)
                secondaryBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                deactiveColor = .lightGray
                warnColor = .red
                
                seatFilterColor = #colorLiteral(red: 0, green: 0.5019607843, blue: 1, alpha: 1)
                seatViewedColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
                seatAvailableNowColor = #colorLiteral(red: 0.3882352941, green: 0.8549019608, blue: 0.2196078431, alpha: 1)
                seatAvailableColor = .white
                seatHighlightColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
                seatUnavailableColor = .darkGray
                seatAvailableNowTextColor = .white
                seatAvailableTextColor = .black
                seatFilterTextColor = .white
                seatUnavailableTextColor = .lightGray
                seatHighlightTextColor = .white
                seatViewedTextColor = .white
                
            }
            // Fallback on earlier versions
        }
        
        switch theme {
        case .dark:
            keyboardAppearance = .dark
            statusBarStyle = .black
            blurEffect = UIBlurEffect(style: .dark)
        case .standard:
            keyboardAppearance = .default
            statusBarStyle = .default
            blurEffect = UIBlurEffect(style: .light)
        }
        
    }
    
}

extension Notification.Name {
    static let ThemeChanged = Notification.Name("ThemeChangedNotification")
}

class ThemeSettings: NSObject, Codable {
    
    private(set) var theme = Theme.standard
    
    static let shared = { () -> ThemeSettings in
        let settings = ThemeSettings.load() ?? ThemeSettings()
        ThemeConfiguration.current.update(theme: settings.theme)
        return settings
    }()
    
    private override init() {
        super.init()
    }
    
    func update(theme: Theme) {
        self.theme = theme
        ThemeConfiguration.current.update(theme: theme)
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
        let configuration = ThemeConfiguration.current
        //MARK: NavigationBar
        let barAppearance = UINavigationBar.appearance()
        barAppearance.barTintColor = configuration.barTintColor
        barAppearance.tintColor = configuration.tintColor
        barAppearance.barStyle = configuration.statusBarStyle
        let textAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: configuration.textColor]
        barAppearance.titleTextAttributes = textAttributes
        
        if #available(iOS 11.0, *) {
            barAppearance.largeTitleTextAttributes = textAttributes
        }
        
        //MARK: TableView
        let tableViewAppearance = UITableView.appearance()
        tableViewAppearance.backgroundColor = configuration.backgroundColor
        tableViewAppearance.separatorColor = configuration.tableViewSeperatorColor
        let cellAppearance = UITableViewCell.appearance()
        cellAppearance.backgroundColor = configuration.secondaryBackgroundColor
        
        //MARK: TextField
        let textFieldAppearance = UITextField.appearance()
        textFieldAppearance.keyboardAppearance = configuration.keyboardAppearance
        
        //MARK: UIWindow
        UIApplication.shared.delegate!.window!!.backgroundColor = configuration.backgroundColor
        
        UISwitch.appearance().tintColor = configuration.tintColor
        SeatRoomTableViewCell.updateAppearance(theme: theme)
    }
    
}
