//
//  CalendarViewController.swift
//

import UIKit

class CalendarViewController: UIViewController {

    // The array of all habits to display in the calendar.
    var habits: [Habit] = []

    // The habits who's due dates match the current selected calendar date.
    private var selectedHabits: [Habit] = []

    private var calendarView: UICalendarView!
    private var calendarContainerView: UIView!
    private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set title and background
        self.title = "Calendar"
        view.backgroundColor = .systemBackground

        // Create container view for calendar
        calendarContainerView = UIView()
        calendarContainerView.translatesAutoresizingMaskIntoConstraints = false
        calendarContainerView.backgroundColor = .systemBackground
        
        // Create table view
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.backgroundColor = .systemBackground
        tableView.tableHeaderView = UIView()
        
        // Add subviews
        view.addSubview(calendarContainerView)
        view.addSubview(tableView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            calendarContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            calendarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            calendarContainerView.heightAnchor.constraint(equalToConstant: 300),
            
            tableView.topAnchor.constraint(equalTo: calendarContainerView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // MARK: - Create and add Calendar View to view hierarchy
        self.calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarContainerView.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            calendarView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
            calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor)
        ])

        // MARK: - Setup the Calendar View
        calendarView.delegate = self
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection

        // Register table view cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")

        // MARK: - Set initial calendar selection
        habits = Habit.getHabits()
        let todayComponents = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day], from: Date())
        let todayHabits = filterHabits(for: todayComponents)
        if !todayHabits.isEmpty {
            let selection = calendarView.selectionBehavior as? UICalendarSelectionSingleDate
            selection?.setSelected(todayComponents, animated: false)
        }
    }

    // Refresh habits anytime the view appears in case updates to any habits were made on another tab.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshHabits()
    }

    // MARK: - Helper Functions

    // A helper method to filter an array of habits down to only the habits which have completion dates that match the given date components.
    private func filterHabits(for dateComponents: DateComponents) -> [Habit] {
        let calendar = Calendar.current
        guard let date = calendar.date(from: dateComponents) else {
            return []
        }
        
        let habitsMatchingDate = habits.filter { habit in
            return habit.wasCompletedOn(date: date)
        }
        
        return habitsMatchingDate
    }

    // Refresh the main habits and update the calendar view and table view.
    private func refreshHabits() {
        habits = Habit.getHabits()
        habits.sort { lhs, rhs in
            if lhs.isCompletedToday() && rhs.isCompletedToday() {
                return lhs.createdDate < rhs.createdDate
            } else if !lhs.isCompletedToday() && !rhs.isCompletedToday() {
                return lhs.createdDate < rhs.createdDate
            } else {
                return !lhs.isCompletedToday() && rhs.isCompletedToday()
            }
        }
        
        if let selection = calendarView.selectionBehavior as? UICalendarSelectionSingleDate,
            let selectedComponents = selection.selectedDate {
            selectedHabits = filterHabits(for: selectedComponents)
        }
        
        let habitCompletionDates = habits.flatMap { $0.getCompletionDates() }
        var habitDueDateComponents = habitCompletionDates.map { completionDate in
            Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day], from: completionDate)
        }
        habitDueDateComponents.removeDuplicates()
        calendarView.reloadDecorations(forDateComponents: habitDueDateComponents, animated: false)
        tableView.reloadData()
    }
    
    // Handle habit completion toggle
    @objc func toggleHabit(_ sender: UIButton) {
        var habit = selectedHabits[sender.tag]
        habit.toggleCompletionForToday()
        habit.save()
        refreshHabits()
    }
}

// MARK: - Calendar Delegate Methods
extension CalendarViewController: UICalendarViewDelegate {

    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let habitsMatchingDate = filterHabits(for: dateComponents)
        
        if !habitsMatchingDate.isEmpty {
            let image = UIImage(systemName: "checkmark.circle.fill")
            return .image(image, color: .systemGreen, size: .large)
        } else {
            return nil
        }
    }
}

// MARK: - Calendar Selection Delegate Methods
extension CalendarViewController: UICalendarSelectionSingleDateDelegate {

    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let components = dateComponents else { return }
        selectedHabits = filterHabits(for: components)
        if selectedHabits.isEmpty {
            selection.setSelected(nil, animated: true)
        }
        tableView.reloadData()
    }
}

// MARK: - Table View Datasource Methods
extension CalendarViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedHabits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let habit = selectedHabits[indexPath.row]
        
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
}

extension Array where Element: Equatable, Element: Hashable {
    mutating func removeDuplicates() {
        let set = Set(self)
        self = Array(set)
    }
}
