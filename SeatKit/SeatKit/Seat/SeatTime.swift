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
    
    public init(time: String) {
        let seperatedTimes = time.components(separatedBy: ":")
        let hour: Int! = Int(seperatedTimes[0])
        let min: Int! = Int(seperatedTimes[1])
        var numId = 480 + ((hour - 8) * 60)
        if min > 0 && min <= 30 {
            numId += 30
        } else if min > 30{
            numId += 60
        }
        self.init(time: numId)
    }
    
    public var next: SeatTime? {
        if let time = minutes {
            return SeatTime(time: time + 30)
        }else{
            return nil
        }
    }
    
    public static func fetchTimeSections(beginTime: SeatTime, endTime: SeatTime) -> [SeatTime] {
        var seatTimes = [SeatTime]()
        var tempId: Int! = Int(beginTime.id)
        let endId: Int! = Int(endTime.id)
        
        while tempId != endId {
            seatTimes.append(SeatTime(time: tempId))
            tempId += 30
        }
        return seatTimes
    }
    
    public static func==(lhs: SeatTime, rhs: SeatTime) -> Bool {
        return lhs.id == rhs.id
    }
}
