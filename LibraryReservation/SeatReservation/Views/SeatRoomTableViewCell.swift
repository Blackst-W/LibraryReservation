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
            rightShadowView.layer.shadowOpacity = 0.15
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
            rightShadowView.layer.shadowOpacity = 0
            rightAvailableLabel.text = ""
            rightRoomLabel.text = ""
            rightFloorLabel.text = ""
            rightRoomView.backgroundColor = .clear
        }
    }
    
    @objc dynamic var titleColor: UIColor? {
        didSet {
            leftRoomLabel.textColor = titleColor
            rightRoomLabel.textColor = titleColor
        }
    }
    
    @objc dynamic var labelColor: UIColor? {
        didSet {
            leftFloorLabel.textColor = labelColor
            leftAvailableLabel.textColor = labelColor
            rightFloorLabel.textColor = labelColor
            rightAvailableLabel.textColor = labelColor
        }
    }
    
    @objc dynamic var roomViewBackgroundColor: UIColor? {
        didSet {
            leftRoomView.backgroundColor = roomViewBackgroundColor
        }
    }
    
    @objc dynamic var roomViewShadowColor: UIColor? {
        didSet {
            leftShadowView.layer.shadowColor = roomViewShadowColor?.cgColor
            rightShadowView.layer.shadowColor = roomViewShadowColor?.cgColor
        }
    }
    
    static func updateAppearance(theme: Theme) {
        let appearance = SeatRoomTableViewCell.appearance()
        appearance.backgroundColor = nil
        switch theme {
        case .black:
            appearance.titleColor = #colorLiteral(red: 0.9019607843, green: 0.5803921569, blue: 0.137254902, alpha: 1)
            appearance.labelColor = .white
            appearance.roomViewBackgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
            appearance.roomViewShadowColor = .white
        case .standard:
            appearance.titleColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            appearance.labelColor = .black
            appearance.roomViewBackgroundColor = .white
            appearance.roomViewShadowColor = .black
        }
    }
    
}
