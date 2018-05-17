//
//  SeatLibraryManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/20.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

public class SeatLibraryManager: SeatBaseNetworkManager {
    
    public let libraryData = LibraryData()
    
    public init() {
        super.init(queue: DispatchQueue(label: "com.westonwu.ios.LibraryReservation.seat.library"))
    }
    
    public func check(library: Library, callback: SeatHandler<[Room]>?) {
        guard let account = AccountManager.shared.currentAccount,
            let token = account.token else {
                callback?(.requireLogin)
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
                let libraryResponse = try decoder.decode(SeatLibraryResponse.self, from: data)
                self.libraryData[library] = libraryResponse.data
                DispatchQueue.main.async {
                    callback?(.success(libraryResponse.data))
                }
            } catch DecodingError.valueNotFound {
                do {
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
        libraryTask.resume()
        
    }
    
}
