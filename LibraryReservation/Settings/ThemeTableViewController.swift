//
//  ThemeTableViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/05/18.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class ThemeTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let theme = ThemeSettings.shared.theme
        update(theme: theme)
        switch theme {
        case .standard:
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))!
            cell.accessoryType = .checkmark
        case .dark:
            let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))!
            cell.accessoryType = .checkmark
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func update(theme: Theme, animated: Bool = false) {
        let configuration = ThemeConfiguration(theme: theme)
        let changed: ()-> Void = {
            self.tableView.backgroundColor = configuration.backgroundColor
            self.tableView.visibleCells.forEach { (cell) in
                cell.backgroundColor = configuration.secondaryBackgroundColor
                cell.textLabel?.textColor = configuration.textColor
            }
            self.tableView.separatorColor = configuration.tableViewSeperatorColor
            let textAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: configuration.textColor]
            
            self.navigationController?.navigationBar.barTintColor = configuration.barTintColor
            self.navigationController?.navigationBar.tintColor = configuration.tintColor
            self.navigationController?.navigationBar.barStyle = configuration.statusBarStyle
            self.navigationController?.navigationBar.titleTextAttributes = textAttributes
            if #available(iOS 11.0, *) {
                self.navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
            }
            self.navigationController?.navigationBar.layoutIfNeeded()
        }
        if animated {
            UIViewPropertyAnimator(duration: 1, curve: .linear, animations: changed).startAnimation()
        }else{
            changed()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        switch indexPath.row {
        case 0:
            let oldCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))!
            oldCell.accessoryType = .none
            update(theme: .standard, animated: true)
            ThemeSettings.shared.update(theme: .standard)
        case 1:
            let oldCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))!
            oldCell.accessoryType = .none
            update(theme: .dark, animated: true)
            ThemeSettings.shared.update(theme: .dark)
        default:
            return
        }
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
