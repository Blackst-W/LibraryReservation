//
//  CopyLabel.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class CopyLabel: UILabel {
    @IBInspectable var isCopyable = true {
        didSet {
            setup()
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return isCopyable
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var longPressGrestureRecognizer: UILongPressGestureRecognizer?
    
    func setup() {
        if isCopyable {
            isUserInteractionEnabled = true
            if longPressGrestureRecognizer != nil {return}
           longPressGrestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
            addGestureRecognizer(longPressGrestureRecognizer!)
        }else{
            isUserInteractionEnabled = false
            if let recognizer = longPressGrestureRecognizer {
                removeGestureRecognizer(recognizer)
            }
        }
    }
    
    @objc func longPressed() {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        let copyItem = UIMenuItem(title: "Copy", action: #selector(copyContent))
        menu.menuItems = [copyItem]
        menu.setTargetRect(bounds, in: self)
        menu.setMenuVisible(true, animated: true)
    }
    
    @objc func copyContent() {
        UIPasteboard.general.string = text
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if isCopyable && action == #selector(copyContent) {
            return true
        } else {
            return false
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
