//
//  ExerciseHistoryCalendarViewController.swift
//  EyeRis
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit

class ExerciseHistoryCalendarViewController: UIViewController {

    @IBOutlet weak var calendarView: UIView!
    
    var onDateSelected: ((Date) -> Void)?


    private let uiCalendarView = UICalendarView()
        private let calendar = Calendar.current

        private let exerciseHistory = ExerciseHistory()
        private var performedDates: Set<Date> = []

        override func viewDidLoad() {
            super.viewDidLoad()
            setupCalendar()
            loadPerformedDates()
            selectPerformedDates()
        }

        private func setupCalendar() {
            uiCalendarView.calendar = .current
            uiCalendarView.locale = .current
            uiCalendarView.translatesAutoresizingMaskIntoConstraints = false

            let selection = UICalendarSelectionMultiDate(delegate: self)
            uiCalendarView.selectionBehavior = selection
            uiCalendarView.delegate = self

            calendarView.addSubview(uiCalendarView)

            NSLayoutConstraint.activate([
                uiCalendarView.topAnchor.constraint(equalTo: calendarView.topAnchor),
                uiCalendarView.bottomAnchor.constraint(equalTo: calendarView.bottomAnchor),
                uiCalendarView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor),
                uiCalendarView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor)
            ])
            
        }

        private func loadPerformedDates() {
            performedDates = exerciseHistory.performedExerciseDates()
        }

        private func selectPerformedDates() {
            guard let selection = uiCalendarView.selectionBehavior as? UICalendarSelectionMultiDate else { return }

            let components = performedDates.map {
                calendar.dateComponents([.year, .month, .day], from: $0)
            }

            // Correct API
            selection.setSelectedDates(components, animated: false)
        }

        @IBAction func clossButtonTapped(_ sender: Any) {
            dismiss(animated: true)
        }
    }

    // MARK: - Highlighting
    extension ExerciseHistoryCalendarViewController: UICalendarViewDelegate {

        func calendarView(_ calendarView: UICalendarView,
                          decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {

            guard let date = calendar.date(from: dateComponents) else { return nil }

            if performedDates.contains(where: {
                calendar.isDate($0, inSameDayAs: date)
            }) {
                return .default(color: .systemBlue, size: .large)
            }

            return nil
        }
    }

// MARK: - Selection Handling
extension ExerciseHistoryCalendarViewController: UICalendarSelectionMultiDateDelegate {

    func multiDateSelection(_ selection: UICalendarSelectionMultiDate,
                            didDeselectDate dateComponents: DateComponents) {

        guard let date = calendar.date(from: dateComponents) else { return }
        onDateSelected?(date)
        dismiss(animated: true)
    }

    func multiDateSelection(_ selection: UICalendarSelectionMultiDate,
                            didSelectDate dateComponents: DateComponents) {
        // optional
    }
}

