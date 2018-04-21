//
//  AvailableSeatManager
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/20.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import SwiftyJSON

struct SeatLayoutData {
    let cols: Int
    let rows: Int
    let seats: [Seat]
}

protocol AvailableSeatDelegate: SeatBaseDelegate {
    func update(layoutData: SeatLayoutData)
    func timeFilterUpdate(seats: [Seat])
}

class AvailableSeatManager: SeatBaseNetworkManager {
    weak var delegate: AvailableSeatDelegate?
    init(delegate: AvailableSeatDelegate?) {
        self.delegate = delegate
        super.init(queue: DispatchQueue(label: "com.westonwu.ios.librayrReservation.seat.layout"))
    }
    
    func check(room: Room, date: Date) {
        guard let token = AccountManager.shared.currentAccount?.token else {
            delegate?.requireLogin()
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let layoutURL = URL(string: "v2/room/layoutByDate/\(room.id)/\(dateString)", relativeTo: SeatAPIURL)!
        var layoutRequest = URLRequest(url: layoutURL)
        layoutRequest.httpMethod = "GET"
        layoutRequest.addValue(token, forHTTPHeaderField: "token")
        let task = session.dataTask(with: layoutRequest) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.updateFailed(error: error)
                }
                return
            }
            
            guard let data = data,
                let json = try? JSON(data: data) else {
                DispatchQueue.main.async {
                    self.delegate?.updateFailed(error: SeatAPIError.dataMissing)
                }
                return
            }
            
            if let result = json["data"].dictionary {
                guard let cols = result["cols"]?.int,
                    let rows = result["rows"]?.int,
                    let layoutData = result["layout"]?.dictionary else {
                    DispatchQueue.main.async {
                        self.delegate?.updateFailed(error: SeatAPIError.dataCorrupt)
                    }
                    return
                }
                let validSeat = layoutData.compactMap{ (key, content) -> Seat? in
                    guard let roomData = content.dictionary else {
                        return nil
                    }
                    return Seat(layoutKey: key, json: roomData)
                }
                DispatchQueue.main.async {
                    let layoutData = SeatLayoutData(cols: cols, rows: rows, seats: validSeat)
                    self.delegate?.update(layoutData: layoutData)
                }
            }else{
                do {
                    let decoder = JSONDecoder()
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.delegate?.updateFailed(failedResponse: failedResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.updateFailed(error: error)
                    }
                }
            }
        }
        task.resume()
    }
    
    func check(library: Library, room: Room, date: Date, start: Date, end: Date) {
        guard let token = AccountManager.shared.currentAccount?.token else {
            delegate?.requireLogin()
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let calender = Calendar.current
        let startHour = calender.component(.hour, from: start)
        let startMin = calender.component(.minute, from: start)
        let endHour = calender.component(.hour, from: end)
        let endMin = calender.component(.minute, from: end)
        let searchURL = URL(string: "v2/searchSeats/\(dateString)/\(startHour*60+startMin)/\(endHour*60+endMin)", relativeTo: SeatAPIURL)!
        var searchRequest = URLRequest(url: searchURL)
        searchRequest.httpMethod = "POST"
        searchRequest.addValue(token, forHTTPHeaderField: "token")
        let body = "t=1&t2=2&roomId=\(room.id)&buildingId=\(library.areaID)&batch=200"
        searchRequest.httpBody = body.data(using: .utf8)
        let searchTask = session.dataTask(with: searchRequest) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.updateFailed(error: error)
                }
                return
            }
            guard let data = data,
                let json = try? JSON(data: data) else {
                    DispatchQueue.main.async {
                        self.delegate?.updateFailed(error: SeatAPIError.dataMissing)
                    }
                    return
            }
            if let result = json["data"].dictionary {
                guard let seatsData = result["seats"]?.dictionary else {
                        DispatchQueue.main.async {
                            self.delegate?.updateFailed(error: SeatAPIError.dataCorrupt)
                        }
                        return
                }
                let validSeats = seatsData.compactMap{ (key, content) -> Seat? in
                    guard let roomData = content.dictionary else {
                        return nil
                    }
                    return Seat(layoutKey: key, json: roomData)
                }
                DispatchQueue.main.async {
                    self.delegate?.timeFilterUpdate(seats: validSeats)
                }
            }else{
                do {
                    let decoder = JSONDecoder()
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.delegate?.updateFailed(failedResponse: failedResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.updateFailed(error: error)
                    }
                }
            }

        }
        searchTask.resume()
    }
    
}
