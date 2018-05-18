//
//  SeatNetworkBaseManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/17.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

public class SeatBaseNetworkManager: NSObject {
    
    let taskQueue: DispatchQueue
    public static let `default` = SeatBaseNetworkManager(queue: DispatchQueue(label: "com.westonwu.ios.libraryReservation.seat.base.default"))
    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        return URLSession(configuration: configuration)
    }()
    
    private override init() {
        fatalError("invalid seat network manager init")
    }
    
    public init(queue: DispatchQueue?) {
        taskQueue = queue ?? SeatBaseNetworkManager.default.taskQueue
        super.init()
    }
    
    public func login(username: String, password: String, callback: SeatHandler<SeatLoginResponse>?) {
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
                let loginResponse = try decoder.decode(SeatLoginResponse.self, from: data)
                DispatchQueue.main.async {
                    callback?(.success(loginResponse))
                }
            } catch where error is DecodingError {
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
        loginTask.resume()
    }
    
    func delete(filePath kFilePath: String) {
            let fileManager = FileManager.default
            let path = GroupURL.appendingPathComponent(kFilePath)
            try? fileManager.removeItem(atPath: path.absoluteString)
    }
    
    func load(filePath kFilePath: String) -> Data? {
        let path = GroupURL.appendingPathComponent(kFilePath)
        return try? Data(contentsOf: path)
    }
    
    func save(data: Data, filePath kFilePath: String) {
        let path = GroupURL.appendingPathComponent(kFilePath)
        do {
            try data.write(to: path)
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
}
