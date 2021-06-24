//
//  ContentView.swift
//  Flashzilla
//
//  Created by Emile Wong on 22/6/2021.
//

import SwiftUI

// MARK: - EXTENSION
extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
}

struct ContentView: View {
    // MARK: - PROPERTIES
    @State private var cards = [Card]()
    @State private var timeRemaining = 100
    @State private var isActive = true
    @State private var showingEditScreen = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    // MARK: - FUNCTIONS
    func removeCard(at index: Int) {
        guard index >= 0 else { return }
        cards.remove(at: index)
    }
    
    func addCard(card: Card) {
        guard cards.count >= 0 else { return }
        cards.append(card)
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
    }
    
    func resetCards() {
        cards = [Card](repeating: Card.example, count: 10)
        timeRemaining = 100
        isActive = true
        loadData()
    }
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            Image(decorative: "background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Time: \(timeRemaining)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.black)
                                .opacity(0.75)
                        )
                }
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: self.cards[index]) {
                            withAnimation {
                                self.removeCard(at: index)
                                if cards.isEmpty {
                                    isActive = false
                                }
                            }
                        }
                        .stacked(at: index, in: self.cards.count)
                        .allowsHitTesting(index == self.cards.count - 1)
                        .accessibility(hidden: index < self.cards.count - 1)
                    } //: LOOP
                } //: ZSTACK
                .allowsHitTesting(timeRemaining > 0)
                
                if cards.isEmpty || timeRemaining == 0 {
                    Text("Game Over")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(.orange)
                        .shadow(radius: 10)
                    Text("You spent \(100 - timeRemaining) seconds")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.orange)
                        .shadow(radius: 10)
                    HStack {
                        Button("Start Again", action: resetCards)
                            .padding()
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        
                        Button(action: {
                            self.showingEditScreen = true
                        }, label: {
                            Image(systemName: "plus.circle")
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color.black)
                                        .opacity(0.75)
                                )
                        })
                        
                    }
                }
            } //: VSTACK
            
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            if differentiateWithoutColor || accessibilityEnabled{
                VStack {
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.addCard(card: self.cards[self.cards.count - 1])
                                self.removeCard(at: self.cards.count - 1)
                            }
                        }) {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Wrong"))
                        .accessibility(hint: Text("Mark your answer as being incorrect"))
                        
                        Spacer()
                        Button(action: {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1)
                            }
                        }) {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Correct"))
                        .accessibility(hint: Text("Mar your answer as being correct"))
                        
                    }
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        } //: ZSTACK
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) {_ in
            self.isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) {_ in
            if self.cards.isEmpty == false {
                self.isActive = true
            }
        }
        .onReceive(timer, perform: { time in
            guard self.isActive else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }
        })
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards, content: {
            EditCardsView()
        })
        .onAppear(perform: resetCards)
            
    }
}
// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
            ContentView()
    }
}

