final class TodaysExerciseDataStore {

    // MARK: - Singleton
    static let shared = TodaysExerciseDataStore()
    private init() {}

    // MARK: - Stored Data
    private(set) var todaysExerciseItems: [TodaysExerciseItem] = []

    // MARK: - Load Today's Exercises

    func loadTodaysExercises() {
        let exercises = ExerciseFetcher.getTodaysExercises()

        todaysExerciseItems = exercises.map { exercise in
            TodaysExerciseItem(
                id: exercise.id,
                name: exercise.name,
                icon: iconName(for: exercise),
                instruction: instructionText(for: exercise)
            )
        }
    }

    // MARK: - Helpers (TEMP LOGIC)

    private func iconName(for exercise: Exercise) -> String {
        // Temporary mapping — replace later
        switch exercise.name {
        case "Figure-8":
            return "figure_8_icon"
        case "Guided Blinking":
            return "blink_icon"
        case "Near-Far Focus":
            return "focus_icon"
        default:
            return "eye_exercise_icon"
        }
    }

    private func instructionText(for exercise: Exercise) -> String {
        // One-line logical direction shown under icon
        return "Follow the on-screen instructions and complete the exercise calmly."
    }
}
