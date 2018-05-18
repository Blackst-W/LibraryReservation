//
//  AccountManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import Security

public extension Notification.Name {
    static let AccountLogin = Notification.Name("kAccountLoginNotification")
    static let AccountLogout = Notification.Name("kAccountLoutoutNotification")
    static let UserInfoUpdated = Notification.Name("kUserInfoUpdatedNotification")
}

public class AccountManager: NSObject {
    
    public class var isLogin: Bool {
        return AccountManager.shared.currentAccount != nil
    }
    
    public static let shared = AccountManager()
    private(set) public var currentAccount: UserAccount?
    private(set) public var userInfo: UserInfo?
    private static let server = "reservation.seat.lib.whu.edu.cn"
    static let kAccountFilePath = "Account.archive"
    
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
    
    public func login(account: UserAccount) {
        if let _ = currentAccount {
            logout()
        }
        currentAccount = account
        save()
        NotificationCenter.default.post(name: .AccountLogin, object: nil, userInfo: ["NewAccount": account])
        
        fetchUserInfo()
    }
    
    public func logout() {
        guard let account = currentAccount else {
            return
        }
        NotificationCenter.default.post(name: .AccountLogout, object: nil, userInfo: ["OldAccount": account])
        deletePassword()
        userInfo = nil
        currentAccount = nil
        deleteAccount()
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
    
    public func reload() {
        load()
    }
    
    private func load() {
        loadAccount()
        guard var account = currentAccount else {
            return
        }
        loadUserInfo()
        let settings = Settings.shared
        guard settings.savePassword else {
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
                return
        }
        guard account.username == username else {
            //Wrong User
            deletePassword()
            return
        }
        //load password success
        account.password = password
        currentAccount = account
    }
    
    func saveAccount() {
        guard var account = currentAccount else {
            print("Not login")
            deleteAccount()
            return
        }
        account.password = nil
        let encoder = JSONEncoder()
        let data = try! encoder.encode(account)
        let path = GroupURL.appendingPathComponent(AccountManager.kAccountFilePath)
        do {
            try data.write(to: path)
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    func loadAccount() {
        let path = GroupURL.appendingPathComponent(AccountManager.kAccountFilePath)
        guard let data = try? Data(contentsOf: path) else {
            deleteAccount()
            return
        }
        let decoder = JSONDecoder()
        guard let archive = try? decoder.decode(UserAccount.self, from: data) else {
            deleteAccount()
            return
        }
        currentAccount = archive
    }
    
    func deleteAccount() {
        let fileManager = FileManager.default
        let path = GroupURL.appendingPathComponent(AccountManager.kAccountFilePath)
        try? fileManager.removeItem(atPath: path.absoluteString)
    }
    
    static let kUserInfoFilePath = "UserInfo.archive"
    
    func loadUserInfo() {
        guard let account = currentAccount else {
            deleteUserInfo()
            return
        }
        let path = GroupURL.appendingPathComponent(AccountManager.kUserInfoFilePath)
        guard let data = try? Data(contentsOf: path) else {
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
        let path = GroupURL.appendingPathComponent(AccountManager.kUserInfoFilePath)
        try? fileManager.removeItem(atPath: path.absoluteString)
    }
    
    func saveUserInfo() {
        guard let userInfo = userInfo else {
            return
        }
        let encoder = JSONEncoder()
        let data = try! encoder.encode(userInfo)
        let path = GroupURL.appendingPathComponent(AccountManager.kUserInfoFilePath)
        do {
            try data.write(to: path)
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    func save() {
        saveAccount()
        guard let account = currentAccount else {
            return
        }
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
        userInfoRequest.allHTTPHeaderFields = CommonHeader
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


