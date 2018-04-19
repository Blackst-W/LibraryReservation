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
}

struct SeatHistoryArchive: Codable {
    let sid: String
    let reservations: [SeatHistoryReservation]
}

class SeatHistoryManager: SeatBaseNetworkManager {
    
    private static let kFilePath = "SeatHistory.archive"
    
    var account: UserAccount?
    var reservations: [SeatHistoryReservation] = []
    weak var delegate: SeatHistoryManagerDelegate?
    
    init(delegate: SeatHistoryManagerDelegate?) {
        super.init(queue: DispatchQueue(label: "com.westonwu.ios.librayrReservation.seat.history"))
        self.delegate = delegate
        account = AccountManager.shared.currentAccount
        NotificationCenter.default.addObserver(self, selector: #selector(handleAccountChanged(notification:)), name: .AccountChanged, object: nil)
        load()
        delegate?.update(reservations: reservations)
    }
    
    func delete() {
        delete(filePath: SeatHistoryManager.kFilePath)
        reservations = []
        delegate?.update(reservations: [])
    }
    
    func load() {
        guard let username = account?.username else {
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
        guard let username = account?.username else {
            //Not login
            return
        }
        let encoder = JSONEncoder()
        let archive = SeatHistoryArchive(sid: username, reservations: reservations)
        let data = try! encoder.encode(archive)
        save(data: data, filePath: SeatHistoryManager.kFilePath)
    }
    
    func update() {
        guard let account = account,
        let token = account.token
            else {
            //Require Login
            delegate?.requireLogin()
            return
        }
        
        let historyURL = URL(string: "v2/history/1/10", relativeTo: SeatAPIURL)!
        
        var historyRequest = URLRequest(url: historyURL)
        historyRequest.httpMethod = "GET"
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
                self.reservations = historyResponse.data.reservations.filter {
                    return $0.isHistory && $0.state != .cancel
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
        account = AccountManager.shared.currentAccount
        if account == nil {
            delete()
        }else{
            update()
        }
    }
}

extension SeatHistoryManager: LoginViewDelegate {
    func loginResult(result: LoginResult) {
        switch result {
        case .cancel:
            return
        case .success(let account):
            self.account = account
            update()
        }
    }
}
