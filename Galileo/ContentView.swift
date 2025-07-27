//
//  ContentView.swift
//  Galileo
//
//  Created by Nguyen Hoang Phuc on 27/7/25.
//

import SwiftUI
import FoundationModels

struct ContentView: View {
    var body: some View {
        TabView {
            ConceptExplainerView()
                .tabItem {
                    Image(systemName: "lightbulb.fill")
                    Text("Explain")
                }
            
            QuizGeneratorView()
                .tabItem {
                    Image(systemName: "questionmark.circle.fill")
                    Text("Quiz")
                }
            
            NoteSummarizerView()
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("Summary")
                }
            
            FlashcardCreatorView()
                .tabItem {
                    Image(systemName: "rectangle.stack.fill")
                    Text("Flashcards")
                }
        }
        .navigationTitle("Galileo Educator")
    }
}

struct ConceptExplainerView: View {
    @State private var inputTopic = ""
    @State private var explanation: ConceptExplanation?
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    @StateObject private var educationService = EducationService()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What would you like to understand?")
                        .font(.headline)
                    
                    TextField("Enter a scientific concept...", text: $inputTopic)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .submitLabel(.done)
                        .onSubmit {
                            explainConcept()
                        }
                    
                    Button("Explain Concept") {
                        explainConcept()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(inputTopic.isEmpty || isLoading)
                }
                
                if isLoading {
                    HStack {
                        ProgressView()
                        Text("Galileo is thinking...")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                if let explanation = explanation {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(explanation.concept)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Simple Explanation:")
                                    .font(.headline)
                                Text(explanation.simpleExplanation)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Key Terms:")
                                    .font(.headline)
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                                    ForEach(explanation.keyTerms, id: \.self) { term in
                                        Text(term)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.green.opacity(0.2))
                                            .cornerRadius(16)
                                            .font(.caption)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Real-World Example:")
                                    .font(.headline)
                                Text(explanation.realWorldExample)
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            HStack {
                                Text("Difficulty Level:")
                                    .font(.headline)
                                Text(explanation.difficultLevel)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.purple.opacity(0.2))
                                    .cornerRadius(8)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Concept Explainer")
        }
    }
    
    private func explainConcept() {
        guard !inputTopic.isEmpty else { return }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let result = try await educationService.explainConcept(topic: inputTopic)
                await MainActor.run {
                    explanation = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to explain concept: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
