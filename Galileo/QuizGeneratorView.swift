import SwiftUI
import FoundationModels

struct QuizGeneratorView: View {
    @State private var inputTopic = ""
    @State private var questionCount = 5
    @State private var quiz: Quiz?
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [Int] = []
    @State private var showResults = false
    
    @StateObject private var educationService = EducationService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if quiz == nil {
                    quizSetupView
                } else if !showResults {
                    quizTakingView
                } else {
                    quizResultsView
                }
            }
            .padding()
            .navigationTitle("Quiz Generator")
        }
    }
    
    private var quizSetupView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create a Quiz")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Topic:")
                    .font(.headline)
                TextField("Enter quiz topic...", text: $inputTopic)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Number of Questions:")
                    .font(.headline)
                Picker("Question Count", selection: $questionCount) {
                    ForEach(3...10, id: \.self) { count in
                        Text("\(count) questions").tag(count)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            if isLoading {
                HStack {
                    ProgressView()
                    Text("Generating quiz...")
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Button("Generate Quiz") {
                    generateQuiz()
                }
                .buttonStyle(.borderedProminent)
                .disabled(inputTopic.isEmpty)
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
        }
    }
    
    private var quizTakingView: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let quiz = quiz {
                HStack {
                    Text("Question \(currentQuestionIndex + 1) of \(quiz.questions.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(quiz.subject)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                
                ProgressView(value: Double(currentQuestionIndex + 1), total: Double(quiz.questions.count))
                
                let currentQuestion = quiz.questions[currentQuestionIndex]
                
                Text(currentQuestion.question)
                    .font(.headline)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(spacing: 12) {
                    ForEach(0..<currentQuestion.options.count, id: \.self) { optionIndex in
                        Button(action: {
                            selectAnswer(optionIndex)
                        }) {
                            HStack {
                                Text(currentQuestion.options[optionIndex])
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedAnswers.count > currentQuestionIndex && selectedAnswers[currentQuestionIndex] == optionIndex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(
                                selectedAnswers.count > currentQuestionIndex && selectedAnswers[currentQuestionIndex] == optionIndex 
                                ? Color.blue.opacity(0.2) 
                                : Color.gray.opacity(0.1)
                            )
                            .cornerRadius(8)
                        }
                    }
                }
                
                HStack {
                    if currentQuestionIndex > 0 {
                        Button("Previous") {
                            currentQuestionIndex -= 1
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    if currentQuestionIndex < quiz.questions.count - 1 {
                        Button("Next") {
                            currentQuestionIndex += 1
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedAnswers.count <= currentQuestionIndex)
                    } else {
                        Button("Finish Quiz") {
                            showResults = true
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedAnswers.count <= currentQuestionIndex)
                    }
                }
            }
        }
    }
    
    private var quizResultsView: some View {
        VStack(spacing: 20) {
            if let quiz = quiz {
                Text("Quiz Results")
                    .font(.title)
                    .fontWeight(.bold)
                
                let correctCount = calculateScore()
                let percentage = Double(correctCount) / Double(quiz.questions.count) * 100
                
                VStack(spacing: 8) {
                    Text("\(correctCount)/\(quiz.questions.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(Int(percentage))% Correct")
                        .font(.headline)
                        .foregroundColor(percentage >= 70 ? .green : percentage >= 50 ? .orange : .red)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(0..<quiz.questions.count, id: \.self) { index in
                            let question = quiz.questions[index]
                            let userAnswer = selectedAnswers[index]
                            let isCorrect = userAnswer == question.correctAnswer
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Q\(index + 1)")
                                        .fontWeight(.bold)
                                    Spacer()
                                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(isCorrect ? .green : .red)
                                }
                                
                                Text(question.question)
                                    .font(.headline)
                                
                                Text("Your answer: \(question.options[userAnswer])")
                                    .foregroundColor(isCorrect ? .green : .red)
                                
                                if !isCorrect {
                                    Text("Correct answer: \(question.options[question.correctAnswer])")
                                        .foregroundColor(.green)
                                }
                                
                                Text(question.explanation)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Button("Create New Quiz") {
                    resetQuiz()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private func generateQuiz() {
        guard !inputTopic.isEmpty else { return }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let result = try await educationService.generateQuiz(topic: inputTopic, questionCount: questionCount)
                await MainActor.run {
                    quiz = result
                    selectedAnswers = []
                    currentQuestionIndex = 0
                    showResults = false
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to generate quiz: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func selectAnswer(_ answerIndex: Int) {
        while selectedAnswers.count <= currentQuestionIndex {
            selectedAnswers.append(-1)
        }
        selectedAnswers[currentQuestionIndex] = answerIndex
    }
    
    private func calculateScore() -> Int {
        guard let quiz = quiz else { return 0 }
        
        var correct = 0
        for (index, question) in quiz.questions.enumerated() {
            if index < selectedAnswers.count && selectedAnswers[index] == question.correctAnswer {
                correct += 1
            }
        }
        return correct
    }
    
    private func resetQuiz() {
        quiz = nil
        selectedAnswers = []
        currentQuestionIndex = 0
        showResults = false
        inputTopic = ""
        errorMessage = ""
    }
}

#Preview {
    QuizGeneratorView()
}