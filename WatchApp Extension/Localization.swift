//
//  Localization.swift
//  WatchKitApp
//
//  Created by Weston Wu on 2018/04/30.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit
import WatchSeatKit

extension String {
    init?(_ intValue: Int?) {
        guard let intValue = intValue else {return nil}
        self = String(intValue)
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    func localized(comment: String) -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    func localized(arguments: CVarArg...) -> String {
        let localizedTemplate = NSLocalizedString(self, comment: self)
        return withVaList(arguments) { (params) -> String in
            return NSString(format: localizedTemplate, arguments: params) as String
        }
    }
}

func LocalizedString(_ key: String, comment: String, arguments: CVarArg...) -> String {
    return String(format: NSLocalizedString(key, comment: comment), arguments)
}
extension SeatBaseResponse {
    var localizedDescription: String {
        guard let statusCode = statusCode else {
            return "SeatBaseResponse.unknownError".localized(arguments: code, message)
        }
        switch statusCode {
        case 0:
            return "SeatBaseResponse.success".localized
        default:
            return "SeatBaseResponse.unknownError".localized(arguments: code, message)
        }
    }
}

extension SeatAPIError {
    var localizedDescription: String {
        switch self {
        case .dataCorrupt:
            return "SeatAPIError.dataCorrupt".localized
        case .dataMissing:
            return "SeatAPIError.dataMissing".localized
        case .unknown:
            return "SeatAPIError.unknown".localized
        }
    }
}

extension SeatTime {
    var localizedValue: String {
        if id == "now" {
            return "SeatTime.now".localized
        }else{
            return value
        }
    }
}

extension SeatCurrentReservationState {
    
    var localizedKey: String {
        switch self {
        case .invalid:
            return "invalid"
        case .upcoming(_):
            return "upcoming"
        case .ongoing(_):
            return "ongoing"
        case .tempAway(_):
            return "tempAway"
        case .late(_):
            return "late"
        case .autoEnd(_):
            return "autoEnd"
        }
    }
    
    var localizedState: String {
        return "SeatCurrentReservationState.\(self.localizedKey)".localized
    }
}

extension Library {
    var localizedValue: String {
        return rawValue.localized
    }
}

extension SeatReservationState {
    
    var localizedKey: String {
        switch self {
        case .reserve:
            return "reserve"
        case .complete:
            return "complete"
        case .miss:
            return "miss"
        case .cancel:
            return "cancel"
        case .incomplete:
            return "incomplete"
        case .checkIn:
            return "checkIn"
        case .away:
            return "away"
        case .stop:
            return "stop"
        case .unknown:
            return "unknown"
        }
    }
    
    var localizedDescription: String {
        return "SeatReservationState.\(self.localizedKey)".localized
    }
}

