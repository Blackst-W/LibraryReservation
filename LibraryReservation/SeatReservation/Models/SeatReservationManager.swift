//
//  ReservationManager.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/05/17.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

struct SeatReservationArchive: Codable {
    let reservation: SeatReservation?
    let historys: [SeatReservation]
    let recentSeats: [DetailSeat]
    let savedSeats: [DetailSeat]
}

extension Notification.Name {
    static let ReserveSuccess = Notification.Name("ReserveSuccessNotification")
}

class SeatReservationManager: NSObject {
    var account = AccountManager.shared.currentAccount
    var reservation: SeatReservation? {
        didSet {
            NotificationManager.shared.schedule(reservation: reservation)
            WatchAppDelegate.shared.transfer(reservation: reservation)
        }
    }
    var historys: [SeatReservation] = []
    var recentSeats: [DetailSeat] = []
    var savedSeats: [DetailSeat] = []
    var manager = SeatHistoryManager()
    static let shared = SeatReservationManager()
    
    private override init() {
        super.init()
        load()
        NotificationCenter.default.addObserver(self, selector: #selector(accountLogin(notification:)), name: .AccountLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accountLogout(notification:)), name: .AccountLogout, object: nil)
    }
    
    @objc func accountLogout(notification: Notification) {
        guard let account = notification.userInfo?["OldAccount"] as? UserAccount else {
            return
        }
        delete(account: account)
    }
    
    @objc func accountLogin(notification: Notification) {
        guard let account = notification.userInfo?["NewAccount"] as? UserAccount else {
            return
        }
        self.account = account
        reservation = nil
        historys = []
        load()
    }
    
    func load() {
        load(account: account)
    }
    
    func load(account: UserAccount?) {
        guard let account = account else {
            reservation = nil
            historys = []
            return
        }
        let path = GroupURL.appendingPathComponent("SeatReservation-\(account.username).archive")
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: path),
            let archive = try? decoder.decode(SeatReservationArchive.self, from: data) else {
                reservation = nil
                historys = []
                return
        }
        reservation = archive.reservation
        historys = archive.historys
        savedSeats = archive.savedSeats
        recentSeats = archive.recentSeats
    }
    
    func save() {
        save(account: account)
    }
    
    func save(account: UserAccount?) {
        guard let account = account else {
            return
        }
        let archive = SeatReservationArchive(reservation: reservation, historys: historys, recentSeats: recentSeats, savedSeats: savedSeats)
        let encoder = JSONEncoder()
        let filePath = GroupURL.appendingPathComponent("SeatReservation-\(account.username).archive")
        let data = try! encoder.encode(archive)
        do {
            try data.write(to: filePath)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func delete() {
        delete(account: account)
    }
    
    func delete(account: UserAccount?) {
        guard let account = account else {
            return
        }
        let fileManager = FileManager.default
        let filePath = GroupURL.appendingPathComponent("SeatReservation-\(account.username).archive")
        try? fileManager.removeItem(at: filePath)
    }
    
    func add(recentSeat: DetailSeat) {
        if let index = recentSeats.index(of: recentSeat) {
            recentSeats.remove(at: index)
        }
        recentSeats.insert(recentSeat, at: 0)
        if recentSeats.count > 10 {
            recentSeats.removeLast()
        }
        save()
    }
    
    func add(savedSeat: DetailSeat) {
        if let index = savedSeats.index(of: savedSeat) {
            savedSeats.remove(at: index)
        }
        savedSeats.insert(savedSeat, at: 0)
        save()
    }
    
    func remove(recentSeatIndex: Int) {
        guard recentSeatIndex < recentSeats.count else {
            return
        }
        recentSeats.remove(at: recentSeatIndex)
        save()
    }
    
    func remove(savedSeatIndex: Int) {
        guard savedSeatIndex < savedSeats.count else {
            return
        }
        savedSeats.remove(at: savedSeatIndex)
        save()
    }
    
    func refresh(callback: SeatHandler<SeatReservation?>?) {
        manager.fetchHistory(page: 1) { (response) in
            switch response {
            case .error(let error):
                callback?(.error(error))
            case .failed(let failedResponse):
                callback?(.failed(failedResponse))
            case .requireLogin:
                callback?(.requireLogin)
            case .success(let reservations):
                self.reservation = nil
                self.historys = reservations
                for reservation in reservations {
                    if !reservation.isHistory {
                        self.reservation = reservation
                        break
                    }
                }
                self.save()
                callback?(.success(self.reservation))
            }
        }
    }
    
    func reserve(seat: Seat, room: Room, library: Library, date: Date, start: SeatTime, end: SeatTime, cols: Int, rows: Int, seats: [Seat], callback: SeatHandler<Void>?) {
        SeatReserveManager().reserve(seat: seat, date: date, start: start, end: end) { (response) in
            if case .success(_) = response {
                let location = SeatLocationData(cols: cols, rows: rows, seats: seats.map{ReducedSeat(seat: $0)})
                let recentSeat = DetailSeat(seat: seat, room: room, library: library, startTime: start, endTime: end, date: date, location: location)
                self.add(recentSeat: recentSeat)
                NotificationCenter.default.post(name: .ReserveSuccess, object: recentSeat)
            }
            callback?(response)
        }
    }
    
    func save(seat: Seat, room: Room, library: Library, date: Date, start: SeatTime, end: SeatTime, cols: Int, rows: Int, seats: [Seat]) {
        let location = SeatLocationData(cols: cols, rows: rows, seats: seats.map{ReducedSeat(seat: $0)})
        let savedSeat = DetailSeat(seat: seat, room: room, library: library, startTime: start, endTime: end, date: date, location: location)
        self.add(savedSeat: savedSeat)
    }
    
    
    func cancel(callback: SeatHandler<Void>?) {
        guard let reservation = reservation else {
            callback?(.success(()))
            return
        }
        manager.cancel(reservation: reservation) { (response) in
            switch response {
            case .error(let error):
                callback?(.error(error))
            case .failed(let failedResponse):
                callback?(.failed(failedResponse))
            case .requireLogin:
                callback?(.requireLogin)
            case .success(_):
                self.reservation = nil
                self.delete()
                callback?(.success(()))
            }
        }
    }
    
    func fetch(page: Int, callback: SeatHandler<[SeatReservation]>?) {
        manager.fetchHistory(page: page) { (response) in
            callback?(response)
            if page == 0,
                case .success(let reservations) = response {
                self.historys = reservations
                for reservation in reservations {
                    if !reservation.isHistory {
                        self.reservation = reservation
                        break
                    }
                }
            }
        }
    }
}

