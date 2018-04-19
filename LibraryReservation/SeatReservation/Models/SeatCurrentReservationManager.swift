//
//  SeatCurrentReservationManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

protocol SeatCurrentReservationManagerDelegate: SeatBaseDelegate {
    func update(reservation: SeatCurrentReservation?)
}

struct SeatCurrentReservationArchive: Codable {
    let sid: String
    let reservation: SeatCurrentReservation
}

class SeatCurrentReservationManager: SeatBaseNetworkManager {
    private static let kFilePath = "CurrentReservation.archive"
    
    var account: UserAccount?
    var reservation: SeatCurrentReservation?
    weak var delegate: SeatCurrentReservationManagerDelegate?
    
    init(delegate: SeatCurrentReservationManagerDelegate?) {
        super.init(queue: DispatchQueue(label: "com.westonwu.ios.libraryReservation.seat.current"))
        self.delegate = delegate
        account = AccountManager.shared.currentAccount
        NotificationCenter.default.addObserver(self, selector: #selector(handleAccountChanged(notification:)), name: .AccountChanged, object: nil)
        load()
    }
    
    func delete() {
        delete(filePath: SeatCurrentReservationManager.kFilePath)
        reservation = nil
        delegate?.update(reservation: nil)
    }
    
    func load() {
        guard let username = account?.username else {
            delete()
            return
        }
        guard let data = load(filePath: SeatCurrentReservationManager.kFilePath) else {
            print("Failed to load data from seat reservation file")
            delete()
            return
        }
        let decoder = JSONDecoder()
        guard let archive = try? decoder.decode(SeatCurrentReservationArchive.self, from: data) else {
            print("Failed to load reservation from archive data")
            delete()
            return
        }
        guard archive.sid == username else {
            delete()
            return
        }
        if check(reservation: archive.reservation) {
            reservation = archive.reservation
        }else{
            delete()
        }
    }
    
    func check(reservation: SeatCurrentReservation) -> Bool {
        return true
    }
    
    func save() {
        guard let username = account?.username,
            let reservation = reservation
        else {
            //Not login or Not resercation
            return
        }
        let encoder = JSONEncoder()
        let archive = SeatCurrentReservationArchive(sid: username, reservation: reservation)
        let data = try! encoder.encode(archive)
        save(data: data, filePath: SeatCurrentReservationManager.kFilePath)
        
    }
    
    func update() {
        guard let account = account,
            let token = account.token
        else {
            delegate?.requireLogin()
            return
        }
        let reservationURL = URL(string: "v2/user/reservations", relativeTo: SeatAPIURL)!
        var reservationRequest = URLRequest(url: reservationURL)
        reservationRequest.httpMethod = "GET"
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
                self.reservation = reservationResponse.data.first!
                self.save()
                DispatchQueue.main.async {
                    self.delegate?.update(reservation: self.reservation)
                }
            } catch DecodingError.keyNotFound {
                do {
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    if failedResponse.code == "0" {
                        DispatchQueue.main.async {
                            self.reservation = nil
                            self.delegate?.update(reservation: nil)
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
                            self.reservation = nil
                            self.delegate?.update(reservation: nil)
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

extension SeatCurrentReservationManager: LoginViewDelegate {
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
