//
//  ViewController.swift
//  Hunt and Scavenge
//
//  Created by Abraham on 3/2/23.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var activities = [Activity]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        activities = Activity.mockedActivities
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // This will reload data in order to reflect any changes made to a task after returning from the detail screen.
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? ActivityDetailController,
            // Get the index path for the current selected table view row.
           let selectedIndexPath = tableView.indexPathForSelectedRow {

            // Get the task associated with the slected index path
            let activity = activities[selectedIndexPath.row]

            // Set the selected task on the detail view controller.
            detailViewController.activity = activity
        }
        
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as? ActivityCell else {
            fatalError("Unable to dequeue Activity Cell")
        }

        cell.configure(with: activities[indexPath.row])

        return cell
    }
}

