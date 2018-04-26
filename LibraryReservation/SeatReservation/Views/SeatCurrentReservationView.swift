//
//  SeatCurrentReservationView.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class SeatCurrentReservationView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var libraryLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var seatLabel: UILabel!
    @IBOutlet weak var stateTimeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet weak var cancelEffectView: UIVisualEffectView!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var showingCancelEffect = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        translatesAutoresizingMaskIntoConstraints = false
        Bundle.main.loadNibNamed("SeatCurrentReservationView", owner: self, options: nil)
        addSubview(view)
        let top = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([top, leading, trailing, bottom])
        cancelEffectView.alpha = 0
        cancelEffectView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(showCancelEffect), name: .SeatReservationCancel, object: nil)
    }

    func update(reservation: SeatCurrentReservationRepresentable) {
        if showingCancelEffect {
            hideCancelEffect()
        }
        if let location = reservation.location {
            libraryLabel.text = location.library.rawValue
            roomLabel.text = location.room
            seatLabel.text = "SeatNo".localized(arguments: String(location.seat))
            floorLabel.text = "Floor".localized(arguments: location.floor)
        }
        timeLabel.text = "\(reservation.rawBegin) - \(reservation.rawEnd)"
        stateLabel.text = reservation.currentState.localizedState
        switch reservation.currentState {
        case .upcoming(let next):
            let hour = next / 60
            let min = next % 60
            let hourString = hour == 0 ? "": " \("h".localized(arguments: hour))"
            let minString = " \("mins".localized(arguments: min))"
            stateTimeLabel.text = "Start In".localized(arguments: hourString, minString)
        case .ongoing(let remain):
            let hour = remain / 60
            let min = remain % 60
            let hourString = hour == 0 ? "": " \("h".localized(arguments: hour))"
            let minString = " \("mins".localized(arguments: min))"
            stateTimeLabel.text = "End In".localized(arguments: hourString, minString)
        case .tempAway(let remain):
            let minString = " \("mins".localized(arguments: remain))"
            stateTimeLabel.text = "Expire In".localized(arguments: minString)
        case .late(let remain):
            let minString = " \("mins".localized(arguments: remain))"
            stateTimeLabel.text = "Expire In".localized(arguments: minString)
        case .autoEnd(let remain):
            let minString = " \("mins".localized(arguments: remain))"
            stateTimeLabel.text = "Auto End In".localized(arguments: minString)
        case .invalid:
            stateTimeLabel.text = "Please Refresh First".localized
        }
    }
    
    @objc func showCancelEffect() {
        cancelLabel.text = "Canceled".localized
        showingCancelEffect = true
        cancelEffectView.isHidden = false
        cancelEffectView.alpha = 0
        let animator = UIViewPropertyAnimator(duration: 1, curve: .easeOut) {
            self.cancelEffectView.alpha = 1
        }
        animator.startAnimation()
    }
    
    func hideCancelEffect() {
        let animator = UIViewPropertyAnimator(duration: 1, curve: .easeOut) {
            self.cancelEffectView.alpha = 0
        }
        animator.addCompletion { (_) in
            self.cancelEffectView.isHidden = true
            self.showingCancelEffect = false
        }
        animator.startAnimation()
    }
    
    func startCanceling() {
        cancelLabel.text = "Canceling...".localized
        showingCancelEffect = true
        cancelEffectView.isHidden = false
        cancelEffectView.alpha = 0
        let animator = UIViewPropertyAnimator(duration: 1, curve: .easeOut) {
            self.cancelEffectView.alpha = 1
        }
        animator.startAnimation()
        
    }
    
    func endCanceling() {
        let animator = UIViewPropertyAnimator(duration: 1, curve: .easeOut) {
            self.cancelEffectView.alpha = 0
        }
        animator.addCompletion { (_) in
            self.cancelEffectView.isHidden = true
            self.showingCancelEffect = false
        }
        animator.startAnimation()
    }
    
}
