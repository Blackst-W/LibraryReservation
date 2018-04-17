//
//  AccountManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class LoginManager {
    
    let session: URLSession
    
    let shared = LoginManager()
    
    private init() {
        session = URLSession.shared
    }
    
    func login(username: String, password: String) {
        guard let username = username.urlQueryEncoded,
            let password = password.urlQueryEncoded else {
                return
        }
        let loginQuery = "username=\(username)&password=\(password)"
        let loginURL = URL(string: "auth?\(loginQuery)", relativeTo: SeatAPIURL)!
        var loginRequest = URLRequest(url: loginURL)
        loginRequest.httpMethod = "GET"
        let loginTask = session.dataTask(with: loginRequest) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                    print("Failed to retrive data")
                    return
            }
            
            let decoder = JSONDecoder()
            do {
                let loginResponse = try decoder.decode(LoginResponse.self, from: data)
                print(loginResponse)
            } catch DecodingError.valueNotFound {
                do {
                    let failedResponse = try decoder.decode(BaseResponse.self, from: data)
                    print(failedResponse)
                } catch {
                    print(error)
                }
            } catch {
                print(error)
            }
        }
        loginTask.resume()
    }
    
}
