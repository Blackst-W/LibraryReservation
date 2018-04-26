//
//  SeatReservationManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/20.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

typealias SeatLibraryResponse = SeatAPIArrayResponse<Room>

protocol SeatLibraryDelegate: SeatBaseDelegate {
    func update(rooms: [Room], `for` library: Library)
}

class SeatLibraryManager: SeatBaseNetworkManager {
    
    let libraryData = LibraryData()
    weak var delegate: SeatLibraryDelegate?
    
    init(delegate: SeatLibraryDelegate?) {
        self.delegate = delegate
        super.init(queue: DispatchQueue(label: "com.westonwu.ios.LibraryReservation.seat.library"))
    }
    
    func check(library: Library) {
        guard let account = AccountManager.shared.currentAccount,
            let token = account.token else {
                delegate?.requireLogin()
                return
        }
        let libraryURL = URL(string: "v2/room/stats2/\(library.areaID)", relativeTo: SeatAPIURL)!
        var libraryRequest = URLRequest(url: libraryURL)
        libraryRequest.httpMethod = "GET"
        libraryRequest.allHTTPHeaderFields = CommonHeader
        libraryRequest.setValue(token, forHTTPHeaderField: "token")
        let libraryTask = session.dataTask(with: libraryRequest) { (data, response, error) in
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
                let libraryResponse = try decoder.decode(SeatLibraryResponse.self, from: data)
                self.libraryData[library] = libraryResponse.data
                DispatchQueue.main.async {
                    self.delegate?.update(rooms: libraryResponse.data, for: library)
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
        libraryTask.resume()
        
    }
    
}
