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

        // Changed to UICalendarSelectionMultiDate
        uiCalendarView.selectionBehavior =
            UICalendarSelectionMultiDate(delegate: self)

        uiCalendarView.delegate = self

        uiCalendarView.transform =
            CGAffineTransform(scaleX: 0.92, y: 0.92)

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
                            didSelectDate dateComponents: DateComponents) {
        guard let date = calendar.date(from: dateComponents) else { return }
        onDateSelected?(date)
        dismiss(animated: true)
    }
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate,
                            didDeselectDate dateComponents: DateComponents) {
        // Optional - handle deselection if needed
    }
}

//    // MARK: - Highlighting
//    extension ExerciseHistoryCalendarViewController: UICalendarViewDelegate {
//
//        func calendarView(_ calendarView: UICalendarView,
//                          decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
//
//            guard let date = calendar.date(from: dateComponents) else { return nil }
//
//            guard performedDates.contains(where: {
//                calendar.isDate($0, inSameDayAs: date)
//            }) else {
//                return nil
//            }
//
//            // Create a custom circular image
//            let size: CGFloat = 32
//            let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
//            let image = renderer.image { ctx in
//                UIColor.systemBlue.withAlphaComponent(0.25).setFill()
//                ctx.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))
//            }
//
//            return .image(image)
//        }
//
//
//    }
//
//// MARK: - Selection Handling
//extension ExerciseHistoryCalendarViewController: UICalendarSelectionSingleDateDelegate {
//
//    func dateSelection(_ selection: UICalendarSelectionSingleDate,
//                       didSelectDate dateComponents: DateComponents?) {
//
//        guard let dateComponents,
//              let date = calendar.date(from: dateComponents) else { return }
//
//        onDateSelected?(date)
//        dismiss(animated: true)
//    }
//}

