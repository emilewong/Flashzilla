//
//  CardView.swift
//  Flashzilla
//
//  Created by Emile Wong on 22/6/2021.
//

import SwiftUI

struct CardView: View {
    // MARK: - PROPERTIES
    let card: Card
    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero
    @State private var feedback = UINotificationFeedbackGenerator()
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    
    var removal: (() -> Void)? = nil
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                        ? Color.white
                        : Color.white
                        .opacity(1 - Double(abs(offset.width / 50)))
                )
                .background(
                    differentiateWithoutColor
                        ? nil
                        : RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(offset.width > 0 ? Color.green : Color.red)
                )
                .shadow(radius: 10)
            
            VStack {
                if accessibilityEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            } //: VSTACK
            .padding(20)
            .multilineTextAlignment(.center)
        } //: ZSTACK
        .frame(width: 450, height: 250, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .rotationEffect((.degrees(Double(offset.width / 5))))
        .offset(x: offset.width * 2, y: 0)
        .opacity(2 - Double(abs(offset.width / 50)))
        .accessibility(addTraits: .isButton)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.offset = gesture.translation
                    self.feedback.prepare()
                }
                .onEnded { _ in
                    if abs(self.offset.width) > 100 {
                        if self.offset.width > 0 {
                            self.feedback.notificationOccurred(.success)
                        } else {
                            self.feedback.notificationOccurred(.error)
                        }
                        
                        self.removal?()
                    } else {
                        self.offset = .zero
                    }
                }
        )
        .onTapGesture {
            self.isShowingAnswer.toggle()
        }
        .animation(.spring())
        
    }
}

// MARK: - PREVIEW
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example)
    }
}
