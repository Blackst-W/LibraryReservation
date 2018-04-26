//
//  SeatRoomTableViewCell.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/20.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class SeatRoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftShadowView: UIView!
    @IBOutlet weak var leftRoomView: UIControl!
    @IBOutlet weak var leftRoomLabel: UILabel!
    @IBOutlet weak var leftAvailableLabel: UILabel!
    @IBOutlet weak var leftFloorLabel: UILabel!
    
    @IBOutlet weak var rightShadowView: UIView!
    @IBOutlet weak var rightRoomView: UIControl!
    @IBOutlet weak var rightRoomLabel: UILabel!
    @IBOutlet weak var rightAvailableLabel: UILabel!
    @IBOutlet weak var rightFloorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func update(left: Room, right: Room?) {
        leftRoomLabel.text = left.name
        leftFloorLabel.text = "Floor".localized(arguments: left.floor)
        if let leftSeat = left.availableSeat {
            leftAvailableLabel.text = "Available: %d".localized(arguments: leftSeat)
        }else{
            leftAvailableLabel.text = "Available: -".localized
        }
        if let right = right {
            rightRoomView.isUserInteractionEnabled = true
            rightShadowView.layer.shadowOpacity = 0.15
            rightRoomLabel.text = right.name
            rightFloorLabel.text = "Floor".localized(arguments: right.floor)
            if let rightSeat = right.availableSeat {
                rightAvailableLabel.text = "Available: %d".localized(arguments: rightSeat)
            }else{
                rightAvailableLabel.text = "Available: -".localized
            }
            rightRoomView.backgroundColor = .white
        }else{
            rightRoomView.isUserInteractionEnabled = false
            rightShadowView.layer.shadowOpacity = 0
            rightAvailableLabel.text = ""
            rightRoomLabel.text = ""
            rightFloorLabel.text = ""
            rightRoomView.backgroundColor = .clear
        }
    }
}
