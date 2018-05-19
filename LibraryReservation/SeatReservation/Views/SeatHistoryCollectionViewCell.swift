//
//  SeatHistoryCollectionViewCell.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class SeatHistoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var libraryNameLabel: UILabel!
    
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var areaNameLabel: UILabel!
    @IBOutlet weak var seatLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet var labels: [UILabel]!
    
    func update(reservation: SeatReservation) {
        updateTheme(false)
        dateLabel.text = reservation.rawDate
        timeLabel.text = "\(reservation.rawBegin) - \(reservation.rawEnd)"
        guard let location = reservation.location else {
            return
        }
        libraryNameLabel.text = location.library.rawValue
        floorLabel.text = "Floor".localized(arguments: location.floor)
        areaNameLabel.text = location.room
        seatLabel.text = "SeatNo".localized(arguments: String(location.seat))
        stateLabel.text = reservation.state.localizedDescription
        stateImageView.isHidden = !reservation.isFailed
    }
    
    func updateTheme(_ animated: Bool) {
        let configuration = ThemeConfiguration.current
        let animation = {
            self.contentView.backgroundColor = configuration.secondaryBackgroundColor
            self.contentView.layer.cornerRadius = 14
            self.labels.forEach { (label) in
                label.textColor = configuration.textColor
            }
            self.layer.shadowColor = configuration.shadowColor.cgColor
        }
        if animated {
            UIViewPropertyAnimator(duration: 1, curve: .linear, animations: animation).startAnimation()
        }else{
            animation()
        }
    }
    
}
