//
//  SeatTimeFilter.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/22.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import WatchKit

public protocol SeatTimeFilterDelegate: class {
    func pickerUpdate(start: SeatTime, end: SeatTime)
}

public class SeatTimeFilter: NSObject {
    var startTimes: [SeatTime]!
    var endTimes: [SeatTime]!
    weak var startPicker: WKInterfacePicker!
    weak var endPicker: WKInterfacePicker!
    weak var delegate: SeatTimeFilterDelegate?
    
    public init(start: WKInterfacePicker, end: WKInterfacePicker, delegate: SeatTimeFilterDelegate?) {
        super.init()
        generateStartTimes()
        generateEndTimes(selection: 0)
        startPicker = start
        endPicker = end
        self.delegate = delegate
        startPicker.setItems(startTimes.map{ (time) -> WKPickerItem in
            let item = WKPickerItem()
            item.title = time.value
            return item
        })
        endPicker.setItems(endTimes.map{ (time) -> WKPickerItem in
            let item = WKPickerItem()
            item.title = time.value
            return item
        })
//        timePickerView.reloadAllComponents()
    }
    
    public func reset() {
        startPicker.setSelectedItemIndex(0)
        startIndex = 0
        endPicker.setSelectedItemIndex(0)
    }
    
    public var startIndex: Int = 0 {
        didSet {
            generateEndTimes(selection: startIndex)
            if endIndex >= endTimes.count {
                endIndex = max(endTimes.count - 1, 0)
            }
            endPicker.setItems(endTimes.map{ (time) -> WKPickerItem in
                let item = WKPickerItem()
                item.title = time.value
                return item
            })
            endPicker.setSelectedItemIndex(endIndex)
            delegate?.pickerUpdate(start: startTimes[startIndex], end: endTimes[endIndex])
        }
    }
    
    public var endIndex: Int = 0 {
        didSet {
            delegate?.pickerUpdate(start: startTimes[startIndex], end: endTimes[endIndex])
        }
    }
    
    public var selectedTimes: (start: SeatTime, end: SeatTime) {
        return (startTimes[startIndex], endTimes[endIndex])
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

//extension SeatTimeFilter: UIPickerViewDataSource {
//    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 2
//    }
//    
//    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return component == 0 ? startTimes.count : endTimes.count
//    }
//}
//
//extension SeatTimeFilter: UIPickerViewDelegate {
//    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return component == 0 ? startTimes[row].value : endTimes[row].value
//    }
//    
//    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if component == 0 {
//            generateEndTimes(selection: row)
//            pickerView.reloadComponent(1)
//        }
//        let startIndex = pickerView.selectedRow(inComponent: 0)
//        let endIndex = pickerView.selectedRow(inComponent: 1)
//        delegate?.pickerUpdate(start: startTimes[startIndex], end: endTimes[endIndex])
//    }
//    
//}
