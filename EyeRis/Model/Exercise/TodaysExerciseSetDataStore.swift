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
                instruction: "Follow the moving dot in a smooth figure-8 pattern."
            ),
            TodaysExerciseItem(
                id: 2,
                name: "Guided Blinking",
                icon: "blink_icon",
                instruction: "Blink your eyes gently following the on-screen rhythm."
            ),
            TodaysExerciseItem(
                id: 3,
                name: "Near-Far Focus",
                icon: "focus_icon",
                instruction: "Shift focus between near and far objects calmly."
            ),
            TodaysExerciseItem(
                id: 4,
                name: "Smooth Pursuit",
                icon: "eye_exercise_icon",
                instruction: "Track the moving object smoothly without jerks."
            )
        ]
    }
}
