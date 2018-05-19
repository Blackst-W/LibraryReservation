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
        updateTheme()
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
    
    var selectedTimes: (start: SeatTime, end: SeatTime)? {
        let startIndex = timePickerView.selectedRow(inComponent: 0)
        let endIndex = timePickerView.selectedRow(inComponent: 1)
        guard startIndex >= 0, endIndex >= 0 else {
            return nil
        }
        return (start: startTimes[startIndex], end: endTimes[endIndex])
    }
    
    func actualStartMinutes() -> Int {
        let configuration = AppSettings.shared.libraryConfiguration
        var start = configuration.startMinutes
        let end = configuration.endMinutes
        let currentDate = Date()
        if currentDate.minutes < end,
            currentDate.minutes > start {
            start = currentDate.minutes / 60 * 60 + 30
        }
        return start
    }
    
    func generateStartTimes() {
        let configuration = AppSettings.shared.libraryConfiguration
        let start = actualStartMinutes()
        let end = configuration.endMinutes
        startTimes = []
        var current = start
        while current < end {
            let seatTime = SeatTime(time: current)
            startTimes.append(seatTime)
            current += 30
        }
    }
    
    func generateEndTimes(selection: Int) {
        endTimes = []
        if startTimes.isEmpty {
            return
        }
        let configuration = AppSettings.shared.libraryConfiguration
        let start = startTimes[selection].minutes!
        let end = configuration.endMinutes
        var current = start + 30
        while (current <= end) {
            let seatTime = SeatTime(time: current)
            endTimes.append(seatTime)
            current += 30
        }
    }
    
    var textColor: UIColor!
    
    func updateTheme() {
        textColor = ThemeConfiguration.current.textColor
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
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let text = component == 0 ? startTimes[row].value : endTimes[row].value
        return NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : textColor])
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
