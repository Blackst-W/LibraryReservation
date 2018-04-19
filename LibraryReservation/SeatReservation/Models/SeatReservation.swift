//
//  SeatReservation.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

enum Library: String {
    case main = "总馆"
    case engineering = "工学分馆"
    case info = "信息科学分馆"
    case medicine = "医学分馆"
}

struct SeatLocation {
    let floor: Int
    let library: Library
    let room: String
    let seat: Int
    
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
    }
    
}

enum SeatCurrentReservationState {
    case upcoming(`in`: Int)
    case ongoing(left: Int)
    case tempAway(remain: Int)
    case late(remain: Int)
    
    var localizedState: String {
        switch self {
        case .upcoming(_):
            return "Upcoming"
        case .ongoing(_):
            return "Ongoing"
        case .tempAway(_):
            return "Temp Away"
        case .late(_):
            return "Late"
        }
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
    
    var localizedDescription: String {
        switch self {
        case .reserve:
            return "Reserve"
        case .complete:
            return "Complete"
        case .miss:
            return "Miss"
        case .cancel:
            return "Cancel"
        case .incomplete:
            return "Incomplete"
        case .checkIn:
            return "Check In"
        case .away:
            return "Away"
        case .stop:
            return "Stop"
        case .unknown:
            return "Unknown"
        }
    }
}

struct SeatHistoryReservation: Codable {
    let id: Int
    let rawDate: String
    let rawBegin: String
    let rawEnd: String
    let rawAwayBegin: String?
    let rawAwayEnd: String?
    let loc: String
    let stat: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case rawDate = "date"
        case rawBegin = "begin"
        case rawEnd = "end"
        case rawAwayBegin = "awayBegin"
        case rawAwayEnd = "awayEnd"
        case loc = "loc"
        case stat = "stat"
    }
    /*
     {
     "id": 2489620,
     "date": "2018-4-15",
     "begin": "10:14",
     "end": "12:00",
     "awayBegin": "10:19",
     "awayEnd": "10:24",
     "loc": "总馆1层A区A1-座位区097号",
     "stat": "COMPLETE"
     }
     */
    var date: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: rawDate)!
    }
    
    var begin: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        return formatter.date(from: "\(rawDate) \(rawBegin)")!
    }
    
    var end: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        return formatter.date(from: "\(rawDate) \(rawEnd)")!
    }
    
    var awayBegin: Date? {
        guard let beginTime = rawAwayBegin else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        return formatter.date(from: "\(rawDate) \(beginTime)")
    }
    
    var awayEnd: Date? {
        guard let endTime = rawAwayEnd else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        return formatter.date(from: "\(rawDate) \(endTime)")
    }
    
    var state: SeatReservationState {
        return SeatReservationState(rawValue: stat) ?? .unknown
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
    
    var location: SeatLocation? {
        return SeatLocation(location: loc)
    }
    
}

/*
 {
 "status": "success",
 "data": [
 {
 "id": 2528288,
 "receipt": "0030-288-3",
 "onDate": "2018-04-18",
 "seatId": 36611,
 "status": "CHECK_IN",
 "location": "信息科学分馆4层西区四楼西图书阅览区，座位号026",
 "begin": "15:00",
 "end": "18:00",
 "actualBegin": "15:00",
 "awayBegin": null,
 "awayEnd": null,
 "userEnded": false,
 "message": ""
 }
 ],
 "message": "",
 "code": "0"
 }
 */
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
    let loc: String
    let stat: String
    
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
        case loc = "location"
        case stat = "status"
    }
    
    var date: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: rawDate)!
    }
    
    var begin: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        return formatter.date(from: "\(rawDate) \(rawBegin)")!
    }
    
    var end: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        return formatter.date(from: "\(rawDate) \(rawEnd)")!
    }
    
    var awayBegin: Date? {
        guard let beginTime = rawAwayBegin else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        return formatter.date(from: "\(rawDate) \(beginTime)")
    }
    
    var awayEnd: Date? {
        guard let endTime = rawAwayEnd else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        return formatter.date(from: "\(rawDate) \(endTime)")
    }
    
    var actualBegin: Date? {
        guard let beginTime = rawActualBegin else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        return formatter.date(from: "\(rawDate) \(beginTime)")
    }
    
    var state: SeatReservationState {
        return SeatReservationState(rawValue: stat) ?? .unknown
    }
    
    
    /// 是否开始
    var isStarted: Bool {
        guard Date() >= begin else {
            return false
        }
        return state != .reserve
    }
    
    /// 是否暂离
    var isAway: Bool {
        return state == .away
    }
    
    /// 是否迟到
    var isLate: Bool {
        guard Date() >= begin else {
            return false
        }
        if state == .reserve {
            return true
        }else{
            return false
        }
    }
    
    
    /// 暂离离开的时间
    var awayTime: Int? {
        guard isAway, let leftDate = awayBegin else {
            return nil
        }
        let current = Date()
        guard current >= leftDate else {
            return  nil
        }
        return Int(ceil(current.timeIntervalSince(leftDate) / 60))
    }
    
    /// 距离预约结束的时间
    var remainTime: Int? {
        guard isStarted else {
            return nil
        }
        let current = Date()
        let time = Int(ceil(current.timeIntervalSince(begin) / 60))
        return time > 0 ? time : 0
    }
    
    /// 暂离剩余时间
    var remainAwayTime: Int? {
        guard isAway, let leftDate = awayBegin else {
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
        var remainTime = availableTime - awayTime
        if remainTime < 0 {
            remainTime = 0
        }
        return remainTime
    }
    
    var remainLateTime: Int? {
        guard isLate else {
            return  nil
        }
        let allowTime = 30
        let current = Date()
        let time = allowTime - Int(ceil(current.timeIntervalSince(begin) / 60))
        return time > 0 ? time : 0
    }
    
    var currentState: SeatCurrentReservationState {
        if isLate {
            return .late(remain: remainLateTime!)
        }else if !isStarted {
            let current = Date()
            let minutes = Int(ceil(begin.timeIntervalSince(current) / 60))
            return .upcoming(in: minutes)
        }else if isAway {
            let remain = remainAwayTime!
            return .tempAway(remain: remain)
        }else{
            return .ongoing(left: remainTime!)
        }
    }
    
    var location: SeatLocation? {
        return SeatLocation(currentLocation: loc)
    }
}

