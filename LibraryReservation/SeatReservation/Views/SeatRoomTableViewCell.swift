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
        if let leftSeat = left.availableSeats {
            leftAvailableLabel.text = "Available: %d".localized(arguments: leftSeat)
        }else{
            leftAvailableLabel.text = "Available: -".localized
        }
        if let right = right {
            rightRoomView.isUserInteractionEnabled = true
            rightRoomLabel.text = right.name
            rightFloorLabel.text = "Floor".localized(arguments: right.floor)
            if let rightSeat = right.availableSeats {
                rightAvailableLabel.text = "Available: %d".localized(arguments: rightSeat)
            }else{
                rightAvailableLabel.text = "Available: -".localized
            }
            rightRoomView.backgroundColor = roomViewBackgroundColor
        }else{
            rightRoomView.isUserInteractionEnabled = false
            rightAvailableLabel.text = ""
            rightRoomLabel.text = ""
            rightFloorLabel.text = ""
            rightRoomView.backgroundColor = nil
        }
    }
    
    @objc dynamic var titleColor: UIColor? {
        set {
            leftRoomLabel.textColor = newValue
            rightRoomLabel.textColor = newValue
        }
        get {
            return nil
        }
    }
    
    @objc dynamic var labelColor: UIColor? {
        set {
            leftFloorLabel.textColor = newValue
            leftAvailableLabel.textColor = newValue
            rightFloorLabel.textColor = newValue
            rightAvailableLabel.textColor = newValue
        }
        get {
            return nil
        }
    }
    
    @objc dynamic var roomViewBackgroundColor: UIColor? {
        set {
            leftRoomView.backgroundColor = newValue
        }
        get {
            return leftRoomView.backgroundColor
        }
    }
    
    @objc dynamic var roomViewShadowColor: UIColor? {
        set {
            leftShadowView.layer.shadowColor = newValue?.cgColor
            rightShadowView.layer.shadowColor = newValue?.cgColor
        }
        get {
            return nil
        }
    }
    
    static func updateAppearance(theme: Theme) {
        let configuration = ThemeConfiguration.current
        let appearance = SeatRoomTableViewCell.appearance()
        appearance.backgroundColor = nil
        appearance.titleColor = configuration.tintColor
        appearance.labelColor = configuration.textColor
        appearance.roomViewBackgroundColor = configuration.secondaryBackgroundColor
        appearance.roomViewShadowColor = configuration.shadowColor
    }
    
}
