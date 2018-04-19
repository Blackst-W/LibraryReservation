//
//  AccountManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import Security

extension Notification.Name {
    static let AccountChanged = Notification.Name("kAccountChangedNotification")
    static let UserInfoUpdated = Notification.Name("kUserInfoUpdatedNotification")
}

class AccountManager: NSObject {
    
    class var isLogin: Bool {
        return AccountManager.shared.currentAccount != nil
    }
    
    static let shared = AccountManager()
    private(set) var currentAccount: UserAccount?
    private(set) var userInfo: UserInfo?
    static let server = "reservation.seat.lib.whu.edu.cn"
    static let kUserDefaultSID = "UserSID"
    
    private override init() {
        super.init()
        load()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePasswordSettingChanged(notification:)), name: .PasswordSettingChanged, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handlePasswordSettingChanged(notification: Notification) {
        let savePassword = notification.object as? Bool ?? Settings.shared.savePassword
        if !savePassword {
            deletePassword()
        }
    }
    
    func login(account: UserAccount) {
        currentAccount = account
        NotificationCenter.default.post(name: .AccountChanged, object: nil)
        save()
        fetchUserInfo()
    }
    
    func logout() {
        deletePassword()
        userInfo = nil
        currentAccount = nil
        NotificationCenter.default.post(name: .AccountChanged, object: nil)
        UserDefaults.standard.set(nil, forKey: AccountManager.kUserDefaultSID)
    }
    
    func deletePassword() {
        currentAccount?.password = nil
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: AccountManager.server]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            print("Failed to delete account")
            print(status)
            return
        }
    }
    
    private func load() {
        guard let savedUsername = UserDefaults.standard.value(forKey: AccountManager.kUserDefaultSID) as? String else {
            //No User Found
            print("User Not Found")
            currentAccount = nil
            return
        }
        var account = UserAccount(username: savedUsername, password: nil, token: nil)
        let settings = Settings.shared
        guard settings.savePassword else {
            currentAccount = account
            return
        }
        //check saved password from keychain
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecAttrServer as String: AccountManager.server,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            print("Failed to retrive password")
            print(status)
            currentAccount = account
            return
        }
        //success to retrive item from keychain
        guard let savedItem = item as? [String: Any],
            let passwordData = savedItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: .utf8),
            let username = savedItem[kSecAttrAccount as String] as? String
            else {
                //Failed to restore data
                print("Failed to restore password")
                currentAccount = account
                return
        }
        guard account.username == username else {
            //Wrong User
            deletePassword()
            currentAccount = account
            return
        }
        //load password success
        account.password = password
        currentAccount = account
    }
    
    static let kUserInfoFilePath = "UserInfo.archive"
    
    func loadUserInfo() {
        guard let account = currentAccount else {
            deleteUserInfo()
            return
        }
        let fileManager = FileManager.default
        let rootPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let dirPath = rootPath + "/\(Bundle.main.bundleIdentifier!)"
        let filePath = dirPath + "/\(AccountManager.kUserInfoFilePath)"
        guard fileManager.fileExists(atPath: filePath) else {
            return
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            deleteUserInfo()
            return
        }
        let decoder = JSONDecoder()
        guard let archive = try? decoder.decode(UserInfo.self, from: data) else {
            deleteUserInfo()
            return
        }
        guard archive.username == account.username else {
            deleteUserInfo()
            return
        }
        userInfo = archive
    }
    
    func deleteUserInfo() {
        let fileManager = FileManager.default
        let rootPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let dirPath = rootPath + "/\(Bundle.main.bundleIdentifier!)"
        let filePath = dirPath + "/\(AccountManager.kUserInfoFilePath)"
        try? fileManager.removeItem(atPath: filePath)
    }
    
    func saveUserInfo() {
        guard let userInfo = userInfo else {
            return
        }
        let encoder = JSONEncoder()
        let data = try! encoder.encode(userInfo)
        let fileManager = FileManager.default
        let rootPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let dirPath = rootPath + "/\(Bundle.main.bundleIdentifier!)"
        let filePath = dirPath + "/\(AccountManager.kUserInfoFilePath)"
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
    
    func save() {
        guard let account = currentAccount else {
            print("Not login")
            return
        }
        UserDefaults.standard.set(account.username, forKey: AccountManager.kUserDefaultSID)
        saveUserInfo()
        let settings = Settings.shared
        guard settings.savePassword else {
            return
        }
        guard let password = account.password else {
            print("Password can't be saved: Password not found")
            return
        }
        let username = account.username
        let passwordData = password.data(using: .utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: username,
                                    kSecAttrServer as String: AccountManager.server,
                                    kSecAttrAccessible as String: kSecAttrAccessibleAlwaysThisDeviceOnly,
                                    kSecValueData as String: passwordData]
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                              kSecAttrServer as String: AccountManager.server]
            let newData: [String: Any] = [kSecAttrAccount as String: username,
                                          kSecValueData as String: passwordData]
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, newData as CFDictionary)
            guard updateStatus == errSecSuccess else {
                print("Failed to update account")
                print(updateStatus)
                return
            }
        }else if status != errSecSuccess {
            print("Failed to save account")
            print(status)
            return
        }
    }
    
    func fetchUserInfo() {
        guard let account = currentAccount,
            let token = account.token else {
                return
        }
        let userInfoURL = URL(string: "v2/user", relativeTo: SeatAPIURL)!
        var userInfoRequest = URLRequest(url: userInfoURL)
        userInfoRequest.httpMethod = "GET"
        userInfoRequest.addValue(token, forHTTPHeaderField: "token")
        let session = SeatBaseNetworkManager.default.session
        let userInfoTask = session.dataTask(with: userInfoRequest) { (data, response, error) in
            let decoder = JSONDecoder()
            guard let data = data,
                let userInfoResponse = try? decoder.decode(UserInfoResponse.self, from: data) else {
                    return
            }
            self.userInfo = userInfoResponse.data
            NotificationCenter.default.post(name: .UserInfoUpdated, object: nil)
            self.saveUserInfo()
        }
        userInfoTask.resume()
    }
    
}


