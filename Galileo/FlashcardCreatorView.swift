import SwiftUI
import FoundationModels

struct FlashcardCreatorView: View {
    @State private var inputContent = ""
    @State private var cardCount = 8
    @State private var flashcardSet: FlashcardSet?
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var currentCardIndex = 0
    @State private var showBack = false
    @State private var studyMode = false
    
    @StateObject private var educationService = EducationService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !studyMode {
                    flashcardSetupView
                } else {
                    flashcardStudyView
                }
            }
            .padding()
            .navigationTitle("Flashcard Creator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if flashcardSet != nil && !studyMode {
                        Button("Study") {
                            startStudyMode()
                        }
                    } else if studyMode {
                        Button("Exit Study") {
                            exitStudyMode()
                        }
                    }
                }
            }
        }
    }
    
    private var flashcardSetupView: some View {
        VStack(alignment: .leading, spacing: 20) {
            if flashcardSet == nil {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Create Flashcards")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter your study material:")
                        .font(.headline)
                    
                    TextEditor(text: $inputContent)
                        .frame(minHeight: 150)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Number of Cards:")
                            .font(.headline)
                        Picker("Card Count", selection: $cardCount) {
                            ForEach([5, 8, 10, 12, 15], id: \.self) { count in
                                Text("\(count) cards").tag(count)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    if isLoading {
                        HStack {
                            ProgressView()
                            Text("Creating flashcards...")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Button("Create Flashcards") {
                            createFlashcards()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(inputContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            } else {
                flashcardSetOverview
            }
            
            Spacer()
        }
    }
    
    private var flashcardSetOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let set = flashcardSet {
                Text(set.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(set.subject)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                
                Text("\(set.cards.count) flashcards created")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(set.cards.enumerated()), id: \.offset) { index, card in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Card \(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text(card.category)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.orange.opacity(0.2))
                                        .cornerRadius(6)
                                }
                                
                                Text("Front:")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                Text(card.front)
                                    .font(.footnote)
                                
                                Text("Back:")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                Text(card.back)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                }
                
                HStack {
                    Button("Create New Set") {
                        resetFlashcards()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Start Studying") {
                        startStudyMode()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    private var flashcardStudyView: some View {
        VStack(spacing: 20) {
            if let set = flashcardSet {
                HStack {
                    Text("\(currentCardIndex + 1) / \(set.cards.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(set.cards[currentCardIndex].category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(6)
                }
                
                ProgressView(value: Double(currentCardIndex + 1), total: Double(set.cards.count))
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showBack.toggle()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(showBack ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            .frame(height: 250)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(showBack ? Color.blue : Color.gray, lineWidth: 2)
                            )
                        
                        VStack(spacing: 16) {
                            Text(showBack ? "Back" : "Front")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            Text(showBack ? set.cards[currentCardIndex].back : set.cards[currentCardIndex].front)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            if !showBack {
                                Text("Tap to reveal answer")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        previousCard()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                    }
                    .buttonStyle(.bordered)
                    .disabled(currentCardIndex == 0)
                    
                    Spacer()
                    
                    Button(action: {
                        nextCard()
                    }) {
                        HStack {
                            Text(currentCardIndex == set.cards.count - 1 ? "Restart" : "Next")
                            if currentCardIndex < set.cards.count - 1 {
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
    
    private func createFlashcards() {
        let content = inputContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let result = try await educationService.createFlashcards(content: content, cardCount: cardCount)
                await MainActor.run {
                    flashcardSet = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to create flashcards: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func startStudyMode() {
        studyMode = true
        currentCardIndex = 0
        showBack = false
    }
    
    private func exitStudyMode() {
        studyMode = false
        currentCardIndex = 0
        showBack = false
    }
    
    private func nextCard() {
        showBack = false
        if let set = flashcardSet {
            if currentCardIndex < set.cards.count - 1 {
                currentCardIndex += 1
            } else {
                currentCardIndex = 0 // Restart from beginning
            }
        }
    }
    
    private func previousCard() {
        showBack = false
        if currentCardIndex > 0 {
            currentCardIndex -= 1
        }
    }
    
    private func resetFlashcards() {
        flashcardSet = nil
        inputContent = ""
        errorMessage = ""
        studyMode = false
        currentCardIndex = 0
        showBack = false
    }
}

#Preview {
    FlashcardCreatorView()
}