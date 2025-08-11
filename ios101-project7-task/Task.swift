//
//  Task.swift
//

import UIKit

// The Task model
struct Task: Codable {

    // The task's title
    var title: String

    // An optional note
    var note: String?

    // The due date by which the task should be completed
    var dueDate: Date

    // Initialize a new task
    // `note` and `dueDate` properties have default values provided if none are passed into the init by the caller.
    init(title: String, note: String? = nil, dueDate: Date = Date()) {
        self.title = title
        self.note = note
        self.dueDate = dueDate
    }

    // A boolean to determine if the task has been completed. Defaults to `false`
    var isComplete: Bool = false {

        // Any time a task is completed, update the completedDate accordingly.
        didSet {
            if isComplete {
                // The task has just been marked complete, set the completed date to "right now".
                completedDate = Date()
            } else {
                completedDate = nil
            }
        }
    }

    // The date the task was completed
    // private(set) means this property can only be set from within this struct, but read from anywhere (i.e. public)
    private(set) var completedDate: Date?

    // The date the task was created
    // This property is set as the current date whenever the task is initially created.
    private(set) var createdDate: Date = Date()

    // An id (Universal Unique Identifier) used to identify a task.
    private(set) var id: String = UUID().uuidString
}

// MARK: - Task + UserDefaults
extension Task {
    
    // The key used to store tasks in UserDefaults
    private static let tasksKey = "SavedTasks"

    // Given an array of tasks, encodes them to data and saves to UserDefaults.
    static func save(_ tasks: [Task]) {
        do {
            // 1. Encode the array of tasks to data using JSONEncoder
            let encoder = JSONEncoder()
            let tasksData = try encoder.encode(tasks)
            
            // 2. Save the encoded tasks data to UserDefaults with a key
            UserDefaults.standard.set(tasksData, forKey: tasksKey)
        } catch {
            print("Failed to save tasks: \(error)")
        }
    }

    // Retrieve an array of saved tasks from UserDefaults.
    static func getTasks() -> [Task] {
        // 1. Get the saved task data for the key used to store tasks
        guard let tasksData = UserDefaults.standard.data(forKey: tasksKey) else {
            return [] // Return empty array if no data found
        }
        
        do {
            // 2. Decode the tasks data into an array of Task objects using JSONDecoder
            let decoder = JSONDecoder()
            let tasks = try decoder.decode([Task].self, from: tasksData)
            return tasks
        } catch {
            print("Failed to load tasks: \(error)")
            return [] // Return empty array if decoding fails
        }
    }

    // Add a new task or update an existing task with the current task.
    func save() {
        // 1. Get the array of saved tasks using the getTasks() method
        var tasks = Task.getTasks()
        
        // 2. Check if the current task (self) already exists in the tasks array
        if let existingIndex = tasks.firstIndex(where: { $0.id == self.id }) {
            // If it does, update the existing task...
            
            // Remove the existing task from the array
            tasks.remove(at: existingIndex)
            
            // Insert the updated task in place of the task you removed
            tasks.insert(self, at: existingIndex)
        } else {
            // 3. Otherwise, if no matching task already exists, add the new task to the end of the array
            tasks.append(self)
        }
        
        // 4. Save the updated tasks array to UserDefaults using the save(_ tasks: [Task]) method
        Task.save(tasks)
    }
}
