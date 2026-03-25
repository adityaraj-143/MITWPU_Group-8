//
//  ChatbotDataStore.swift
//  EyeRis
//
//  Created by SDC-USER on 16/12/25.
//

import Foundation

// MARK: - FAQ Categories Data

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

