//
//  SeatNetworkBaseManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/17.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

enum SeatAPIError: Int, Error {
    
    case dataCorrupt
    case dataMissing
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .dataCorrupt:
            return "Data corrputed, please try again"
        case .dataMissing:
            return "Failed to receive data from server, please try again"
        case .unknown:
            return "Unknown error, please try again"
        }
    }
    
}

protocol SeatBaseDelegate: class {
    func requireLogin()
    func updateFailed(error: Error)
    func updateFailed(failedResponse: SeatFailedResponse)
}

class SeatBaseNetworkManager: NSObject {
    
    let taskQueue: DispatchQueue
    static let `default` = SeatBaseNetworkManager(queue: DispatchQueue(label: "com.westonwu.ios.libraryReservation.seat.base.default"))
    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        return URLSession(configuration: configuration)
    }()
    
    private override init() {
        fatalError("invalid seat network manager init")
    }
    
    init(queue: DispatchQueue?) {
        taskQueue = queue ?? SeatBaseNetworkManager.default.taskQueue
        super.init()
    }
    
    func login(username: String, password: String, callback: ((Error?, SeatLoginResponse?, SeatFailedResponse?)->Void)?) {
        guard let username = username.urlQueryEncoded,
            let password = password.urlQueryEncoded else {
                return
        }
        let loginQuery = "username=\(username)&password=\(password)"
        let loginURL = URL(string: "auth?\(loginQuery)", relativeTo: SeatAPIURL)!
        var loginRequest = URLRequest(url: loginURL)
        loginRequest.allHTTPHeaderFields = CommonHeader
        loginRequest.httpMethod = "GET"
        let loginTask = session.dataTask(with: loginRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    callback?(error, nil, nil)
                }
                return
            }
            
            guard let data = data else {
                print("Failed to retrive data")
                DispatchQueue.main.async {
                    callback?(SeatAPIError.dataMissing, nil, nil)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let loginResponse = try decoder.decode(SeatLoginResponse.self, from: data)
                DispatchQueue.main.async {
                    callback?(nil, loginResponse, nil)
                }
            } catch DecodingError.valueNotFound {
                do {
                    let failedResponse = try decoder.decode(SeatFailedResponse.self, from: data)
                    DispatchQueue.main.async {
                        callback?(nil, nil, failedResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        callback?(error, nil, nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    callback?(error, nil, nil)
                }
            }
        }
        loginTask.resume()
    }
    
    func delete(filePath kFilePath: String) {
            let fileManager = FileManager.default
            let rootPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
            let dirPath = rootPath + "/\(Bundle.main.bundleIdentifier!)"
            let filePath = dirPath + "/\(kFilePath)"
            try? fileManager.removeItem(atPath: filePath)
    }
    
    func load(filePath kFilePath: String) -> Data? {
        let fileManager = FileManager.default
        let rootPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let dirPath = rootPath + "/\(Bundle.main.bundleIdentifier!)"
        let filePath = dirPath + "/\(kFilePath)"
        guard fileManager.fileExists(atPath: filePath) else {
            return nil
        }
        return try? Data(contentsOf: URL(fileURLWithPath: filePath))
    }
    
    func save(data: Data, filePath kFilePath: String) {
        let fileManager = FileManager.default
        let rootPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let dirPath = rootPath + "/\(Bundle.main.bundleIdentifier!)"
        let filePath = dirPath + "/\(kFilePath)"
        if !fileManager.fileExists(atPath: dirPath) {
            do {
                try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                return
            }
        }
        do {
            try data.write(to: URL(fileURLWithPath: filePath))
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
}
