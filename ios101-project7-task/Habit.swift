//
//  Habit.swift
//

import UIKit

// The Habit model
struct Habit: Codable {

    // The habit's name
    var name: String

    // An optional description
    var description: String?

    // Target frequency per week (1-7 days)
    var targetFrequency: Int

    // The date the habit was created
    private(set) var createdDate: Date = Date()

    // Current streak count
    private(set) var currentStreak: Int = 0

    // An id (Universal Unique Identifier) used to identify a habit
    private(set) var id: String = UUID().uuidString

    // Track completion dates for streak calculation
    private var completionDates: [String] = [] // Store as date strings for easier comparison

    // Initialize a new habit
    init(name: String, description: String? = nil, targetFrequency: Int = 7) {
        self.name = name
        self.description = description
        self.targetFrequency = targetFrequency
        self.currentStreak = 0
        self.completionDates = []
    }

    // Check if habit is completed today
    func isCompletedToday() -> Bool {
        let todayString = dateToString(Date())
        return completionDates.contains(todayString)
    }

    // Mark habit as completed for today
    mutating func markCompletedForToday() {
        let todayString = dateToString(Date())
        if !completionDates.contains(todayString) {
            completionDates.append(todayString)
            completionDates.sort { $0 > $1 } // Most recent first
            updateStreak()
        }
    }

    // Mark habit as not completed for today
    mutating func markNotCompletedForToday() {
        let todayString = dateToString(Date())
        if let index = completionDates.firstIndex(of: todayString) {
            completionDates.remove(at: index)
            updateStreak()
        }
    }

    // Toggle completion for today
    mutating func toggleCompletionForToday() {
        if isCompletedToday() {
            markNotCompletedForToday()
        } else {
            markCompletedForToday()
        }
    }

    // Calculate and update streak
    private mutating func updateStreak() {
        currentStreak = calculateCurrentStreak()
    }

    // Calculate current streak based on completion dates
    private func calculateCurrentStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        
        // Sort completion dates (most recent first)
        let sortedDates = completionDates.compactMap { stringToDate($0) }.sorted { $0 > $1 }
        
        // Check if today or yesterday was completed (allow for streak continuation)
        guard let mostRecentCompletion = sortedDates.first else { return 0 }
        
        let daysSinceLastCompletion = calendar.dateComponents([.day], from: mostRecentCompletion, to: today).day ?? 0
        
        // If more than 1 day gap, streak is broken
        if daysSinceLastCompletion > 1 { return 0 }
        
        // Calculate consecutive days
        for i in 0..<sortedDates.count {
            let completionDate = calendar.startOfDay(for: sortedDates[i])
            let expectedDate = calendar.date(byAdding: .day, value: -i, to: today)!
            
            if calendar.isDate(completionDate, inSameDayAs: expectedDate) {
                streak += 1
            } else {
                break
            }
        }
        
        return streak
    }

    // Helper function to convert Date to String
    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // Helper function to convert String to Date
    private func stringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }

    // Get completion dates as Date objects for calendar display
    func getCompletionDates() -> [Date] {
        return completionDates.compactMap { stringToDate($0) }
    }

    // Check if habit was completed on a specific date
    func wasCompletedOn(date: Date) -> Bool {
        let dateString = dateToString(date)
        return completionDates.contains(dateString)
    }
}

// MARK: - Habit + UserDefaults
extension Habit {
    
    // The key used to store habits in UserDefaults
    private static let habitsKey = "SavedHabits"

    // Given an array of habits, encodes them to data and saves to UserDefaults.
    static func save(_ habits: [Habit]) {
        do {
            let encoder = JSONEncoder()
            let habitsData = try encoder.encode(habits)
            UserDefaults.standard.set(habitsData, forKey: habitsKey)
        } catch {
            print("Failed to save habits: \(error)")
        }
    }

    // Retrieve an array of saved habits from UserDefaults.
    static func getHabits() -> [Habit] {
        guard let habitsData = UserDefaults.standard.data(forKey: habitsKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let habits = try decoder.decode([Habit].self, from: habitsData)
            return habits
        } catch {
            print("Failed to load habits: \(error)")
            return []
        }
    }

    // Add a new habit or update an existing habit
    func save() {
        var habits = Habit.getHabits()
        
        if let existingIndex = habits.firstIndex(where: { $0.id == self.id }) {
            habits[existingIndex] = self
        } else {
            habits.append(self)
        }
        
        Habit.save(habits)
    }
}
