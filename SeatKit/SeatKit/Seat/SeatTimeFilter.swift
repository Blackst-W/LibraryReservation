//
//  SeatTimeFilter.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/22.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

public protocol SeatTimeFilterDelegate: class {
    func pickerUpdate(start: SeatTime, end: SeatTime)
}

public class SeatTimeFilter: NSObject {
    var startTimes: [SeatTime]!
    var endTimes: [SeatTime]!
    weak var timePickerView: UIPickerView!
    weak var delegate: SeatTimeFilterDelegate?
    
    public init(pickerView: UIPickerView, delegate: SeatTimeFilterDelegate?) {
        super.init()
        generateStartTimes()
        generateEndTimes(selection: 0)
        timePickerView = pickerView
        timePickerView.delegate = self
        timePickerView.dataSource = self
        self.delegate = delegate
        timePickerView.reloadAllComponents()
    }
    
    public func reset() {
        generateEndTimes(selection: 0)
        timePickerView.selectRow(0, inComponent: 0, animated: false)
        timePickerView.reloadComponent(1)
        timePickerView.selectRow(0, inComponent: 1, animated: false)
    }
    
    public var selectedTimes: (start: SeatTime, end: SeatTime) {
        let startIndex = timePickerView.selectedRow(inComponent: 0)
        let endIndex = timePickerView.selectedRow(inComponent: 1)
        return (start: startTimes[startIndex], end: endTimes[endIndex])
    }
    
    func generateStartTimes() {
        let start = 8 * 60  //8:00
        let end = 22 * 60   //22:00
        startTimes = []
        var current = start
        repeat {
            let seatTime = SeatTime(time: current)
            startTimes.append(seatTime)
            current += 30
        }while(current < end)
    }
    
    func generateEndTimes(selection: Int) {
        let start = 8 * 60 + selection * 30
        let end = 22 * 60
        endTimes = []
        var current = start + 30
        repeat {
            let seatTime = SeatTime(time: current)
            endTimes.append(seatTime)
            current += 30
        }while(current <= end)
    }
}

extension SeatTimeFilter: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? startTimes.count : endTimes.count
    }
}

extension SeatTimeFilter: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? startTimes[row].value : endTimes[row].value
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            generateEndTimes(selection: row)
            pickerView.reloadComponent(1)
        }
        let startIndex = pickerView.selectedRow(inComponent: 0)
        let endIndex = pickerView.selectedRow(inComponent: 1)
        delegate?.pickerUpdate(start: startTimes[startIndex], end: endTimes[endIndex])
    }
    
}
