//
//  SeatHistoryManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

protocol SeatHistoryManagerDelegate: SeatBaseDelegate {
    func update(reservations: [SeatHistoryReservation])
    func loadMore()
}

struct SeatHistoryArchive: Codable {
    let sid: String
    let reservations: [SeatHistoryReservation]
}

class SeatHistoryManager: SeatBaseNetworkManager {
    
    private static let kFilePath = "SeatHistory.archive"
    var reservations: [SeatHistoryReservation] = []
    var validReservations: [SeatHistoryReservation] {
        return reservations.filter{ return $0.isHistory}
    }
    weak var delegate: SeatHistoryManagerDelegate?
    private var pageCount = 1
    private(set) var end = false
    
    init(delegate: SeatHistoryManagerDelegate?) {
        super.init(queue: DispatchQueue(label: "com.westonwu.ios.librayrReservation.seat.history"))
        self.delegate = delegate
        NotificationCenter.default.addObserver(self, selector: #selector(handleAccountChanged(notification:)), name: .AccountChanged, object: nil)
        load()
    }
    
    
    func delete() {
        delete(filePath: SeatHistoryManager.kFilePath)
        reservations = []
        delegate?.update(reservations: [])
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
        guard let archive = try? decoder.decode(SeatHistoryArchive.self, from: data) else {
            print("Failed to load archive from archive data")
            delete()
            return
        }
        guard archive.sid == username else {
            delete()
            return
        }
        reservations = archive.reservations
    }
    
    func save() {
        guard let username = AccountManager.shared.currentAccount?.username else {
            //Not login
            return
        }
        let encoder = JSONEncoder()
        let archive = SeatHistoryArchive(sid: username, reservations: reservations)
        let data = try! encoder.encode(archive)
        save(data: data, filePath: SeatHistoryManager.kFilePath)
    }
    
    func loadMore() -> Bool {
        if end {
            return false
        }
        pageCount += 1
        update(page: pageCount)
        return true
    }
    
    func update(page: Int = 1) {
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
                if page == 1 {
                    self.end = false
                    self.reservations = historyResponse.data.reservations
                }else{
                    self.reservations.append(contentsOf: historyResponse.data.reservations)
                }
                if historyResponse.data.reservations.count < 10 {
                    self.end = true
                }
                self.save()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleAccountChanged(notification: Notification) {
        if AccountManager.isLogin {
            update()
        }else{
            delete()
        }
    }
}

extension SeatHistoryManager: LoginViewDelegate {
    func loginResult(result: LoginResult) {
        switch result {
        case .cancel:
            return
        case .success(_):
            update()
        }
    }
}
