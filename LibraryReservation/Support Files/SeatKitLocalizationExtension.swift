//
//  SeatKitLocalizationExtension.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/30.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

extension SeatBaseResponse {
     var localizedDescription: String {
        guard let statusCode = statusCode else {
            return "SeatBaseResponse.unknownError".localized(arguments: code, message)
        }
        switch statusCode {
        case 0:
            return "SeatBaseResponse.success".localized
        case 10:
            return "SeatBaseResponse.maintenance".localized
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

