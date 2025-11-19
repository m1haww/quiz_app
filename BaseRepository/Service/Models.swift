import Foundation

struct CharacterData: Codable {
    let characters: [Character]
}

struct Character: Codable, Identifiable {
    let id: Int
    let name: String
    let image: String
    var completed: Bool
    var stars: Int
    let quiz: Quiz
}

struct Quiz: Codable {
    let questions: [Question]
}

struct Question: Codable {
    let question: String
    let answers: [String]
    let correctAnswer: Int
}

class CharacterDataManager: ObservableObject {
    @Published var characters: [Character] = []
    
    init() {
        loadCharacters()
    }
    
    func loadCharacters() {
        guard let url = Bundle.main.url(forResource: "characters_data", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let characterData = try? JSONDecoder().decode(CharacterData.self, from: data) else {
            print("Failed to load characters data")
            return
        }
        
        self.characters = characterData.characters
    }
    
    func updateCharacterProgress(id: Int, completed: Bool, stars: Int) {
        if let index = characters.firstIndex(where: { $0.id == id }) {
            characters[index].completed = completed
            characters[index].stars = stars
        }
    }
}