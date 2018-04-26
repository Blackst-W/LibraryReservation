//
//  SeatReservation.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

protocol SeatCurrentReservationRepresentable {
    var id: Int {get}
    var time: SeatReservationTime {get}
    var location: SeatLocation? {get}
    var currentState: SeatCurrentReservationState {get}
    var seatID: Int? {get}
    var receiptID: String? {get}
    var awayStart: Date? {get}
    var isStarted: Bool {get}
    var rawLocation: String {get}
    var rawDate: String {get}
    var rawBegin: String {get}
    var rawEnd: String {get}
}

struct SeatReservationTime {
    let date: Date
    let start: Date
    let end: Date
    var message: String? = nil
    var duration: Int {
        return Int(end.timeIntervalSince(start)) / 60
    }
}

struct SeatLocation {
    let floor: Int
    let library: Library
    let room: String
    let seat: Int
    let detail: String
    init?(location: String) {
        var floorIndex = 0
        var floorNo = 0
        for (index, character) in location.enumerated() {
            if let floorNumber = Int(String(character)) {
                floorNo = floorNumber
                floorIndex = index
                break
            }
        }
        if floorNo == 0 {
            return nil
        }
        floor = floorNo
        let libStartIndex = location.index(location.startIndex, offsetBy: 0)
        let libEndIndex = location.index(location.startIndex, offsetBy: floorIndex)
        guard let lib = Library(rawValue: String(location[libStartIndex..<libEndIndex])) else {
            return nil
        }
        library = lib
        let roomStartIndex = location.index(libEndIndex, offsetBy: 2)
        let roomEndIndex = location.index(location.endIndex, offsetBy: -4)
        var originRoom = String(location[roomStartIndex..<roomEndIndex])
        if let areaEndIndex = originRoom.index(of: "区") {
            let areaBeginIndex = originRoom.index(originRoom.startIndex, offsetBy: 0)
            originRoom.replaceSubrange(areaBeginIndex...areaEndIndex, with: "")
        }
        if let floorEndIndex = originRoom.index(of: "楼") {
            let floorStartIndex = originRoom.index(floorEndIndex, offsetBy: -1)
            originRoom.replaceSubrange(floorStartIndex...floorEndIndex, with: "")
        }
        room = originRoom
        let seatStartIndex = location.index(roomEndIndex, offsetBy: 0)
        let seatEndIndex = location.index(location.endIndex, offsetBy: -1)
        guard let seatNo = Int(String(location[seatStartIndex..<seatEndIndex])) else {
            return nil
        }
        seat = seatNo
        detail = location
    }
    
    init?(currentLocation location: String) {
        var floorIndex = 0
        var floorNo = 0
        for (index, character) in location.enumerated() {
            if let floorNumber = Int(String(character)) {
                floorNo = floorNumber
                floorIndex = index
                break
            }
        }
        if floorNo == 0 {
            return nil
        }
        floor = floorNo
        let libStartIndex = location.index(location.startIndex, offsetBy: 0)
        let libEndIndex = location.index(location.startIndex, offsetBy: floorIndex)
        guard let lib = Library(rawValue: String(location[libStartIndex..<libEndIndex])) else {
            return nil
        }
        library = lib
        let roomStartIndex = location.index(libEndIndex, offsetBy: 2)
        let roomEndIndex = location.index(of: "，")!
        var originRoom = String(location[roomStartIndex..<roomEndIndex])
        if let areaEndIndex = originRoom.index(of: "区") {
            let areaBeginIndex = originRoom.index(originRoom.startIndex, offsetBy: 0)
            originRoom.replaceSubrange(areaBeginIndex...areaEndIndex, with: "")
        }
        if let floorEndIndex = originRoom.index(of: "楼") {
            let floorStartIndex = originRoom.index(floorEndIndex, offsetBy: -1)
            originRoom.replaceSubrange(floorStartIndex...floorEndIndex, with: "")
        }
        room = originRoom
        let seatStartIndex = location.index(roomEndIndex, offsetBy: 4)
        let seatEndIndex = location.index(location.endIndex, offsetBy: 0)
        guard let seatNo = Int(String(location[seatStartIndex..<seatEndIndex])) else {
            return nil
        }
        seat = seatNo
        detail = location
    }
}

enum SeatCurrentReservationState {
    case invalid
    case upcoming(`in`: Int)
    case ongoing(left: Int)
    case tempAway(remain: Int)
    case late(remain: Int)
    case autoEnd(`in`: Int)
    
    var localizedKey: String {
        switch self {
        case .invalid:
            return "invalid"
        case .upcoming(_):
            return "upcoming"
        case .ongoing(_):
            return "ongoing"
        case .tempAway(_):
            return "tempAway"
        case .late(_):
            return "late"
        case .autoEnd(_):
            return "autoEnd"
        }
    }
    
    var localizedState: String {
        return "SeatCurrentReservationState.\(self.localizedKey)".localized
    }
}

enum SeatReservationState: String {
    case reserve = "RESERVE"        //未开始的预约
    case complete = "COMPLETE"      //完成的预约
    case miss = "MISS"              //失约
    case cancel = "CANCEL"          //预约已取消
    case incomplete = "INCOMPLETE"  //暂离超时的预约
    case checkIn = "CHECK_IN"       //正在进行的预约
    case away = "AWAY"              //暂离
    case stop = "STOP"              //提前结束
    case unknown
    
    var localizedKey: String {
        switch self {
        case .reserve:
            return "reserve"
        case .complete:
            return "complete"
        case .miss:
            return "miss"
        case .cancel:
            return "cancel"
        case .incomplete:
            return "incomplete"
        case .checkIn:
            return "checkIn"
        case .away:
            return "away"
        case .stop:
            return "stop"
        case .unknown:
            return "unknown"
        }
    }
    
    var localizedDescription: String {
        return "SeatReservationState.\(self.localizedKey)".localized
    }
}

struct SeatReservation: Codable {
    
    let id: Int
    let rawDate: String
    let rawBegin: String
    let rawEnd: String
    let rawAwayBegin: String?
    let rawAwayEnd: String?
    let rawLocation: String
    let rawState: String
    
    let time: SeatReservationTime
    let location: SeatLocation?
    let state: SeatReservationState
    
    let seatID: Int? = nil
    let receiptID: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case rawDate = "date"
        case rawBegin = "begin"
        case rawEnd = "end"
        case rawAwayBegin = "awayBegin"
        case rawAwayEnd = "awayEnd"
        case rawLocation = "loc"
        case rawState = "stat"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        rawDate = try container.decode(String.self, forKey: .rawDate)
        rawBegin = try container.decode(String.self, forKey: .rawBegin)
        rawEnd = try container.decode(String.self, forKey: .rawEnd)
        rawAwayBegin = try container.decode(String?.self, forKey: .rawAwayBegin)
        rawAwayEnd = try container.decode(String?.self, forKey: .rawAwayEnd)
        rawLocation = try container.decode(String.self, forKey: .rawLocation)
        rawState = try container.decode(String.self, forKey: .rawState)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: rawDate)!
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let start = formatter.date(from: "\(rawDate) \(rawBegin)")!
        let end = formatter.date(from: "\(rawDate) \(rawEnd)")!
        
        time = SeatReservationTime(date: date, start: start, end: end, message: nil)
        location = SeatLocation(location: rawLocation)
        state = SeatReservationState(rawValue: rawState) ?? .unknown
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(rawDate, forKey: .rawDate)
        try container.encode(rawBegin, forKey: .rawBegin)
        try container.encode(rawEnd, forKey: .rawEnd)
        try container.encode(rawAwayBegin, forKey: .rawAwayBegin)
        try container.encode(rawAwayEnd, forKey: .rawAwayEnd)
        try container.encode(rawLocation, forKey: .rawLocation)
        try container.encode(rawState, forKey: .rawState)
    }
    
    var awayStart: Date? {
        guard let beginTime = rawAwayBegin else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: "\(rawDate) \(beginTime)")
    }
    
    var awayEnd: Date? {
        guard let endTime = rawAwayEnd else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: "\(rawDate) \(endTime)")
    }
    
    var isHistory: Bool {
        switch state {
        case .reserve, .checkIn, .away:
            return false
        default:
            return true
        }
    }
    
    var isFailed: Bool {
        switch state {
        case .incomplete, .miss:
            return true
        default:
            return false
        }
    }
}

extension SeatReservation: Equatable {
    public static func==(lhs: SeatReservation, rhs: SeatReservation) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SeatReservation: Comparable {
    public static func<(lhs: SeatReservation, rhs: SeatReservation) -> Bool {
        return lhs.id < rhs.id
    }
}

extension SeatReservation: SeatCurrentReservationRepresentable{
    var currentState: SeatCurrentReservationState {
        let current = Date()
        switch state {
        case .reserve:
            if current < time.start {
                let minutes = Int(ceil(time.start.timeIntervalSince(current) / 60))
                return .upcoming(in: minutes)
            }else{
                let allowTime = min(30, self.time.duration)
                let time = allowTime - Int(ceil(current.timeIntervalSince(self.time.start) / 60))
                if time > 0 {
                    return .late(remain: time)
                }else{
                    return .invalid
                }
            }
        case .checkIn:
            let usedTime = Int(ceil(current.timeIntervalSince(self.time.start) / 60))
            let left = time.duration - usedTime
            if left > 0 {
                return .ongoing(left: left)
            }else{
                return .invalid
            }
        case .away:
            return .invalid
        default:
            return .invalid
        }
    }
    
    var isStarted: Bool {
        return Date() >= time.start
    }
}

struct SeatCurrentReservation: Codable {
    
    let id: Int
    let seatId: Int
    let receipt: String
    let rawDate: String
    let rawBegin: String
    let rawEnd: String
    let rawAwayBegin: String?
    let rawAwayEnd: String?
    let rawActualBegin: String?
    let rawLocation: String
    let rawState: String
    let message: String
    
    let time: SeatReservationTime
    let location: SeatLocation?
    let state: SeatReservationState
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case seatId
        case receipt
        case rawDate = "onDate"
        case rawBegin = "begin"
        case rawEnd = "end"
        case rawAwayBegin = "awayBegin"
        case rawAwayEnd = "awayEnd"
        case rawActualBegin = "actualBegin"
        case rawLocation = "location"
        case rawState = "status"
        case message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        seatId = try container.decode(Int.self, forKey: .seatId)
        receipt = try container.decode(String.self, forKey: .receipt)
        rawDate = try container.decode(String.self, forKey: .rawDate)
        rawBegin = try container.decode(String.self, forKey: .rawBegin)
        rawEnd = try container.decode(String.self, forKey: .rawEnd)
        rawAwayBegin = try container.decode(String?.self, forKey: .rawAwayBegin)
        rawAwayEnd = try container.decode(String?.self, forKey: .rawAwayEnd)
        rawActualBegin = try container.decode(String?.self, forKey: .rawActualBegin)
        rawLocation = try container.decode(String.self, forKey: .rawLocation)
        rawState = try container.decode(String.self, forKey: .rawState)
        message = try container.decode(String.self, forKey: .message)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: rawDate)!
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let start = formatter.date(from: "\(rawDate) \(rawBegin)")!
        let end = formatter.date(from: "\(rawDate) \(rawEnd)")!
        
        time = SeatReservationTime(date: date, start: start, end: end, message: message)
        location = SeatLocation(currentLocation: rawLocation)
        state = SeatReservationState(rawValue: rawState) ?? .unknown
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(seatId, forKey: .seatId)
        try container.encode(receipt, forKey: .receipt)
        try container.encode(rawDate, forKey: .rawDate)
        try container.encode(rawBegin, forKey: .rawBegin)
        try container.encode(rawEnd, forKey: .rawEnd)
        try container.encode(rawAwayBegin, forKey: .rawAwayBegin)
        try container.encode(rawAwayEnd, forKey: .rawAwayEnd)
        try container.encode(rawActualBegin, forKey: .rawActualBegin)
        try container.encode(rawLocation, forKey: .rawLocation)
        try container.encode(rawState, forKey: .rawState)
        try container.encode(message, forKey: .message)
    }
    
    var awayStart: Date? {
        guard let beginTime = rawAwayBegin else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: "\(rawDate) \(beginTime)")
    }
    
    var awayEnd: Date? {
        guard let endTime = rawAwayEnd else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: "\(rawDate) \(endTime)")
    }
    
    var actualStart: Date? {
        guard let beginTime = rawActualBegin else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: "\(rawDate) \(beginTime)")
    }
    
    /// 暂离剩余时间
    var remainAwayTime: Int? {
        guard state == .away, let leftDate = awayStart else {
            return  nil
        }
        let current = Date()
        guard current >= leftDate else {
            return nil
        }
        let hour = Calendar.current.component(.hour, from: current)
        var availableTime = 30
        switch hour {
        case 11, 12, 17, 18:
            availableTime = 60
        default:
            break
        }
        let awayTime = Int(ceil(current.timeIntervalSince(leftDate) / 60))
        let remainTime = availableTime - awayTime
        return remainTime < 0 ? nil : remainTime
    }
    
    var currentState: SeatCurrentReservationState {
        let current = Date()
        switch state {
        case .reserve:
            if current < time.start {
                let minutes = Int(ceil(time.start.timeIntervalSince(current) / 60))
                return .upcoming(in: minutes)
            }else{
                let allowTime = min(30, self.time.duration)
                let time = allowTime - Int(ceil(current.timeIntervalSince(self.time.start) / 60))
                if time > 0 {
                    return .late(remain: time)
                }else{
                    return .invalid
                }
            }
        case .checkIn:
            let usedTime = Int(ceil(current.timeIntervalSince(time.start) / 60))
            let left = time.duration - usedTime
            if left > 0 {
                return .ongoing(left: left)
            }else{
                return .invalid
            }
        case .away:
            guard let remain = remainAwayTime else {
                return .invalid
            }
            let endTime = Int(ceil(time.end.timeIntervalSince(current) / 60))
            if endTime < 0 {
                return .invalid
            }
            
            if remain > endTime {
                return .autoEnd(in: endTime)
            }
            return .tempAway(remain: remain)
        default:
            return .invalid
        }
    }
    
    var isStarted: Bool {
        return Date() >= time.start
    }
}

extension SeatCurrentReservation: SeatCurrentReservationRepresentable {
    var seatID: Int? {
        return seatId
    }
    
    var receiptID: String? {
        return receipt
    }
}
