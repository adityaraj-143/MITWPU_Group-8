//
//  ChatbotDataStore.swift
//  EyeRis
//
//  Created by SDC-USER on 16/12/25.
//

import Foundation

struct ChatbotDataStore {

    static let calendar = Calendar.current

    static func makeTime(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int
    ) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? Date()
    }

    static let dummyMessages: [Message] = [

        Message(
            role: Role.bot,
            text: "Hi! 👋 I’m your eye-health assistant. How can I help you today?",
            time: makeTime(year: 2025, month: 5, day: 8, hour: 10, minute: 0),
            isBookmarked: false
        ),

        Message(
            role: Role.user,
            text: "I want to check my near vision.",
            time: makeTime(year: 2025, month: 5, day: 8, hour: 10, minute: 1),
            isBookmarked: false
        ),

        Message(
            role: Role.bot,
            text: "Sure! Before we start, make sure your phone is about 40 cm away from your eyes.",
            time: makeTime(year: 2025, month: 5, day: 8, hour: 10, minute: 1),
            isBookmarked: true
        ),

        Message(
            role: Role.bot,
            text: "Please cover your right eye. Let me know when you’re ready.",
            time: makeTime(year: 2025, month: 5, day: 8, hour: 10, minute: 2),
            isBookmarked: false
        ),

        Message(
            role: Role.user,
            text: "Okay, ready.",
            time: makeTime(year: 2025, month: 5, day: 8, hour: 10, minute: 2),
            isBookmarked: false
        ),

        Message(
            role: Role.bot,
            text: "Great! Read out the letters you see on the screen.",
            time: makeTime(year: 2025, month: 5, day: 8, hour: 10, minute: 3),
            isBookmarked: false
        )
    ]
}

let faqCategories: [FAQCategory] = [

    FAQCategory(
        title: "Eye Health Basics",
        imageURL: "https://yourcdn.com/icons/eye-health.png",
        questions: [
            FAQQuestion(text: "Why do my eyes feel tired so often?"),
            FAQQuestion(text: "How many hours of screen time is safe?"),
            FAQQuestion(text: "What causes dry eyes?"),
            FAQQuestion(text: "How often should I blink while using a screen?"),
            FAQQuestion(text: "When should I get an eye check-up?")
        ]
    ),

    FAQCategory(
        title: "Eye Exercises",
        imageURL: "https://yourcdn.com/icons/exercises.png",
        questions: [
            FAQQuestion(text: "Which exercise helps reduce eye strain?"),
            FAQQuestion(text: "How long should I do eye exercises daily?"),
            FAQQuestion(text: "Do eye exercises really improve vision?"),
            FAQQuestion(text: "What is the 20-20-20 rule?"),
            FAQQuestion(text: "Which exercise is best for focus improvement?")
        ]
    ),

    FAQCategory(
        title: "Screen & Digital Care",
        imageURL: "https://yourcdn.com/icons/screen-care.png",
        questions: [
            FAQQuestion(text: "How can I protect my eyes from blue light?"),
            FAQQuestion(text: "Should I use dark mode or light mode?"),
            FAQQuestion(text: "What brightness level is best for my screen?"),
            FAQQuestion(text: "Is night mode good for eye health?"),
            FAQQuestion(text: "How far should my screen be from my eyes?")
        ]
    ),

    FAQCategory(
        title: "Eye Tests & Vision",
        imageURL: "https://yourcdn.com/icons/eye-test.png",
        questions: [
            FAQQuestion(text: "How do I know if my vision is getting worse?"),
            FAQQuestion(text: "What does blurry vision indicate?"),
            FAQQuestion(text: "How accurate are app-based eye tests?"),
            FAQQuestion(text: "What is color blindness?"),
            FAQQuestion(text: "What does eye strain feel like?")
        ]
    ),

    FAQCategory(
        title: "Eye Safety & Habits",
        imageURL: "https://yourcdn.com/icons/eye-safety.png",
        questions: [
            FAQQuestion(text: "How can I prevent eye infections?"),
            FAQQuestion(text: "Is rubbing eyes harmful?"),
            FAQQuestion(text: "What foods improve eye health?"),
            FAQQuestion(text: "How important is sleep for eye health?"),
            FAQQuestion(text: "Can dehydration affect eyesight?")
        ]
    )
]

