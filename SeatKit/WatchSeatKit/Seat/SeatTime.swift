//
//  SeatTime.swift
//  SeatKit
//
//  Created by Weston Wu on 2018/05/17.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

/*
 {
     "id": "now",
     "value": "现在"
 }
 {
    "id": "600",
    "value: "10:00"
 }
*/

public struct SeatTime: Codable, Equatable {

    public let id: String
    public let value: String
    public var minutes: Int? {
        return Int(id)
    }
    
    public init(time: Int) {
        id = String(time)
        let hour = time / 60
        let min = time % 60
        let hourString = hour < 10 ? "0\(hour)" : "\(hour)"
        let minString = min < 10 ? "0\(min)" : "\(min)"
        value = hourString + ":" + minString
    }
    
    public var next: SeatTime? {
        if let time = minutes {
            return SeatTime(time: time + 30)
        }else{
            return nil
        }
    }
    
    public static func==(lhs: SeatTime, rhs: SeatTime) -> Bool {
        return lhs.id == rhs.id
    }
}
