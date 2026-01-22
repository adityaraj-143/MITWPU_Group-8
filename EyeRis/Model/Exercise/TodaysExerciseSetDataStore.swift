import UIKit
import UIKit

final class TodaysExerciseDataStore {

    var todaysExerciseItems: [TodaysExerciseItem] = []

    init() {
        loadTodaysExercises()
    }

    private func loadTodaysExercises() {
        todaysExerciseItems = [
            TodaysExerciseItem(
                id: 1,
                name: "Figure-8",
                icon: "figure_8_icon",
                instruction: "Follow the moving dot in a smooth figure-8 pattern.",
                bgColor: UIColor(hex: "D3F2E8"),
                iconBGColor: UIColor(hex: "5BC8A8")
            ),
            TodaysExerciseItem(
                id: 2,
                name: "Guided Blinking",
                icon: "blink_icon",
                instruction: "Blink your eyes gently following the on-screen rhythm.",
                bgColor: UIColor(hex: "E9E0F8"),
                iconBGColor: UIColor(hex: "A68BEB")
            ),
            TodaysExerciseItem(
                id: 3,
                name: "Near-Far Focus",
                icon: "focus_icon",
                instruction: "Shift focus between near and far objects calmly.",
                bgColor: UIColor(hex: "F8D7DC"),
                iconBGColor: UIColor(hex: "E66A7A")
            ),
            TodaysExerciseItem(
                id: 4,
                name: "Smooth Pursuit",
                icon: "eye_exercise_icon",
                instruction: "Track the moving object smoothly without jerks.",
                bgColor: UIColor(hex: "FFECC2"),
                iconBGColor: UIColor(hex: "F5B942")
            )
        ]
    }
}
