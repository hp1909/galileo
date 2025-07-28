import Foundation
import FoundationModels
import Combine

@Generable
struct Quiz {
    let title: String
    let subject: String
    let questions: [Question]
}

@Generable
struct Question {
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
}

@Generable
struct FlashcardSet {
    let title: String
    let subject: String
    let cards: [Flashcard]
}

@Generable
struct Flashcard {
    let front: String
    let back: String
    let category: String
}

@Generable
struct StudyNotes {
    let title: String
    let keyPoints: [String]
    let summary: String
    let importantConcepts: [String]
}

@Generable
struct ConceptExplanation {
    let concept: String
    let simpleExplanation: String
    let keyTerms: [String]
    let realWorldExample: String
    let difficultLevel: String
}

@MainActor
class EducationService: ObservableObject {
    private let session: LanguageModelSession

    init() {
        let instructions = Instructions("""
        You are Galileo, a brilliant educator and scientist. Your role is to make complex concepts accessible and engaging for students.
        Always provide clear, accurate, and educational content.
        When creating structured responses, follow the exact format requested.
        Be encouraging and supportive in your explanations.
        """)
        
        self.session = LanguageModelSession(instructions: instructions)
        
        // Prewarm the session for better performance
        Task {
            await session.prewarm()
        }
    }
    
    func explainConcept(topic: String) async throws -> ConceptExplanation {
        let response = try await session.respond(
            to: """
            Explain the scientific concept "\(topic)" in simple terms suitable for students. 
            Provide key terms, a real-world example, and rate the difficulty level (Beginner/Intermediate/Advanced).
            Focus on making complex ideas accessible and engaging.
            """,
            generating: ConceptExplanation.self
        )
        
        return response.content
    }
    
    func generateQuiz(topic: String, questionCount: Int = 5) async throws -> Quiz {
        let response = try await session.respond(
            to: """
            Create a \(questionCount)-question multiple choice quiz about "\(topic)".
            Each question should have exactly 4 options with one correct answer (index 0-3).
            Include educational explanations for the correct answers.
            Make questions appropriately challenging but fair.
            """,
            generating: Quiz.self
        )
        
        return response.content
    }
    
    func createFlashcards(content: String, cardCount: Int = 10) async throws -> FlashcardSet {
        let response = try await session.respond(
            to: """
            Create \(cardCount) flashcards from this content: "\(content)"
            Each flashcard should have a clear question/term on the front and a concise answer/definition on the back.
            Organize cards by logical categories and focus on the most important concepts.
            """,
            generating: FlashcardSet.self
        )
        
        return response.content
    }
    
    func summarizeNotes(text: String) async throws -> StudyNotes {
        let response = try await session.respond(
            to: """
            Summarize this study material into key points: "\(text)"
            Extract the most important concepts and create a concise summary.
            Organize information in a student-friendly format with clear key points and important concepts.
            """,
            generating: StudyNotes.self
        )
        
        return response.content
    }
}
