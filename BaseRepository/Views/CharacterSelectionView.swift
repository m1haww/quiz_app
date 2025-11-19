import SwiftUI

struct CharacterSelectionView: View {
    @StateObject private var dataManager = CharacterDataManager()
    @State private var selectedCharacter: Character? = nil
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#351162")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text(localizationManager.localizedString("home"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(dataManager.characters) { character in
                                Button(action: {
                                    selectedCharacter = character
                                }) {
                                    CharacterCard(character: character)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(item: $selectedCharacter) { character in
            QuizIntroView(character: character, dataManager: dataManager)
        }
    }
}

struct CharacterCard: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 10) {
            Image(character.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity )
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Text(character.name)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
}

struct CharacterSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterSelectionView()
    }
}
