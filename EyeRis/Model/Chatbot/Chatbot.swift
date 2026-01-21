//
//  Chatbot.swift
//  EyeRis
//
//  Created by SDC-USER on 16/12/25.
//

import Foundation


enum Role {
    case user
    case bot
}

struct Message {
    var role: Role
    var text: String
    var time: Date
    var isBookmarked: Bool
}

// MARK: - Models

struct FAQCategory: Identifiable, Codable {
    let id: UUID
    let title: String
    let imageURL: String
    private let questions: [FAQQuestion]

    init(
        id: UUID = UUID(),
        title: String,
        imageURL: String,
        questions: [FAQQuestion]
    ) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.questions = questions
    }

    /// Returns exactly ONE random question from this category
    func getRandomQuestion() -> FAQQuestion? {
        questions.randomElement()
    }
}

struct FAQQuestion: Identifiable, Codable {
    let id: UUID
    let text: String

    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}

struct FAQResponse {

    private let categories: [FAQCategory]

    init(categories: [FAQCategory] = faqCategories) {
        self.categories = categories
    }

    /// One question per category → no repeated types, no repeated icons
    func getQuickFAQs() -> [(category: FAQCategory, question: FAQQuestion)] {
        categories.compactMap { category in
            guard let question = category.getRandomQuestion() else { return nil }
            return (category, question)
        }
    }
}
