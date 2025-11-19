import SwiftUI

struct QuizIntroView: View {
    let character: Character
    let dataManager: CharacterDataManager
    @State private var showQuizView = false
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        ZStack {
            Color(hex: "351162")
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text(localizationManager.localizedString("About to take quiz"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
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
                
                Text(localizationManager.localizedString("Ready to take the quiz about") + " \(character.name)?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 20) {
                    Button(action: {
                        showQuizView = true
                    }) {
                        Text(localizationManager.localizedString("Start Quiz"))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "D29B43"))
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 40)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text(localizationManager.localizedString("Back"))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color(hex: "7328CF"), lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showQuizView) {
            QuizView(character: character, dataManager: dataManager)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissQuizIntro"))) { _ in
            dismiss()
        }
    }
}

struct QuizIntroView_Previews: PreviewProvider {
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
        
        QuizIntroView(character: sampleCharacter, dataManager: CharacterDataManager())
    }
}

