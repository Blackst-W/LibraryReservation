//
//  SeatCollectionView.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/20.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class SeatCollectionView: UIControl {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBOutlet weak var seatLabel: UILabel!
    
    @IBOutlet weak var computerImageView: UIImageView!
    @IBOutlet weak var windowImageView: UIImageView!
    @IBOutlet weak var powerImageView: UIImageView!
    @IBOutlet var contentView: UIView!
    
    var seat: Seat!
    
    func update(seat: Seat) {
        self.seat = seat
        layer.cornerRadius = 8
//        layer.shadowRadius = 8
//        layer.shadowOpacity = 0.15
//        layer.shadowOffset = CGSize(width: 0, height: 5)
        seatLabel.text = seat.name
        computerImageView.alpha = seat.hasComputer ? 1 : 0
        windowImageView.alpha = seat.hasWindow ? 1 : 0
        powerImageView.alpha = seat.hasPower ? 1 : 0
        addSubview(contentView)
        if !seat.available {
            disable()
        }else{
            reset()
        }
    }
    
    func disable() {
        isUserInteractionEnabled = false
        let configuration = ThemeConfiguration.current
        contentView.backgroundColor = configuration.seatUnavailableColor
        seatLabel.textColor = configuration.seatUnavailableTextColor
    }
    
    func reset() {
        guard seat.available else {
            disable()
            return
        }
        isUserInteractionEnabled = true
        let configuration = ThemeConfiguration.current
        if seat.availableNow {
            contentView.backgroundColor = configuration.seatAvailableNowColor
            seatLabel.textColor = configuration.seatAvailableNowTextColor
        }else{
            contentView.backgroundColor = configuration.seatAvailableColor
            seatLabel.textColor = configuration.seatAvailableTextColor
        }
    }
    
    func hightlight() {
        guard seat.available else {return}
        let configuration = ThemeConfiguration.current
        contentView.backgroundColor = configuration.seatFilterColor
        seatLabel.textColor = configuration.seatFilterTextColor
        isUserInteractionEnabled = true
    }
    
    func selected() {
        let configuration = ThemeConfiguration.current
        contentView.backgroundColor = configuration.seatHighlightColor
        seatLabel.textColor = configuration.seatHighlightTextColor
    }
    
    func viewed() {
        let configuration = ThemeConfiguration.current
        contentView.backgroundColor = configuration.seatViewedColor
        seatLabel.textColor = configuration.seatViewedTextColor
    }
    
}
