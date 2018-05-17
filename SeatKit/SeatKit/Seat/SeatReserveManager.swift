//
//  SeatReserveManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/21.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

public class SeatReserveManager: SeatBaseNetworkManager {
    
    var startTimes: [SeatTime] = []
    var now: Date = Date()
    public init() {
        super.init(queue: DispatchQueue(label: "com.westonwu.ios.librayrReservation.seat.time"))
    }
    
    public func endTimes(`for` timeIndex: Int) -> [SeatTime] {
        if startTimes.isEmpty {
            return []
        }
        var endTimes = [SeatTime]()
        let firstIndex = timeIndex + 1
        var validNext = startTimes[timeIndex].next ?? nextForNow
        for index in firstIndex ... startTimes.count {
            if index == startTimes.count {
                endTimes.append(validNext)
                return endTimes
            }
            let next = startTimes[index]
            if next == validNext {
                endTimes.append(next)
                validNext = validNext.next!
            }else{
                endTimes.append(validNext)
                break
            }
        }
        return endTimes
    }
    
    var nextForNow: SeatTime {
        let calender = Calendar.current
        var hour = calender.component(.hour, from: now)
        var min = calender.component(.minute, from: now)
        if min < 30 {
            min = 30
        }else{
            hour += 1
            min = 0
        }
        let time = hour * 60 + min
        return SeatTime(time: time)
    }
    
    public func check(seat: Seat, date: Date, callback: SeatHandler<(seat: Seat, start: [SeatTime], end: [SeatTime])>?) {
        guard let account = AccountManager.shared.currentAccount,
            let token = account.token else {
                callback?(.requireLogin)
                return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let timeURL = URL(string: "v2/startTimesForSeat/\(seat.id)/\(dateString)", relativeTo: SeatAPIURL)!
        var timeRequest = URLRequest(url: timeURL)
        timeRequest.httpMethod = "GET"
        timeRequest.allHTTPHeaderFields = CommonHeader
        timeRequest.addValue(token, forHTTPHeaderField: "token")
        let task = session.dataTask(with: timeRequest) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    callback?(.error(error))
                }
                return
            }
            guard let data = data else {
                print("Failed to retrive data")
                DispatchQueue.main.async {
                    callback?(.error(SeatAPIError.dataMissing))
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let timeResponse = try decoder.decode(SeatStartTimeResponse.self, from: data)
                let startTimes = timeResponse.data.startTimes
                DispatchQueue.main.async {
                    self.now = Date()
                    self.startTimes = startTimes
                    let end = self.endTimes(for: 0)
                    callback?(.success((seat: seat, start: startTimes, end: end)))
                }
            } catch DecodingError.keyNotFound {
                do {
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    if failedResponse.code == "0" {
                        DispatchQueue.main.async {
                            self.startTimes = []
                            self.now = Date()
                            callback?(.success((seat: seat, start: [], end: [])))
                        }
                    }else{
                        DispatchQueue.main.async {
                            callback?(.failed(failedResponse))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        callback?(.error(error))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    callback?(.error(error))
                }
            }
        }
        task.resume()
    }
    
    public func reserve(seat: Seat, date: Date, start: SeatTime, end: SeatTime, callback: SeatHandler<Void>?) {
        guard let token = AccountManager.shared.currentAccount?.token else {
            callback?(.requireLogin)
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let reserveURL = URL(string: "v2/freeBook", relativeTo: SeatAPIURL)!
        var reserveRequest = URLRequest(url: reserveURL)
        reserveRequest.httpMethod = "POST"
        reserveRequest.allHTTPHeaderFields = CommonHeader
        reserveRequest.addValue(token, forHTTPHeaderField: "token")
        let startTime = start.id == "now" ? "-1" : start.id
        let body = "t=1&seat=\(seat.id)&date=\(dateString)&startTime=\(startTime)&endTime=\(end.id)&t2=2"
        reserveRequest.httpBody = body.data(using: .utf8)
        reserveRequest.timeoutInterval = 3
        let reserveTask = session.dataTask(with: reserveRequest) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    callback?(.error(error))
                }
                return
            }
            guard let data = data else {
                    DispatchQueue.main.async {
                        callback?(.error(SeatAPIError.dataMissing))
                    }
                    return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(SeatBaseResponse.self, from: data)
                if response.code == "0" {
                    DispatchQueue.main.async {
                        callback?(.success(()))
                    }
                }else{
                    DispatchQueue.main.async {
                        callback?(.failed(response))
                    }
                }
            }catch{
                DispatchQueue.main.async {
                    callback?(.error(error))
                }
            }
        }
        reserveTask.resume()
    }
    
}

