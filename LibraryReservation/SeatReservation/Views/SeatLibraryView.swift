//
//  SeatLibraryView.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/20.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

protocol SeatLibraryViewDelegate: class {
    func select(library: Library?)
}

class SeatLibraryView: UIStackView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    var upperStackView: UIStackView!
    var lowerStackView: UIStackView!
    
    var mainLibraryView: UIView!
    var engineeringLibraryView: UIView!
    var infoLibraryView: UIView!
    var medicineLibraryView: UIView!
    
    var mainButton: UIButton!
    var engineeringButton: UIButton!
    var infoButton: UIButton!
    var medicineButton: UIButton!
    
    var tipLabel: UILabel!
    
    var isSelected = false
    var selectedLibrary: Library?
    weak var delegate: SeatLibraryViewDelegate?
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        upperStackView = viewWithTag(10) as! UIStackView
        lowerStackView = viewWithTag(20) as! UIStackView
        
        mainLibraryView = viewWithTag(100)!
        engineeringLibraryView = viewWithTag(200)!
        infoLibraryView = viewWithTag(300)!
        medicineLibraryView = viewWithTag(400)!
        
        mainButton = viewWithTag(1000) as! UIButton
        engineeringButton = viewWithTag(2000) as! UIButton
        infoButton = viewWithTag(3000) as! UIButton
        medicineButton = viewWithTag(4000) as! UIButton
        
        tipLabel = viewWithTag(50) as! UILabel
        
        mainButton.addTarget(self, action: #selector(onButtonClick(_:)), for: .touchUpInside)
        engineeringButton.addTarget(self, action: #selector(onButtonClick(_:)), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(onButtonClick(_:)), for: .touchUpInside)
        medicineButton.addTarget(self, action: #selector(onButtonClick(_:)), for: .touchUpInside)
    }
    
    @objc func onButtonClick(_ sender: UIButton) {
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
        if self.isSelected {
            //deselect
            sender.setTitleColor(#colorLiteral(red: 0, green: 0.5018912177, blue: 1, alpha: 1), for: .normal)
            sender.backgroundColor = .white
            switch sender {
            case self.mainButton:
                self.engineeringLibraryView.isHidden = false
                self.engineeringLibraryView.alpha = 1
                self.lowerStackView.isHidden = false
                self.lowerStackView.alpha = 1
            case self.engineeringButton:
                self.mainLibraryView.isHidden = false
                self.mainLibraryView.alpha = 1
                self.lowerStackView.isHidden = false
                self.lowerStackView.alpha = 1
            case self.infoButton:
                self.medicineLibraryView.isHidden = false
                self.medicineLibraryView.alpha = 1
                self.upperStackView.isHidden = false
                self.upperStackView.alpha = 1
            case self.medicineButton:
                self.infoLibraryView.isHidden = false
                self.infoLibraryView.alpha = 1
                self.upperStackView.isHidden = false
                self.upperStackView.alpha = 1
            default:
                return
            }
        }else{
            //select
//            self.tipLabel.isHidden = true
//            self.tipLabel.alpha = 0
            sender.setTitleColor(.white, for: .normal)
            sender.backgroundColor = #colorLiteral(red: 0, green: 0.5018912177, blue: 1, alpha: 1)
            switch sender {
            case self.mainButton:
                self.engineeringLibraryView.isHidden = true
                self.engineeringLibraryView.alpha = 0
                self.lowerStackView.isHidden = true
                self.lowerStackView.alpha = 0
            case self.engineeringButton:
                self.mainLibraryView.isHidden = true
                self.mainLibraryView.alpha = 0
                self.lowerStackView.isHidden = true
                self.lowerStackView.alpha = 0
            case self.infoButton:
                self.medicineLibraryView.isHidden = true
                self.medicineLibraryView.alpha = 0
                self.upperStackView.isHidden = true
                self.upperStackView.alpha = 0
            case self.medicineButton:
                self.infoLibraryView.isHidden = true
                self.infoLibraryView.alpha = 0
                self.upperStackView.isHidden = true
                self.upperStackView.alpha = 0
            default:
                return
            }
        }
            self.layoutIfNeeded()
        }
        animator.addCompletion { (_) in
            self.isSelected = !self.isSelected
        }
        animator.startAnimation()
        
        if isSelected {
            //deselect
            selectedLibrary = nil
        }else{
            switch sender {
            case mainButton:
                selectedLibrary = .main
            case engineeringButton:
                selectedLibrary = .engineering
            case infoButton:
                selectedLibrary = .info
            case medicineButton:
                selectedLibrary = .medicine
            default:
                return
            }
        }
        self.delegate?.select(library: selectedLibrary)
    }
    
}
