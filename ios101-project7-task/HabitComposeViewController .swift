//
//  HabitComposeViewController.swift
//

import UIKit

class HabitComposeViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var noteField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!

    // The optional habit to edit.
    var habitToEdit: Habit?

    // When a new habit is created (or an existing habit is edited), this closure is called
    var onComposeHabit: ((Habit) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Update placeholder text for habits
        titleField.placeholder = "Habit name (e.g., Drink 8 glasses of water)"
        noteField.placeholder = "Description (optional)"

        // Configure date picker for frequency selection (we'll repurpose this)
        datePicker.isHidden = true // Hide for now, we'll use it for frequency later

        // If a habit was passed in to edit, set all the fields
        if let habit = habitToEdit {
            titleField.text = habit.name
            noteField.text = habit.description
            self.title = "Edit Habit"
        } else {
            self.title = "New Habit"
        }
    }

    // The function called when the "Done" button is tapped.
    @IBAction func didTapDoneButton(_ sender: Any) {
        // Make sure we have a habit name
        guard let name = titleField.text, !name.isEmpty else {
            presentAlert(title: "Oops...", message: "Make sure to add a habit name!")
            return
        }
        
        var habit: Habit
        
        if let editHabit = habitToEdit {
            // Editing existing habit
            habit = editHabit
            habit.name = name
            habit.description = noteField.text?.isEmpty == true ? nil : noteField.text
        } else {
            // Creating new habit
            habit = Habit(
                name: name,
                description: noteField.text?.isEmpty == true ? nil : noteField.text,
                targetFrequency: 7 // Default to daily
            )
        }
        
        // Call the completion closure
        onComposeHabit?(habit)
        
        // Dismiss the view controller
        dismiss(animated: true)
    }

    // The cancel button was tapped.
    @IBAction func didTapCancelButton(_ sender: Any) {
        dismiss(animated: true)
    }

    // A helper method to present an alert given a title and message.
    private func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
