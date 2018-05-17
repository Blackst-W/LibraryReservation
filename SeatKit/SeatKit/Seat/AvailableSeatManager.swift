//
//  AvailableSeatManager
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/20.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

public struct RoomLayoutData: Codable {
    public let roomID: Int
    public let roomName: String
    public let cols: Int
    public let rows: Int
    public let seats: [Seat]
    
    enum CodingKeys: String, CodingKey {
        case roomID = "id"
        case roomName = "name"
        case cols
        case rows
        case layout
        case seats
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        roomID = try container.decode(Int.self, forKey: .roomID)
        roomName = try container.decode(String.self, forKey: .roomName)
        cols = try container.decode(Int.self, forKey: .cols)
        rows = try container.decode(Int.self, forKey: .rows)
        if let seats = try container.decodeIfPresent([Seat].self, forKey: .seats) {
            self.seats = seats
            return
        }
        let seatsData = try container.decode(Data.self, forKey: .layout)
        guard let seatsDict = try JSONSerialization.jsonObject(with: seatsData, options: []) as? [String: Any] else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.layout, in: container, debugDescription: "Failed to phrase seats data")
        }
        var seats = [Seat]()
        for (key, value) in seatsDict {
            guard let value = value as? [String: Any],
                let seat = Seat(layoutKey: key, values: value) else {
                continue
            }
            seats.append(seat)
        }
        self.seats = seats
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(roomID, forKey: .roomID)
        try container.encode(roomName, forKey: .roomName)
        try container.encode(cols, forKey: .cols)
        try container.encode(rows, forKey: .rows)
        try container.encode(seats, forKey: .seats)
    }
    
}

public class AvailableSeatManager: SeatBaseNetworkManager {
    
    public init() {
        super.init(queue: DispatchQueue(label: "com.westonwu.ios.librayrReservation.seat.layout"))
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
                    
                    DispatchQueue.main.async {
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
            if let result = try? decoder.decode(SeatAPIResponse<RoomLayoutData>.self, from: data) {
                DispatchQueue.main.async {
                    callback?(.success(result.data.seats))
                }
            }else{
                do {
                    let decoder = JSONDecoder()
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    
                    DispatchQueue.main.async {
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
