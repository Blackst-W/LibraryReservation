//
//  SeatHistoryTableViewCell.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/19.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class SeatHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var containerView: UIView!
    
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
        let configuration = ThemeConfiguration.current
        labels.forEach { (label) in
            label.textColor = configuration.textColor
        }
        containerView.backgroundColor = configuration.secondaryBackgroundColor
        shadowView.layer.shadowColor = configuration.shadowColor.cgColor
        
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
