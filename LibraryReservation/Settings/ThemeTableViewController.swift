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
        case .black:
            let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))!
            cell.accessoryType = .checkmark
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func update(theme: Theme, animated: Bool = false) {
        var backgroundColor: UIColor!
        var cellBackgroundColor: UIColor!
        var cellLabelColor: UIColor!
        var seperateColor: UIColor!
        var navigationBarTintColor: UIColor?
        var navigationTintColor: UIColor?
        var navigationTitleColor: UIColor!
        var statusBarStyle: UIBarStyle!
        switch theme {
        case .black:
            backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1137254902, alpha: 1)
            cellBackgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
            cellLabelColor = .white
            seperateColor = #colorLiteral(red: 0.2078431373, green: 0.2078431373, blue: 0.2156862745, alpha: 1)
            navigationBarTintColor = .black
            navigationTintColor = #colorLiteral(red: 0.9019607843, green: 0.5803921569, blue: 0.137254902, alpha: 1)
            navigationTitleColor = .white
            statusBarStyle = .black
        case .standard:
            backgroundColor = .groupTableViewBackground
            cellBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cellLabelColor = .black
            seperateColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8, alpha: 1)
            navigationBarTintColor = nil
            navigationTintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            navigationTitleColor = .black
            statusBarStyle = .default
        }
        let changed: ()-> Void = {
            self.tableView.backgroundColor = backgroundColor
            self.tableView.visibleCells.forEach { (cell) in
                cell.backgroundColor = cellBackgroundColor
                cell.textLabel?.textColor = cellLabelColor
                //                    cell.textLabel?.backgroundColor = cellBackgroundColor
            }
            self.tableView.separatorColor = seperateColor
            let textAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: navigationTitleColor]
            
            self.navigationController?.navigationBar.barTintColor = navigationBarTintColor
            self.navigationController?.navigationBar.tintColor = navigationTintColor
            self.navigationController?.navigationBar.barStyle = statusBarStyle
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
            update(theme: .black, animated: true)
            ThemeSettings.shared.update(theme: .black)
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
