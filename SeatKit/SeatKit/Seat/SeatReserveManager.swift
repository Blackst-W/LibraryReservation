//
//  SeatReserveManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/21.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

public class SeatReserveManager: SeatBaseNetworkManager {
    
    public init() {
        super.init(queue: DispatchQueue(label: "com.westonwu.ios.librayrReservation.seat.time"))
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
                }else if response.code == "12" {
                    callback?(.requireLogin)
                }else{
                    callback?(.failed(response))
                }
                    
            }catch{
                DispatchQueue.main.async {
                    callback?(.error(error))
                }
            }
        }
        reserveTask.resume()
    }
    
    public func check(seat: Seat, date: Date, callback: SeatHandler<(seat: Seat, start: [SeatTime])>?) {
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
                    callback?(.success((seat: seat, start: startTimes)))
                }
            } catch where error is DecodingError {
                do {
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    if failedResponse.code == "0" {
                        DispatchQueue.main.async {
                            callback?(.success((seat: seat, start: [])))
                        }
                    }else if failedResponse.code == "12" {
                        callback?(.requireLogin)
                    }else{
                        callback?(.failed(failedResponse))
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

    public func check(room: Room, date: Date, callback: SeatHandler<RoomLayoutData>?) {
        guard let token = AccountManager.shared.currentAccount?.token else {
            callback?(.requireLogin)
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let layoutURL = URL(string: "v2/room/layoutByDate/\(room.id)/\(dateString)", relativeTo: SeatAPIURL)!
        var layoutRequest = URLRequest(url: layoutURL)
        layoutRequest.httpMethod = "GET"
        layoutRequest.allHTTPHeaderFields = CommonHeader
        layoutRequest.addValue(token, forHTTPHeaderField: "token")
        let task = session.dataTask(with: layoutRequest) { (data, response, error) in
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
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(SeatAPIResponse<RoomLayoutData>.self, from: data)
                DispatchQueue.main.async {
                    callback?(.success(result.data))
                }
                
            } catch where error is DecodingError {
                print(error.localizedDescription)
                do {
                    let decoder = JSONDecoder()
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    if failedResponse.code == "12" {
                        callback?(.requireLogin)
                    }else{
                        callback?(.failed(failedResponse))
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
    
    public func check(library: Library, room: Room, date: Date, start: SeatTime, end: SeatTime, callback: SeatHandler<[Seat]>?) {
        guard let token = AccountManager.shared.currentAccount?.token else {
            callback?(.requireLogin)
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let searchURL = URL(string: "v2/searchSeats/\(dateString)/\(start.id)/\(end.id)", relativeTo: SeatAPIURL)!
        var searchRequest = URLRequest(url: searchURL)
        searchRequest.httpMethod = "POST"
        searchRequest.allHTTPHeaderFields = CommonHeader
        searchRequest.addValue(token, forHTTPHeaderField: "token")
        let body = "t=1&t2=2&roomId=\(room.id)&buildingId=\(library.areaID)&batch=200"
        searchRequest.httpBody = body.data(using: .utf8)
        let searchTask = session.dataTask(with: searchRequest) { (data, response, error) in
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
            let decoder = JSONDecoder()
            if let result = try? decoder.decode(SeatTimeFilterResponse.self, from: data) {
                DispatchQueue.main.async {
                    callback?(.success(result.seats))
                }
            }else{
                do {
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    if failedResponse.code == "12" {
                        callback?(.requireLogin)
                    }else{
                        callback?(.failed(failedResponse))
                    }
                } catch {
                    DispatchQueue.main.async {
                        callback?(.error(error))
                    }
                }
            }
            
        }
        searchTask.resume()
    }
    
}

