//
//  AboutViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/05/19.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let theme = ThemeSettings.shared.theme
        var backgroundColor: UIColor!
        var textColor: UIColor!
        var tintColor: UIColor!
        
        switch theme {
        case .black:
            backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1137254902, alpha: 1)
            textColor = .white
            tintColor = #colorLiteral(red: 0.9019607843, green: 0.5803921569, blue: 0.137254902, alpha: 1)
        case .standard:
            backgroundColor = .groupTableViewBackground
            textColor = .black
            tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        }
        
        view.backgroundColor = backgroundColor
        textView.textColor = textColor
        textView.tintColor = tintColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
