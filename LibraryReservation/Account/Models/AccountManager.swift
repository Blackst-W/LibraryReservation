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
}

class AccountManager: NSObject {
    
    static let shared = AccountManager()
    private(set) var currentAccount: UserAccount? {
        didSet {
            NotificationCenter.default.post(name: .AccountChanged, object: nil)
        }
    }
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
        save()
    }
    
    func logout() {
        deletePassword()
        currentAccount = nil
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
    
    func update(token: String) {
        currentAccount?.token = token
    }
    
    private func load() {
        guard let username = UserDefaults.standard.value(forKey: AccountManager.kUserDefaultSID) as? String else {
            //No User Found
            print("User Not Found")
            currentAccount = nil
            return
        }
        var account = UserAccount(username: username, password: nil, token: nil)
        let settings = Settings.shared
        if settings.savePassword {
            //check saved password from keychain
            let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                        kSecMatchLimit as String: kSecMatchLimitOne,
                                        kSecAttrServer as String: AccountManager.server,
                                        kSecReturnAttributes as String: true,
                                        kSecReturnData as String: true]
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            if status == errSecItemNotFound {
                //password not saved
                print("Password Not Found")
                currentAccount = account
                return
            }else if status != errSecSuccess {
                //failed to retrive item from keychain
                print("Failed to retrive password")
                print(status)
                currentAccount = account
                return
            }else{
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
        }
    }
    
    func save() {
        guard let account = currentAccount else {
            print("Not login")
            return
        }
        UserDefaults.standard.set(account.username, forKey: AccountManager.kUserDefaultSID)
        let settings = Settings.shared
        if settings.savePassword {
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
    }
    
    
}
