//
//  HabitListViewController.swift
//

import UIKit

class HabitListViewController: UIViewController {

    var tableView: UITableView!
    var emptyStateLabel: UILabel!

    // The main habits array initialized with a default value of an empty array.
    var habits = [Habit]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the title
        self.title = "Habits"
        
        // Set background color
        view.backgroundColor = .systemBackground

        // Create table view programmatically
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground

        // Create empty state label programmatically
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "Tap the \"+\" button to add habits"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.font = UIFont.systemFont(ofSize: 17)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add to view
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)

        // Set up constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // Register cell - use subtitle style for description
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")

        // Add the + button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapNewHabitButton)
        )

        // Hide top cell separator
        tableView.tableHeaderView = UIView()
    }

    // Refresh the habits list each time the view appears in case any habits were updated on the other tab.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshHabits()
    }

    // When the "+" button is tapped, show alert to add habit
    @objc func didTapNewHabitButton() {
        let alert = UIAlertController(title: "New Habit", message: "Enter habit details", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Habit name (required)"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Description (optional)"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard let nameField = alert.textFields?.first,
                  let name = nameField.text, !name.isEmpty else {
                let errorAlert = UIAlertController(title: "Error", message: "Habit name is required", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
                return
            }
            
            let description = alert.textFields?[1].text
            let habit = Habit(name: name, description: description?.isEmpty == true ? nil : description)
            habit.save()
            self.refreshHabits()
        })
        
        present(alert, animated: true)
    }
    
    // Handle habit completion toggle
    @objc func toggleHabit(_ sender: UIButton) {
        var habit = habits[sender.tag]
        habit.toggleCompletionForToday()
        habit.save()
        refreshHabits()
    }

    // MARK: - Helper Functions
    
    // Refresh all habits
    private func refreshHabits() {
        // Get the current saved habits
        var habits = Habit.getHabits()
        
        // Sort habits: incomplete first, then by creation date
        habits.sort { lhs, rhs in
            if lhs.isCompletedToday() && !rhs.isCompletedToday() {
                return false // rhs (incomplete) comes first
            } else if !lhs.isCompletedToday() && rhs.isCompletedToday() {
                return true // lhs (incomplete) comes first
            } else {
                return lhs.createdDate < rhs.createdDate // Sort by creation date
            }
        }
        
        // Update the main habits array
        self.habits = habits
        
        // Hide the "empty state label" if there are habits present
        emptyStateLabel.isHidden = !habits.isEmpty
        
        // Reload the table view data
        tableView.reloadData()
    }
}

// MARK: - Table View Data Source Methods

extension HabitListViewController: UITableViewDataSource {

    // The number of rows to show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }

    // Create and configure a cell for each row of the table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let habit = habits[indexPath.row]
        
        // Configure cell content
        cell.textLabel?.text = habit.name
        
        // Show description or streak info
        if let description = habit.description, !description.isEmpty {
            cell.detailTextLabel?.text = description
        } else {
            cell.detailTextLabel?.text = habit.currentStreak > 0 ? "\(habit.currentStreak) day streak 🔥" : "No streak yet"
        }
        
        // Set text colors based on completion
        let isCompletedToday = habit.isCompletedToday()
        cell.textLabel?.textColor = isCompletedToday ? .secondaryLabel : .label
        cell.detailTextLabel?.textColor = isCompletedToday ? .tertiaryLabel : .secondaryLabel
        
        // Add completion button
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.setImage(UIImage(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle"), for: .normal)
        button.tintColor = isCompletedToday ? .systemGreen : .tertiaryLabel
        button.tag = indexPath.row
        button.addTarget(self, action: #selector(toggleHabit(_:)), for: .touchUpInside)
        cell.accessoryView = button
        
        return cell
    }

    // Enable "Swipe to Delete" functionality
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            habits.remove(at: indexPath.row)
            Habit.save(habits)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Show empty state if no habits left
            emptyStateLabel.isHidden = !habits.isEmpty
        }
    }
}

// MARK: - Table View Delegate Methods

extension HabitListViewController: UITableViewDelegate {

    // Handle row selection for editing habits
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedHabit = habits[indexPath.row]
        
        // Show edit alert
        let alert = UIAlertController(title: "Edit Habit", message: "Update habit details", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = selectedHabit.name
            textField.placeholder = "Habit name (required)"
        }
        
        alert.addTextField { textField in
            textField.text = selectedHabit.description
            textField.placeholder = "Description (optional)"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let nameField = alert.textFields?.first,
                  let name = nameField.text, !name.isEmpty else {
                let errorAlert = UIAlertController(title: "Error", message: "Habit name is required", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
                return
            }
            
            var updatedHabit = selectedHabit
            updatedHabit.name = name
            updatedHabit.description = alert.textFields?[1].text?.isEmpty == true ? nil : alert.textFields?[1].text
            updatedHabit.save()
            self.refreshHabits()
        })
        
        present(alert, animated: true)
    }
}
