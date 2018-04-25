//
//  SeatHistoryManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let SeatReservationCancel = Notification.Name("kSeatReservationCancelNotification")
}

protocol SeatHistoryManagerDelegate: SeatBaseDelegate {
    func update(reservations: [SeatReservation])
    func update(current: SeatCurrentReservationRepresentable?)
}

struct SeatReservationArchive: Codable {
    let sid: String
    let reservations: [SeatReservation]
    let current: SeatCurrentReservation?
}

class SeatHistoryManager: SeatBaseNetworkManager {
    
    private static let kFilePath = "SeatReservation.archive"
    var reservations: [SeatReservation] = [] {
        didSet {
            history = reservations.filter{$0.isHistory}
        }
    }
    var history: [SeatReservation] = []
    var current: SeatCurrentReservationRepresentable? {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.update(current: self.current)
            }
        }
    }
    weak var delegate: SeatHistoryManagerDelegate?
    private var pageCount = 0
    private(set) var end = false
    private var loadingHistory = false
    var timer: Timer?
    
    init(delegate: SeatHistoryManagerDelegate?) {
        super.init(queue: DispatchQueue(label: "com.westonwu.ios.librayrReservation.seat.history"))
        self.delegate = delegate
        NotificationCenter.default.addObserver(self, selector: #selector(handleAccountChanged(notification:)), name: .AccountChanged, object: nil)
        load()
        startTimer()
    }
    
    
    func delete() {
        delete(filePath: SeatHistoryManager.kFilePath)
        reservations = []
        current = nil
        delegate?.update(reservations: [])
    }
    
    func startTimer() {
        invalidateTimer()
        let current = Date()
        let second = 60 - Calendar.current.component(.second, from: current)
        let nextMinute = current.addingTimeInterval(TimeInterval(second))
        timer = Timer(fireAt: nextMinute, interval: 60, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func updateTime() {
        guard let current = current else {
            return
        }
        delegate?.update(current: current)
    }
    
    func load() {
        guard let username = AccountManager.shared.currentAccount?.username else {
            delete()
            return
        }
        guard let data = load(filePath: SeatHistoryManager.kFilePath) else {
            print("Failed to load data from seat history file")
            delete()
            return
        }
        let decoder = JSONDecoder()
        guard let archive = try? decoder.decode(SeatReservationArchive.self, from: data) else {
            print("Failed to load archive from archive data")
            delete()
            return
        }
        guard archive.sid == username else {
            delete()
            return
        }
        reservations = archive.reservations
        current = archive.current ?? reservations.filter{!$0.isHistory}.first
    }
    
    func save() {
        guard let username = AccountManager.shared.currentAccount?.username else {
            //Not login
            return
        }
        let encoder = JSONEncoder()
        let currentReservation = current as? SeatCurrentReservation
        let archive = SeatReservationArchive(sid: username, reservations: reservations, current: currentReservation)
        let data = try! encoder.encode(archive)
        save(data: data, filePath: SeatHistoryManager.kFilePath)
    }
    
    func reload() {
        loadingHistory = true
        pageCount = 1
        fetchHistory(page: 1)
    }
    
    func loadMore() -> Bool {
        if end {
            return false
        }
        if loadingHistory {return true}
        loadingHistory = true
        pageCount += 1
        fetchHistory(page: pageCount)
        return true
    }
    
    private func fetchHistory(page: Int) {
        guard let account = AccountManager.shared.currentAccount,
        let token = account.token
            else {
            //Require Login
            delegate?.requireLogin()
            return
        }
        
        let historyURL = URL(string: "v2/history/\(page)/10", relativeTo: SeatAPIURL)!
        
        var historyRequest = URLRequest(url: historyURL)
        historyRequest.httpMethod = "GET"
        historyRequest.allHTTPHeaderFields? = CommonHeader
        historyRequest.addValue(token, forHTTPHeaderField: "token")
        let historyTask = session.dataTask(with: historyRequest) { data, response, error in
            self.loadingHistory = false
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.delegate?.updateFailed(error: error)
                }
                return
            }
            
            guard let data = data else {
                print("Failed to retrive data")
                DispatchQueue.main.async {
                    self.delegate?.updateFailed(error: SeatAPIError.dataMissing)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let historyResponse = try decoder.decode(SeatHistoryResponse.self, from: data)
                let newReservations = historyResponse.data.reservations
                if page == 1 {
                    self.end = false
                    self.reservations = newReservations
                }else{
                    let uniqueNewReservations = newReservations.filter{ (reservation) in
                        !self.reservations.contains {$0 == reservation}
                    }
                    self.reservations.append(contentsOf: uniqueNewReservations)
                }
                if historyResponse.data.reservations.count < 10 {
                    self.end = true
                }
                self.save()
                if let newReservation = self.reservations.filter({!$0.isHistory}).first {
                    if self.current == nil {
                        self.current = newReservation
                        self.checkCurrent()
                    }
                }else{
                    self.current = nil
                }
                DispatchQueue.main.async {
                    self.delegate?.update(reservations: self.reservations)
                }
            } catch DecodingError.keyNotFound {
                do {
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.delegate?.updateFailed(failedResponse: failedResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.updateFailed(error: error)
                    }
                }
            } catch DecodingError.valueNotFound {
                do {
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.delegate?.updateFailed(failedResponse: failedResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.updateFailed(error: error)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.updateFailed(error: error)
                }
            }
        }
        historyTask.resume()
    }
    
    func checkCurrent() {
        guard let account = AccountManager.shared.currentAccount,
            let token = account.token
            else {
                delegate?.requireLogin()
                return
        }
        let reservationURL = URL(string: "v2/user/reservations", relativeTo: SeatAPIURL)!
        var reservationRequest = URLRequest(url: reservationURL)
        reservationRequest.httpMethod = "GET"
        reservationRequest.allHTTPHeaderFields? = CommonHeader
        reservationRequest.addValue(token, forHTTPHeaderField: "token")
        let reservationTask = session.dataTask(with: reservationRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.delegate?.updateFailed(error: error)
                }
                return
            }
            guard let data = data else {
                print("Failed to retrive data")
                DispatchQueue.main.async {
                    self.delegate?.updateFailed(error: SeatAPIError.dataMissing)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let reservationResponse = try decoder.decode(SeatCurrentReservationResponse.self, from: data)
                self.current = reservationResponse.data.first!
                self.save()
            } catch DecodingError.keyNotFound {
                do {
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    if failedResponse.code == "0" {
                        DispatchQueue.main.async {
                            self.delegate?.update(current: self.current)
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.delegate?.updateFailed(failedResponse: failedResponse)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.updateFailed(error: error)
                    }
                }
            } catch DecodingError.valueNotFound {
                do {
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    if failedResponse.code == "0" {
                        DispatchQueue.main.async {
                            self.delegate?.update(current: self.current)
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.delegate?.updateFailed(failedResponse: failedResponse)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.updateFailed(error: error)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.updateFailed(error: error)
                }
            }
        }
        reservationTask.resume()
    }
    
    func cancelReservation() {
        guard let account = AccountManager.shared.currentAccount,
            let token = account.token else {
                delegate?.requireLogin()
                return
        }
        guard let reservationID = current?.id else {
            delegate?.update(current: nil)
            return
        }
        let cancelURL = URL(string: "v2/cancel/\(reservationID)", relativeTo: SeatAPIURL)!
        var cancelRequest = URLRequest(url: cancelURL)
        cancelRequest.httpMethod = "GET"
        cancelRequest.allHTTPHeaderFields? = CommonHeader
        cancelRequest.addValue(token, forHTTPHeaderField: "token")
        let cancelTask = session.dataTask(with: cancelRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.delegate?.updateFailed(error: error)
                }
                return
            }
            
            guard let data = data else {
                print("Failed to retrive data")
                DispatchQueue.main.async {
                    self.delegate?.updateFailed(error: SeatAPIError.dataMissing)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let cancelResponse = try decoder.decode(SeatBaseResponse.self, from: data)
                if cancelResponse.code == "0" {
                    DispatchQueue.main.async {
                        self.current = nil
                        NotificationCenter.default.post(name: .SeatReservationCancel, object: nil)
                    }
                }else{
                    DispatchQueue.main.async {
                        self.delegate?.updateFailed(failedResponse: cancelResponse)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.updateFailed(error: error)
                }
            }
        }
        cancelTask.resume()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleAccountChanged(notification: Notification) {
        if AccountManager.isLogin {
            pageCount = 0
            reload()
        }else{
            delete()
        }
    }
}
