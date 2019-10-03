//
//  SeatTimePicker.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/05/17.
//  Copyright © 2018 Weston Wu. All rights reserved.
//



class SeatTimePicker: NSObject {
    var now = Date()
    var textColor: UIColor!
    var startTimes: [SeatTime] = []
    var endTimes: [SeatTime] = []
    
    weak var timePickerView: UIPickerView!
    weak var delegate: SeatTimeFilterDelegate?
    
    var selectedTimes: (start: SeatTime, end: SeatTime)? {
        let startIndex = timePickerView.selectedRow(inComponent: 0)
        let endIndex = timePickerView.selectedRow(inComponent: 1)
        guard startIndex >= 0, endIndex >= 0 else {
            return nil
        }
        return (start: startTimes[startIndex], end: endTimes[endIndex])
    }
    
    init(pickerView: UIPickerView, delegate: SeatTimeFilterDelegate?) {
        super.init()
        updateTheme()
        timePickerView = pickerView
        timePickerView.delegate = self
        timePickerView.dataSource = self
        self.delegate = delegate
    }
    
    func update(startTimes: [SeatTime], filterStart: SeatTime?, filterEnd: SeatTime?) {
        now = Date()
        self.startTimes = startTimes
        self.endTimes = self.endTimes(for: 0)
        timePickerView.reloadAllComponents()
        if let filterStart = filterStart, let index = startTimes.index(of: filterStart) {
            timePickerView.selectRow(index, inComponent: 0, animated: false)
            self.endTimes = self.endTimes(for: index)
            timePickerView.reloadComponent(1)
            if let filterEnd = filterEnd, let endIndex = endTimes.index(of: filterEnd) {
                timePickerView.selectRow(endIndex, inComponent: 1, animated: false)
            }else{
                timePickerView.selectRow(0, inComponent: 1, animated: false)
            }
        }else{
            timePickerView.selectRow(0, inComponent: 0, animated: false)
            timePickerView.selectRow(0, inComponent: 1, animated: false)
        }
    }
    
    var nextForNow: SeatTime {
        let calender = Calendar.current
        var hour = calender.component(.hour, from: now)
        var min = calender.component(.minute, from: now)
        if min < 30 {
            min = 30
        }else{
            hour += 1
            min = 0
        }
        let time = hour * 60 + min
        return SeatTime(time: time)
    }
    
    func endTimes(`for` timeIndex: Int) -> [SeatTime] {
        if startTimes.isEmpty {
            return []
        }
        var endTimes = [SeatTime]()
        let firstIndex = timeIndex + 1
        var validNext = startTimes[timeIndex].next ?? nextForNow
        for index in firstIndex ... startTimes.count {
            if index == startTimes.count {
                endTimes.append(validNext)
                return endTimes
            }
            let next = startTimes[index]
            if next == validNext {
                endTimes.append(next)
                validNext = validNext.next!
            }else{
                endTimes.append(validNext)
                break
            }
        }
        return endTimes
    }
    
    func updateTheme() {
        textColor = ThemeConfiguration.current.textColor
    }
    
}

extension SeatTimePicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? startTimes.count : endTimes.count
    }
}

extension SeatTimePicker: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let text = component == 0 ? startTimes[row].value : endTimes[row].value
        return NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : textColor])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            endTimes = endTimes(for: row)
            pickerView.reloadComponent(1)
        }
    }
}

extension SeatTimePicker {
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
}
