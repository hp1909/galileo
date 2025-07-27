import SwiftUI
import FoundationModels

struct NoteSummarizerView: View {
    @State private var inputText = ""
    @State private var studyNotes: StudyNotes?
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    @StateObject private var educationService = EducationService()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Summarize Your Study Material")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Paste your notes, articles, or study material below:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $inputText)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    if inputText.isEmpty {
                        Text("Enter text to summarize...")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    } else {
                        Text("\(inputText.count) characters")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    
                    Button("Summarize Notes") {
                        summarizeNotes()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                
                if isLoading {
                    HStack {
                        ProgressView()
                        Text("Analyzing and summarizing...")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                if let notes = studyNotes {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(notes.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Summary")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                Text(notes.summary)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Key Points")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                LazyVStack(alignment: .leading, spacing: 8) {
                                    ForEach(Array(notes.keyPoints.enumerated()), id: \.offset) { index, point in
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("\(index + 1).")
                                                .fontWeight(.bold)
                                                .foregroundColor(.green)
                                            Text(point)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .padding()
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Important Concepts")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                                    ForEach(notes.importantConcepts, id: \.self) { concept in
                                        Text(concept)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.purple.opacity(0.2))
                                            .cornerRadius(12)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                        }
                    }
                }
                
                if studyNotes == nil && !isLoading {
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Study Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if studyNotes != nil {
                        Button("Clear") {
                            clearNotes()
                        }
                    }
                }
            }
        }
    }
    
    private func summarizeNotes() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let result = try await educationService.summarizeNotes(text: text)
                await MainActor.run {
                    studyNotes = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to summarize notes: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func clearNotes() {
        studyNotes = nil
        inputText = ""
        errorMessage = ""
    }
}

#Preview {
    NoteSummarizerView()
}