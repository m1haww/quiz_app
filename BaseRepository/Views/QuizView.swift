import SwiftUI

struct QuizView: View {
    let character: Character
    let dataManager: CharacterDataManager
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showResult = false
    @State private var correctAnswers = 0
    @State private var quizCompleted = false
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var userService = UserService.shared
    
    var currentQuestion: Question {
        character.quiz.questions[currentQuestionIndex]
    }
    
    
    var progress: Double {
        Double(currentQuestionIndex) / Double(character.quiz.questions.count)
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#351162")
                .ignoresSafeArea()
            
            if quizCompleted {
                QuizResultView(
                    characterName: character.name,
                    score: correctAnswers,
                    totalQuestions: character.quiz.questions.count,
                    currentCharacter: character,
                    dataManager: dataManager,
                    onDismiss: {
                        let stars = calculateStars()
                        dataManager.updateCharacterProgress(id: character.id, completed: true, stars: stars)
                        userService.addStars(stars)
                        print("🎯 QuizView: Added \(stars) stars to UserService from quiz completion")
                        dismiss()
                    },
                    onMainScreen: {
                        let stars = calculateStars()
                        dataManager.updateCharacterProgress(id: character.id, completed: true, stars: stars)
                        userService.addStars(stars)
                        print("🎯 QuizView: Added \(stars) stars to UserService from quiz completion (Main Screen)")
                        // Double dismiss to get back to MainTabView
                        dismiss() // Dismiss QuizView
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            // Notification pentru QuizIntroView să se dismiss
                            NotificationCenter.default.post(name: NSNotification.Name("DismissQuizIntro"), object: nil)
                        }
                    }
                )
            } else {
                VStack(spacing: 0) {
                    // Top Header with back button and progress dots
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        // Progress dots
                        HStack(spacing: 8) {
                            ForEach(0..<character.quiz.questions.count, id: \.self) { index in
                                Circle()
                                    .fill(index <= currentQuestionIndex ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Character Image
                    Image(character.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 280, height: 350)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.orange, Color.yellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 4
                                )
                        )
                    
                    Spacer()
                    
                    // Question
                    Text(currentQuestion.question)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Answer Buttons
                    VStack(spacing: 15) {
                        HStack(spacing: 15) {
                            QuizAnswerButton(
                                text: currentQuestion.answers[0],
                                isSelected: selectedAnswer == 0,
                                isCorrect: nil,
                                isWrong: false
                            ) {
                                if !showResult {
                                    selectedAnswer = 0
                                    handleNextQuestion()
                                }
                            }
                            
                            QuizAnswerButton(
                                text: currentQuestion.answers[1],
                                isSelected: selectedAnswer == 1,
                                isCorrect: nil,
                                isWrong: false
                            ) {
                                if !showResult {
                                    selectedAnswer = 1
                                    handleNextQuestion()
                                }
                            }
                        }
                        
                        HStack(spacing: 15) {
                            QuizAnswerButton(
                                text: currentQuestion.answers[2],
                                isSelected: selectedAnswer == 2,
                                isCorrect: nil,
                                isWrong: false
                            ) {
                                if !showResult {
                                    selectedAnswer = 2
                                    handleNextQuestion()
                                }
                            }
                            
                            QuizAnswerButton(
                                text: currentQuestion.answers[3],
                                isSelected: selectedAnswer == 3,
                                isCorrect: nil,
                                isWrong: false
                            ) {
                                if !showResult {
                                    selectedAnswer = 3
                                    handleNextQuestion()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func handleNextQuestion() {
        if !showResult {
            // Check answer and advance after delay
            if let selected = selectedAnswer {
                let isCorrect = selected == currentQuestion.correctAnswer
                if isCorrect {
                    correctAnswers += 1
                    print("✅ QuizView: Correct answer! Total correct: \(correctAnswers)")
                } else {
                    print("❌ QuizView: Wrong answer. Selected: \(selected), Correct: \(currentQuestion.correctAnswer). Total correct: \(correctAnswers)")
                }
            }
            
            // Advance to next question after showing selection
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if currentQuestionIndex < character.quiz.questions.count - 1 {
                    currentQuestionIndex += 1
                    selectedAnswer = nil
                    showResult = false
                    print("➡️ QuizView: Moving to question \(currentQuestionIndex + 1)/\(character.quiz.questions.count)")
                } else {
                    print("🏁 QuizView: Quiz completed! Final score: \(correctAnswers)/\(character.quiz.questions.count)")
                    quizCompleted = true
                }
            }
        }
    }
    
    private func calculateStars() -> Int {
        let percentage = Double(correctAnswers) / Double(character.quiz.questions.count)
        print("📊 QuizView: Quiz stats - Correct answers: \(correctAnswers)/\(character.quiz.questions.count) (\(Int(percentage * 100))%)")
        
        if percentage >= 0.9 {
            print("⭐ QuizView: Awarding 3 stars (90%+ correct)")
            return 3
        } else if percentage >= 0.7 {
            print("⭐ QuizView: Awarding 2 stars (70%+ correct)")
            return 2
        } else {
            // Always give at least 1 star for completing the quiz
            print("⭐ QuizView: Awarding 1 star (quiz completed)")
            return 1
        }
    }
}

struct QuizAnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let isWrong: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if isSelected {
            return Color(hex: "#7328CF")
        } else {
            return .clear
        }
    }
    
    var borderColor: Color {
        return Color.white.opacity(0.5)
    }
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(borderColor, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 25))
        }
        .disabled(isCorrect != nil)
    }
}

struct QuizResultView: View {
    let characterName: String
    let score: Int
    let totalQuestions: Int
    let currentCharacter: Character
    let dataManager: CharacterDataManager
    let onDismiss: () -> Void
    let onMainScreen: (() -> Void)?
    
    @State private var showNextQuiz = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var percentage: Int {
        Int((Double(score) / Double(totalQuestions)) * 100)
    }
    
    var stars: Int {
        let perc = Double(score) / Double(totalQuestions)
        if perc >= 0.8 {
            return 3
        } else if perc >= 0.6 {
            return 2
        } else {
            return 1  // Always give at least 1 star for completing
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#351162")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: horizontalSizeClass == .regular ? 60 : 50) {
                    Spacer()
                        .frame(height: horizontalSizeClass == .regular ? 80 : 60)
                    
                    // Stars display
                    VStack(spacing: horizontalSizeClass == .regular ? 50 : 40) {
                        // Top star - always show at least one star
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "#D29B43"))
                            .font(.system(size: horizontalSizeClass == .regular ? 150 : 120))
                        
                        // Bottom two stars
                        HStack(spacing: horizontalSizeClass == .regular ? 100 : 80) {
                            if stars >= 2 {
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color(hex: "#D29B43"))
                                    .font(.system(size: horizontalSizeClass == .regular ? 125 : 100))
                            } else {
                                Image(systemName: "star")
                                    .foregroundColor(Color.gray.opacity(0.3))
                                    .font(.system(size: horizontalSizeClass == .regular ? 125 : 100))
                            }
                            
                            if stars >= 3 {
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color(hex: "#D29B43"))
                                    .font(.system(size: horizontalSizeClass == .regular ? 125 : 100))
                            } else {
                                Image(systemName: "star")
                                    .foregroundColor(Color.gray.opacity(0.3))
                                    .font(.system(size: horizontalSizeClass == .regular ? 125 : 100))
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: horizontalSizeClass == .regular ? 80 : 60)
                    
                    // Congratulations text
                    Text("Now we sure that you know \(characterName) better than anyone!")
                        .font(.system(
                            size: horizontalSizeClass == .regular ? 28 : 24, 
                            weight: .bold
                        ))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, horizontalSizeClass == .regular ? 60 : 40)
                    
                    Spacer()
                        .frame(height: horizontalSizeClass == .regular ? 80 : 60)
                    
                    // Buttons
                    VStack(spacing: horizontalSizeClass == .regular ? 25 : 20) {
                        Button(action: {
                            if let nextCharacter = getNextCharacter() {
                                showNextQuiz = true
                                print("🔄 QuizResultView: Moving to next quiz for character: \(nextCharacter.name)")
                            } else {
                                // No more characters, go to main screen
                                print("🏁 QuizResultView: No more characters, going to main screen")
                                if let onMainScreen = onMainScreen {
                                    onMainScreen()
                                } else {
                                    onDismiss()
                                }
                            }
                        }) {
                            Text("Next Quiz")
                                .font(.system(
                                    size: horizontalSizeClass == .regular ? 20 : 18, 
                                    weight: .semibold
                                ))
                                .foregroundColor(.white)
                                .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                                .frame(height: horizontalSizeClass == .regular ? 64 : 56)
                                .background(Color(hex: "#D29B43"))
                                .cornerRadius(horizontalSizeClass == .regular ? 32 : 28)
                        }
                        .padding(.horizontal, horizontalSizeClass == .regular ? 80 : 40)
                        
                        Button(action: {
                            if let onMainScreen = onMainScreen {
                                onMainScreen()
                            } else {
                                onDismiss()
                            }
                        }) {
                            Text("Main Screen")
                                .font(.system(
                                    size: horizontalSizeClass == .regular ? 20 : 18, 
                                    weight: .semibold
                                ))
                                .foregroundColor(.white)
                                .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                                .frame(height: horizontalSizeClass == .regular ? 64 : 56)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: horizontalSizeClass == .regular ? 32 : 28)
                                        .stroke(Color(hex: "#7328CF"), lineWidth: 2)
                                )
                        }
                        .padding(.horizontal, horizontalSizeClass == .regular ? 80 : 40)
                    }
                    .padding(.bottom, horizontalSizeClass == .regular ? 80 : 60)
                }
            }
        }
        .fullScreenCover(isPresented: $showNextQuiz) {
            if let nextCharacter = getNextCharacter() {
                QuizIntroView(character: nextCharacter, dataManager: dataManager)
            }
        }
    }
    
    private func getNextCharacter() -> Character? {
        // Find next character that hasn't been completed
        let availableCharacters = dataManager.characters.filter { !$0.completed }
        
        // If current character is in available list, remove it since we just completed it
        let remainingCharacters = availableCharacters.filter { $0.id != currentCharacter.id }
        
        return remainingCharacters.first
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCharacter = Character(
            id: 1,
            name: "Pavel Durov",
            image: "Pavel Durov",
            completed: false,
            stars: 0,
            quiz: Quiz(questions: [
                Question(question: "Sample question?", answers: ["A", "B", "C", "D"], correctAnswer: 0)
            ])
        )
        
        QuizView(character: sampleCharacter, dataManager: CharacterDataManager())
    }
}
