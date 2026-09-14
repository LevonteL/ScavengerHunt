////
//  ViewController.swift
//  ScavengerHunt
//

import UIKit

class Task {
    let title: String
    let description: String
    var isCompleted: Bool

    init(title: String, description: String, isCompleted: Bool = false) {
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
    }
}

class ViewController: UIViewController,
                      UITableViewDataSource,
                      UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var tasks = [
        Task(
            title: "Take a photo of something red",
            description: "Find something red and attach a photo of it."
        ),
        Task(
            title: "Find something outdoors",
            description: "Go outside and attach a photo of something you find."
        ),
        Task(
            title: "Take a photo of something interesting",
            description: "Find something interesting and attach a photo of it."
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Scavenger Hunt"

        tableView.dataSource = self
        tableView.delegate = self
    }

    // Refresh the list whenever we return from the detail screen.
    // This allows completed tasks to immediately show as completed.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    // MARK: - Table View Data Source

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return tasks.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TaskCell",
            for: indexPath
        )

        let task = tasks[indexPath.row]

        var content = cell.defaultContentConfiguration()

        content.text = task.title

        if task.isCompleted {
            content.secondaryText = "Completed ✓"
            cell.accessoryType = .checkmark
        } else {
            content.secondaryText = "Tap to view task"
            cell.accessoryType = .none
        }

        cell.contentConfiguration = content

        return cell
    }

    // MARK: - Navigation

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        let selectedTask = tasks[indexPath.row]

        performSegue(
            withIdentifier: "ShowTaskDetail",
            sender: selectedTask
        )
    }

    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {

        if segue.identifier == "ShowTaskDetail",
           let detailVC = segue.destination as? TaskDetailViewController,
           let task = sender as? Task {

            detailVC.task = task
            detailVC.taskTitle = task.title
        }
    }
}
