//
//  SeatHistoryViewController.swift
//  LibraryReservation
//
//  Created by Weston Wu on 2018/04/16.
//  Copyright © 2018 Weston Wu. All rights reserved.
//

import UIKit

class SeatHistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var remindLabel: UILabel!
    
    @IBOutlet weak var loadMoreLabel: UILabel!
    
    var manager: SeatHistoryManager!
    
    var data: [SeatReservation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        manager.delegate = self
        data = manager.reservations
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshStateChanged), for: .valueChanged)
        tableView.refreshControl = control
        tableView.reloadData()
        control.beginRefreshing()
        manager.reload()
    }
    
    @objc func refreshStateChanged() {
        if tableView.refreshControl!.isRefreshing {
            manager.reload()
        }
    }

    @objc func checkMore() {
        if !manager.loadMore() {
            loadMoreLabel.text = "No more reservations in the last 30 days".localized
        }
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

extension SeatHistoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! SeatHistoryTableViewCell
        cell.update(reservation: data[indexPath.row])
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: cell)
        }
        return cell
    }
    
}

extension SeatHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 146
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let reservation = data[indexPath.row]
        let viewController = SeatHistoryDetailViewController.makeFromStoryboard()
        viewController.reservation = reservation
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == data.count - 1 {
            checkMore()
        }
    }
}

extension SeatHistoryViewController: SeatHistoryManagerDelegate {
    func requireLogin() {
        autoLogin(delegate: self)
    }
    func updateFailed(error: Error) {
        tableView.refreshControl?.endRefreshing()
        let alertController = UIAlertController(title: "Failed To Update".localized, message: error.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func updateFailed(failedResponse: SeatFailedResponse) {
        if failedResponse.code == "12" {
            autoLogin(delegate: self)
            return
        }
        tableView.refreshControl?.endRefreshing()
        let alertController = UIAlertController(title: "Failed To Update".localized, message: failedResponse.localizedDescription, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close".localized, style: .default, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func update(reservations: [SeatReservation]) {
        if reservations.isEmpty {
            remindLabel.isHidden = false
        }else{
            remindLabel.isHidden = true
        }
        data = reservations
        tableView.reloadData()
        tableView.refreshControl!.perform(#selector(tableView.refreshControl!.endRefreshing), with: nil, afterDelay: 0.5)
    }
    
    func update(current: SeatCurrentReservationRepresentable?) {
        NotificationManager.shared.schedule(reservation: current)
        return
    }
    
    func loadMore() {
        tableView.reloadData()
        if manager.end {
            loadMoreLabel.text = "No more reservations in the last 30 days".localized
        }
    }
}

extension SeatHistoryViewController: LoginViewDelegate {
    func loginResult(result: LoginResult) {
        switch result {
        case .cancel:
            navigationController?.popViewController(animated: true)
        case .success(_):
            return
        }
    }
}

extension SeatHistoryViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let sourceCell = previewingContext.sourceView as? SeatHistoryTableViewCell {
            let indexPath = tableView.indexPath(for: sourceCell)!
            let reservation = data[indexPath.row]
            let viewController = SeatHistoryDetailViewController.makeFromStoryboard()
            viewController.reservation = reservation
            viewController.preferredContentSize = CGSize(width: 0, height: 0)
            
            return viewController
        }else{
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
