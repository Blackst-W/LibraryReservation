//
//  AboutViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/05/19.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UIScrollViewDelegate {

    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = ThemeConfiguration.current
        view.backgroundColor = configuration.backgroundColor
        textView.textColor = configuration.textColor
        textView.tintColor = configuration.tintColor
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height * 1.2)
    }

    override func viewWillLayoutSubviews() {
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.frame = view.frame
        
        iconImageView.frame = CGRect(x: view.frame.midX - iconImageView.frame.width / 2, y: iconImageView.frame.minY, width: iconImageView.frame.width, height: iconImageView.frame.height)
        textView.frame = CGRect(x: view.frame.minX + 8, y: iconImageView.frame.maxY + 16, width: view.frame.width - 16, height: textView.frame.height)
        qrCodeImageView.frame = CGRect(x: view.frame.midX - qrCodeImageView.frame.width / 2, y: textView.frame.maxY + 20, width: qrCodeImageView.frame.width, height: qrCodeImageView.frame.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
