//
//  SeatHistoryInterfaceController.swift
//  WatchApp Extension
//
//  Created by Weston Wu on 2018/05/01.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import WatchKit
import WatchSeatKit


class SeatHistoryInterfaceController: WKInterfaceController {
    
    @IBOutlet var noHistoryLabel: WKInterfaceLabel!
    @IBOutlet var historyTable: WKInterfaceTable!
    var historys = [SeatReservation]()
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        guard let historyReservations = context as? [SeatReservation] else {
            noHistoryLabel.setHidden(false)
            historyTable.setHidden(true)
            return
        }
        noHistoryLabel.setHidden(true)
        historyTable.setHidden(false)
        historys = historyReservations
        configureTable()
    }
    
    func configureTable() {
        if historys.isEmpty {
            noHistoryLabel.setHidden(false)
            historyTable.setHidden(true)
            return
        }
        historyTable.setNumberOfRows(historys.count, withRowType: "HistoryRow")
        for (index, history) in historys.enumerated() {
            let rowController = historyTable.rowController(at: index) as! SeatHistoryRowController
            rowController.update(reservation: history)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
