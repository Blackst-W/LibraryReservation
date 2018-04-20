//
//  SeatRoomTableViewCell.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/20.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

enum SeatRoomSelection: Int {
    case left
    case right
    case none
}

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
    
    var roomSelected = false
    var selectedRoom = SeatRoomSelection.none
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func update(left: Room, right: Room?) {
        reset()
        leftRoomLabel.text = left.name
        leftFloorLabel.text = "\(left.floor)F"
        if let leftSeat = left.availableSeat {
            leftAvailableLabel.text = "Available: \(leftSeat)"
        }else{
            leftAvailableLabel.text = "Available: -"
        }
        if let right = right {
            rightRoomView.isUserInteractionEnabled = true
            rightShadowView.layer.shadowOpacity = 0.15
            rightRoomLabel.text = right.name
            rightFloorLabel.text = "\(right.floor)F"
            if let rightSeat = right.availableSeat {
                rightAvailableLabel.text = "Available: \(rightSeat)"
            }else{
                rightAvailableLabel.text = "Available: -"
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
    
    func reset() {
        switch selectedRoom {
        case .none:
            return
        case .left:
            roomSelected(leftRoomView)
        case .right:
            roomSelected(rightRoomView)
        }
    }
    
    func hideLeft() {
        leftShadowView.alpha = 0
        leftShadowView.isHidden = true
        rightRoomView.backgroundColor = #colorLiteral(red: 0, green: 0.5018912177, blue: 1, alpha: 1)
        rightRoomLabel.textColor = .white
        rightAvailableLabel.textColor = .white
        rightFloorLabel.textColor = .white
    }
    
    func hideRight() {
        rightShadowView.alpha = 0
        rightShadowView.isHidden = true
        leftRoomView.backgroundColor = #colorLiteral(red: 0, green: 0.5018912177, blue: 1, alpha: 1)
        leftRoomLabel.textColor = .white
        leftAvailableLabel.textColor = .white
        leftFloorLabel.textColor = .white
    }
    
    func showLeft() {
        leftShadowView.isHidden = false
        leftShadowView.alpha = 1
        rightRoomView.backgroundColor = .white
        rightRoomLabel.textColor = #colorLiteral(red: 0, green: 0.5018912177, blue: 1, alpha: 1)
        rightAvailableLabel.textColor = .black
        rightFloorLabel.textColor = .black
    }
    
    func showRight() {
        rightShadowView.isHidden = false
        rightShadowView.alpha = 1
        leftRoomView.backgroundColor = .white
        leftRoomLabel.textColor = #colorLiteral(red: 0, green: 0.5018912177, blue: 1, alpha: 1)
        leftAvailableLabel.textColor = .black
        leftFloorLabel.textColor = .black
    }
    
    @IBAction func roomSelected(_ sender: UIControl) {
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            if self.roomSelected {
                //deselect
                self.selectedRoom = .none
                switch sender {
                case self.leftRoomView:
                    self.showRight()
                case self.rightRoomView:
                    self.showLeft()
                default:
                    return
                }
            }else{
                //select
                switch sender {
                case self.leftRoomView:
                    self.selectedRoom = .left
                    self.hideRight()
                case self.rightRoomView:
                    self.selectedRoom = .right
                    self.hideLeft()
                default:
                    return
                }
            }
            self.layoutIfNeeded()
        }
        animator.addCompletion { (_) in
            self.roomSelected = !self.roomSelected
        }
        animator.startAnimation()
    }

}
