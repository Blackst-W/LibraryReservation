//
//  SeatHistoryManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

public class SeatHistoryManager: SeatBaseNetworkManager {
    
    public init() {
        super.init(queue: DispatchQueue(label: "com.westonwu.ios.librayrReservation.seat.history"))
    }
    
    public func fetchHistory(page: Int, callback: SeatHandler<[SeatReservation]>?) {
        guard let account = AccountManager.shared.currentAccount,
        let token = account.token
            else {
            //Require Login
            callback?(.requireLogin)
            return
        }
        
        let historyURL = URL(string: "v2/history/\(page)/10", relativeTo: SeatAPIURL)!
        
        var historyRequest = URLRequest(url: historyURL)
        historyRequest.httpMethod = "GET"
        historyRequest.allHTTPHeaderFields = CommonHeader
        historyRequest.addValue(token, forHTTPHeaderField: "token")
        let historyTask = session.dataTask(with: historyRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
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
                let historyResponse = try decoder.decode(SeatHistoryResponse.self, from: data)
                let newReservations = historyResponse.data.reservations.sorted {$0 > $1}
                DispatchQueue.main.async {
                    callback?(.success(newReservations))
                }
            } catch where error is DecodingError {
                do {
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    DispatchQueue.main.async {
                        if failedResponse.code == "12" {
                            callback?(.requireLogin)
                        }else{
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
        historyTask.resume()
    }
    
    public func checkCurrent(callback: SeatHandler<SeatCurrentReservation?>?) {
        guard let account = AccountManager.shared.currentAccount,
            let token = account.token
            else {
                callback?(.requireLogin)
                return
        }
        let reservationURL = URL(string: "v2/user/reservations", relativeTo: SeatAPIURL)!
        var reservationRequest = URLRequest(url: reservationURL)
        reservationRequest.httpMethod = "GET"
        reservationRequest.allHTTPHeaderFields = CommonHeader
        reservationRequest.addValue(token, forHTTPHeaderField: "token")
        let reservationTask = session.dataTask(with: reservationRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
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
                let reservationResponse = try decoder.decode(SeatCurrentReservationResponse.self, from: data)
                callback?(.success(reservationResponse.data.first))
            } catch where error is DecodingError {
                do {
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    if failedResponse.code == "0" {
                        DispatchQueue.main.async {
                            callback?(.success(nil))
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
        reservationTask.resume()
    }

    public func cancel(reservation: SeatReservation, callback: SeatHandler<Void>?) {
        switch reservation.currentState {
        case .late(_), .upcoming(_):
            stop(reservation: reservation, retry: true, callback: callback)
        default:
            cancel(reservation: reservation, retry: true, callback: callback)
        }
    }
    
    func stop(reservation: SeatReservation, retry: Bool, callback: SeatHandler<Void>?) {
        guard let account = AccountManager.shared.currentAccount,
            let token = account.token else {
                callback?(.requireLogin)
                return
        }
        let cancelURL = URL(string: "v2/stop", relativeTo: SeatAPIURL)!
        var cancelRequest = URLRequest(url: cancelURL)
        cancelRequest.httpMethod = "GET"
        cancelRequest.allHTTPHeaderFields = CommonHeader
        cancelRequest.addValue(token, forHTTPHeaderField: "token")
        let cancelTask = session.dataTask(with: cancelRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
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
                let cancelResponse = try decoder.decode(SeatBaseResponse.self, from: data)
                if cancelResponse.code == "0" {
                    DispatchQueue.main.async {
                        callback?(.success(()))
                    }
                }else if retry && cancelResponse.code == "1" {
                    self.cancel(reservation: reservation, retry: false, callback: callback)
                }else if cancelResponse.code == "12" {
                    callback?(.requireLogin)
                }else{
                    callback?(.failed(cancelResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    callback?(.error(error))
                }
            }
        }
        cancelTask.resume()
    }
    
    func cancel(reservation: SeatReservation, retry: Bool, callback: SeatHandler<Void>?) {
        guard let account = AccountManager.shared.currentAccount,
            let token = account.token else {
                callback?(.requireLogin)
                return
        }
        let cancelURL = URL(string: "v2/cancel/\(reservation.id)", relativeTo: SeatAPIURL)!
        var cancelRequest = URLRequest(url: cancelURL)
        cancelRequest.httpMethod = "GET"
        cancelRequest.allHTTPHeaderFields = CommonHeader
        cancelRequest.addValue(token, forHTTPHeaderField: "token")
        let cancelTask = session.dataTask(with: cancelRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
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
                let cancelResponse = try decoder.decode(SeatBaseResponse.self, from: data)
                if cancelResponse.code == "0" {
                    DispatchQueue.main.async {
                        callback?(.success(()))
                    }
                }else if retry && cancelResponse.code == "1" {
                    self.stop(reservation: reservation, retry: false, callback: callback)
                }else if cancelResponse.code == "12" {
                    callback?(.requireLogin)
                }else{
                    callback?(.failed(cancelResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    callback?(.error(error))
                }
            }
        }
        cancelTask.resume()
    }
}
