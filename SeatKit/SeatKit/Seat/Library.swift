//
//  Library.swift
//  SeatKit
//
//  Created by Weston Wu on 2018/05/17.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

public enum Library: String {
    case main = "总馆"
    case engineering = "工学分馆"
    case info = "信息科学分馆"
    case medicine = "医学分馆"
    
    public var areaID: Int {
        switch self {
        case .main:
            return 4
        case .engineering:
            return 2
        case .info:
            return 1
        case .medicine:
            return 3
        }
    }
}
