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
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 5)
        seatLabel.text = seat.name
        computerImageView.isHidden = !seat.hasComputer
        windowImageView.isHidden = !seat.hasWindow
        powerImageView.isHidden = !seat.hasPower
        addSubview(contentView)
        if !seat.available {
            disable()
        }else{
            reset()
        }
    }
    
    func disable() {
        isUserInteractionEnabled = false
        contentView.backgroundColor = .darkGray
        seatLabel.textColor = .white
    }
    
    func reset() {
        guard seat.available else {
            disable()
            return
        }
        isUserInteractionEnabled = true
        windowImageView.image = #imageLiteral(resourceName: "WindowIcon")
        if seat.availableNow {
            contentView.backgroundColor = #colorLiteral(red: 0.3882352941, green: 0.8549019608, blue: 0.2196078431, alpha: 1)
            seatLabel.textColor = .white
            computerImageView.image = #imageLiteral(resourceName: "ScreenIcon")
            powerImageView.image = #imageLiteral(resourceName: "PowerInvertIcon")
        }else{
            contentView.backgroundColor = .white
            seatLabel.textColor = .black
            computerImageView.image = #imageLiteral(resourceName: "ScreenIcon")
            powerImageView.image = #imageLiteral(resourceName: "PowerIcon")
        }
    }
    
    func hightlight() {
        guard seat.available else {return}
        isUserInteractionEnabled = true
        contentView.backgroundColor = #colorLiteral(red: 0, green: 0.5018912177, blue: 1, alpha: 1)
        seatLabel.textColor = .white
        computerImageView.image = #imageLiteral(resourceName: "ScreenInvertIcon")
        powerImageView.image = #imageLiteral(resourceName: "PowerIcon")
        windowImageView.image = #imageLiteral(resourceName: "WindowIcon")
    }
    
    func selected() {
        contentView.backgroundColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
        seatLabel.textColor = .white
        computerImageView.image = #imageLiteral(resourceName: "ScreenIcon")
        powerImageView.image = #imageLiteral(resourceName: "PowerIcon")
        windowImageView.image = #imageLiteral(resourceName: "WindowIcon")
    }
    
    func viewed() {
        contentView.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        seatLabel.textColor = .white
        computerImageView.image = #imageLiteral(resourceName: "ScreenIcon")
        powerImageView.image = #imageLiteral(resourceName: "PowerIcon")
        windowImageView.image = #imageLiteral(resourceName: "WindowInvertIcon")
    }
    
}
