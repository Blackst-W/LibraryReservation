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
        let configuration = ThemeConfiguration.current
        view.backgroundColor = configuration.backgroundColor
        textView.textColor = configuration.textColor
        textView.tintColor = configuration.tintColor
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
