import SwiftUI

struct QuizIntroView: View {
    let character: Character
    let dataManager: CharacterDataManager
    @State private var showQuizView = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        ZStack {
            Color(hex: "351162")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: horizontalSizeClass == .regular ? 50 : 40) {
                    Text(localizationManager.localizedString("About to take quiz"))
                        .font(horizontalSizeClass == .regular ? .system(size: 40, weight: .bold) : .largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, horizontalSizeClass == .regular ? 60 : 40)
                    
                    // Character Image
                    Image(character.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: horizontalSizeClass == .regular ? 350 : 280,
                            height: horizontalSizeClass == .regular ? 440 : 350
                        )
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .regular ? 25 : 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: horizontalSizeClass == .regular ? 25 : 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.orange, Color.yellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: horizontalSizeClass == .regular ? 6 : 4
                                )
                        )
                    
                    Text(localizationManager.localizedString("Ready to take the quiz about") + " \(character.name)?")
                        .font(.system(
                            size: horizontalSizeClass == .regular ? 32 : 28,
                            weight: .bold
                        ))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, horizontalSizeClass == .regular ? 60 : 30)
                    
                    Spacer()
                        .frame(height: horizontalSizeClass == .regular ? 60 : 40)
                    
                    // Buttons
                    VStack(spacing: horizontalSizeClass == .regular ? 25 : 20) {
                        Button(action: {
                            showQuizView = true
                        }) {
                            Text(localizationManager.localizedString("Start Quiz"))
                                .font(horizontalSizeClass == .regular ? .title2 : .headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                                .frame(height: horizontalSizeClass == .regular ? 60 : 50)
                                .background(Color(hex: "D29B43"))
                                .cornerRadius(25)
                        }
                        .padding(.horizontal, horizontalSizeClass == .regular ? 80 : 40)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text(localizationManager.localizedString("Back"))
                                .font(horizontalSizeClass == .regular ? .title2 : .headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                                .frame(height: horizontalSizeClass == .regular ? 60 : 50)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color(hex: "7328CF"), lineWidth: 2)
                                )
                        }
                        .padding(.horizontal, horizontalSizeClass == .regular ? 80 : 40)
                    }
                    .padding(.bottom, horizontalSizeClass == .regular ? 80 : 50)
                }
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

