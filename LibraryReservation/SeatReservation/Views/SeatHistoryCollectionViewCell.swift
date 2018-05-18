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
    
    func updateTheme() {
        let theme = ThemeSettings.shared.theme
        var backgroundColor: UIColor!
        var labelColor: UIColor!
        var shadowColor: UIColor!
        switch theme {
        case .black:
            labelColor = .white
            shadowColor = .white
            backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
        case .standard:
            labelColor = .black
            shadowColor = .black
            backgroundColor = .white
        }
        UIViewPropertyAnimator(duration: 1, curve: .linear) {
            self.contentView.backgroundColor = backgroundColor
            self.labels.forEach { (label) in
                label.textColor = labelColor
            }
            self.layer.shadowColor = shadowColor.cgColor
        }.startAnimation()
    }
    
    func update(reservation: SeatReservation) {
        updateTheme()
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
    
}
