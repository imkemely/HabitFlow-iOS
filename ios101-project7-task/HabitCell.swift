//
//  HabitCell.swift
//

import UIKit

// A cell to display a habit
class HabitCell: UITableViewCell {

    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!

    // The closure called, passing in the associated habit, when the "Complete" button is tapped.
    var onCompleteButtonTapped: ((Habit) -> Void)?

    // The habit associated with the cell
    var habit: Habit!

    // The function called when the "Complete" button is tapped.
    @IBAction func didTapCompleteButton(_ sender: UIButton) {
        // Call the closure with the current habit
        onCompleteButtonTapped?(habit)
    }

    // Initial configuration of the habit cell
    func configure(with habit: Habit, onCompleteButtonTapped: ((Habit) -> Void)?) {
        self.habit = habit
        self.onCompleteButtonTapped = onCompleteButtonTapped
        update(with: habit)
    }

    // Update the UI for the given habit
    private func update(with habit: Habit) {
        // Set the title and description
        titleLabel.text = habit.name
        
        // Show description or streak info
        if let description = habit.description, !description.isEmpty {
            noteLabel.text = description
        } else {
            noteLabel.text = habit.currentStreak > 0 ? "\(habit.currentStreak) day streak 🔥" : "No streak yet"
        }
        
        // Always show the note label for habit tracking
        noteLabel.isHidden = false
        
        // Set the text color based on completion status
        let isCompletedToday = habit.isCompletedToday()
        titleLabel.textColor = isCompletedToday ? .secondaryLabel : .label
        noteLabel.textColor = isCompletedToday ? .tertiaryLabel : .secondaryLabel
        
        // Set the "Complete" button's selected state
        completeButton.isSelected = isCompletedToday
        
        // Set the button's tint color
        completeButton.tintColor = isCompletedToday ? .systemGreen : .tertiaryLabel
        
        // Update button image for better visual feedback
        if isCompletedToday {
            completeButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        } else {
            completeButton.setImage(UIImage(systemName: "circle"), for: .normal)
        }
    }

    // Override selection behavior
    override func setSelected(_ selected: Bool, animated: Bool) { }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { }
}
