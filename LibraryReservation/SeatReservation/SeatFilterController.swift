//
//  SeatFilterController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/21.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

protocol SeatFilterViewDelegate: class {
    func update(filter: SeatFilterCondition)
}

class SeatFilterController: UITableViewController {

    @IBOutlet weak var timeFilterSwitch: UISwitch!
    @IBOutlet weak var computerSwitch: UISwitch!
    @IBOutlet weak var powerSwitch: UISwitch!
    @IBOutlet weak var windowSwitch: UISwitch!
    @IBOutlet weak var timePickerView: UIPickerView!
    var date: Date!
    var startTimes: [String] = []
    var endTimes: [String] = []
    var filter: SeatFilterCondition!
    weak var delegate: SeatFilterViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        computerSwitch.setOn(filter.needComputer, animated: false)
        powerSwitch.setOn(filter.needPower, animated: false)
        windowSwitch.setOn(filter.needWindow, animated: false)
        
        timeFilterSwitch.isOn = filter.begin != nil
        timePickerView.delegate = self
        timePickerView.dataSource = self
        
        generateStartTimes()
        generateEndTimes()
        if let begin = filter.begin,
            let end = filter.end {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let startString = dateFormatter.string(from: begin)
            let startIndex = startTimes.index(of: startString)!
            endTimes = Array(endTimes[startIndex..<endTimes.endIndex])
            let endString = dateFormatter.string(from: end)
            let endIndex = endTimes.index(of: endString)!
            timePickerView.reloadAllComponents()
            timePickerView.selectRow(startIndex, inComponent: 0, animated: false)
            timePickerView.selectRow(endIndex, inComponent: 1, animated: false)
        }else{
            timePickerView.reloadAllComponents()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var newFilter = SeatFilterCondition(needPower: powerSwitch.isOn, needWindow: windowSwitch.isOn, needComputer: computerSwitch.isOn)
        if timeFilterSwitch.isOn {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let startString = dateFormatter.string(from: date) + " " + startTimes[timePickerView.selectedRow(inComponent: 0)]
            let endString = dateFormatter.string(from: date) + " " + endTimes[timePickerView.selectedRow(inComponent: 1)]
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let start = dateFormatter.date(from: startString)!
            let end = dateFormatter.date(from: endString)!
            newFilter.time(begin: start, end: end)
        }
        delegate?.update(filter: newFilter)
    }
    
    func generateStartTimes() {
        let start = 8 * 60  //8:00
        let end = 22 * 60   //22:00
        startTimes = []
        var current = start
        repeat {
            let hour = current / 60
            var hourString = "\(hour)"
            if hour < 10 {
                hourString = "0" + hourString
            }
            let min = current % 60
            var minString = "\(min)"
            if min < 10 {
                minString = "0" + minString
            }
            startTimes.append(hourString+":"+minString)
            current += 30
        }while(current < end)
    }
    
    func generateEndTimes() {
        let startIndex = timePickerView.selectedRow(inComponent: 0)
        let start = 8 * 60 + startIndex * 30
        let end = 22 * 60
        endTimes = []
        var current = start + 30
        repeat {
            let hour = current / 60
            var hourString = "\(hour)"
            if hour < 10 {
                hourString = "0" + hourString
            }
            let min = current % 60
            var minString = "\(min)"
            if min < 10 {
                minString = "0" + minString
            }
            endTimes.append(hourString+":"+minString)
            current += 30
        }while(current <= end)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetFilter(_ sender: Any) {
        timeFilterSwitch.setOn(false, animated: true)
        computerSwitch.setOn(false, animated: true)
        powerSwitch.setOn(false, animated: true)
        windowSwitch.setOn(false, animated: true)
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SeatFilterController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? startTimes.count : endTimes.count
    }
}

extension SeatFilterController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? startTimes[row] : endTimes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            generateEndTimes()
            pickerView.reloadComponent(1)
        }
    }
    
}
