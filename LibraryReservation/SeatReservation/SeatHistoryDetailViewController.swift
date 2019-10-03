//
//  SeatHistoryDetailViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class SeatHistoryDetailViewController: UITableViewController {

    var reservation: SeatReservation!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var libraryLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var seatLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet var labels: [UILabel]!
    
    class func makeFromStoryboard() -> SeatHistoryDetailViewController {
        let storyboard = UIStoryboard(name: "SeatStoryboard", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "HistoryDetailViewController") as! SeatHistoryDetailViewController
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idLabel.text = String(reservation.id)
        dateLabel.text = reservation.rawDate
        timeLabel.text = "\(reservation.rawBegin) - \(reservation.rawEnd)"
        stateLabel.text = reservation.state.localizedDescription
        if let location = reservation.location {
            libraryLabel.text = location.library.rawValue
            floorLabel.text = "Floor".localized(arguments: location.floor)
            roomLabel.text = location.room
            seatLabel.text = "SeatNo".localized(arguments: String(location.seat))
        }
        locationLabel.text = reservation.rawLocation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTheme()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var previewActionItems: [UIPreviewActionItem] {
        let copyAction = UIPreviewAction(title: "Copy Location".localized, style: .default) { (_, _) in
            UIPasteboard.general.string = self.reservation.rawLocation
        }
        return [copyAction]
    }
    
    func updateTheme() {
        let configuration = ThemeConfiguration.current
        labels.forEach { (label) in
            label.textColor = configuration.textColor
        }
    }
}
