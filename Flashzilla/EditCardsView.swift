//
//  EditCardsView.swift
//  Flashzilla
//
//  Created by Emile Wong on 23/6/2021.
//

import SwiftUI

struct EditCardsView: View {
    // MARK: - PROPERTIES
    @Environment(\.presentationMode) var presentationMode
    @State private var cards = [Card]()
    @State private var newPrompt = ""
    @State private var newAnswer = ""
    
    // MARK: - FUNCTIONS
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
    }
    
    func saveData() {
        if let data = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.setValue(data, forKey: "Cards")
        }
    }
    
    func addCard() {
        let trimmedPrompt = newPrompt.trimmingCharacters(in: .whitespaces)
        let trimedAnswer = newAnswer.trimmingCharacters(in: .whitespaces)
        guard trimmedPrompt.isEmpty == false && trimedAnswer.isEmpty == false else { return }
        
        let card = Card(prompt: trimmedPrompt, answer: trimedAnswer)
        cards.insert(card, at: 0)
        saveData()
        newPrompt = ""
        newAnswer = ""
    }
    
    func removeCards(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
        saveData()
    }
    
    // MARK: - BODY
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Add new card"), content: {
                    TextField("Prompt", text: $newPrompt)
                    TextField("Answer", text: $newAnswer)
                    Button("Add card", action: addCard)
                }) //: SECTION
                
                Section {
                    ForEach(0..<cards.count, id: \.self) { index in
                        VStack {
                            Text(self.cards[index].prompt)
                                .font(.headline)
                            Text(self.cards[index].answer)
                                .foregroundColor(.secondary)
                        } //: VSTACK
                    } //: LOOP
                    .onDelete(perform: removeCards)
                } //: SECITON
            } //: LIST
            .navigationBarTitle("Edit Cards")
            .navigationBarItems(trailing: Button("Done", action: dismiss))
            .listStyle(GroupedListStyle())
            .onAppear(perform: loadData)
        } //: NAVIGATION
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
// MARK: - PREVIEW
struct EditCardsView_Previews: PreviewProvider {
    static var previews: some View {
        EditCardsView()
    }
}
