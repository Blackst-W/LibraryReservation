//
//  Handler.swift
//  SeatKit
//
//  Created by Weston Wu on 2018/05/17.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

public enum SeatResponse<T> {
    case error(Error)
    case failed(SeatFailedResponse)
    case requireLogin
    case success(T)
}

public enum SeatAPIError: Int, Error {
    case dataCorrupt
    case dataMissing
    case unknown
}

public typealias SeatHandler<ResultType> = (SeatResponse<ResultType>) -> Void
