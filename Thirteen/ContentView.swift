//
//  ContentView.swift
//  Thirteen
//
//  Created by Alexander Burneikis on 7/6/2022.
//

import SwiftUI

let screenSize: CGRect = UIScreen.main.bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height

let cards = [
    "1S", "2S", "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "11S", "12S", "13S","1D", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "11D", "12D", "13D","1C", "2C", "3C", "4C", "5C", "6C", "7C", "8C", "9C", "10C", "11C", "12C", "13C","1H", "2H", "3H", "4H", "5H", "6H", "7H", "8H", "9H", "10H", "11H", "12H", "13H"
]

var currentCards = cards
var lastCard = "gray_back"

let green = UIColor(red:0,green:1,blue:0,alpha: 0.3)
let red = UIColor(red:1,green:0,blue:0,alpha: 0.3)

let userDefaults = UserDefaults.standard

private struct pastCard: Identifiable {
    let name: String
    let win: Bool
    var id: String { name }
}

struct ContentView: View {
    @State private var currentCard = currentCards.randomElement()!
    @State private var pastCards: [pastCard] = []
    
    @State private var cardsUsed = 1
    @State private var rawScore = 0
    @State private var wins = 0
    
    @State private var score = 0
    
    @State private var showFinishedSheet = false
    
    func addScore(isOver: Bool) {
        if (isWin(isOver: isOver)) {
            rawScore += (1000/(abs((Int(lastCard.trimmingCharacters(in: CharacterSet(charactersIn: "SDCH")))! + Int(currentCard.trimmingCharacters(in: CharacterSet(charactersIn: "SDCH")))!)-13)+1))
            wins += 1
        }
        score = rawScore*wins/(cardsUsed-1 == 0 ? 1 : cardsUsed - 1)
    }
    func isWin(isOver: Bool) -> Bool{
        var card1Value = Int(lastCard.trimmingCharacters(in: CharacterSet(charactersIn: "SDCH")))!
        var card2Value = Int(currentCard.trimmingCharacters(in: CharacterSet(charactersIn: "SDCH")))!
        if (card1Value > 10) {
            card1Value = 10
        }
        if (card2Value > 10) {
            card2Value = 10
        }
        
        if (isOver) {
            if (card1Value + card2Value > 13) {
                return true
            }
            else {
                return false
            }
        } else {
            if (card1Value + card2Value <= 13) {
                return true
            }
            else {
                return false
            }
        }
    }
    
    func makeToolBar() -> some View{
        return NavigationView {
            HStack {}
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text(String(100*wins/(cardsUsed-1 == 0 ? 1 : cardsUsed - 1)) + "%")
                    }
                    ToolbarItem(placement: .status) {
                        Text("Points: " + String(rawScore))
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Text(String(cardsUsed) + "/52")
                    }
                }
        }
        .frame(height: screenHeight * 0.051)
    }
    
    func makeCard() -> some View{
        return Image(currentCard)
            .resizable()
            .scaledToFit()
    }
    func makeLastCards() -> some View {
        return ScrollView(.horizontal) {
            HStack(spacing: -40) {
                ForEach(pastCards) { pastCard in
                    ZStack {
                        Image(pastCard.name)
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.15)
                        Color(pastCard.win ? green : red)
                            .frame(width: screenWidth * 0.21, height: screenHeight * 0.15)
                    }
                }
                Color.clear
                    .frame(height: screenHeight * 0.15)
            }
        }
    }
    
    func makeTopButton() -> some View {
        return Color(red: 1, green: 1, blue: 1, opacity: 0.01)
            .onTapGesture {
                if (currentCards.count > 1) {
                    currentCards.remove(at:currentCards.firstIndex(of: currentCard)!)
                    lastCard = currentCard
                    currentCard = currentCards.randomElement()!
                    pastCards.insert(pastCard(name: lastCard, win: isWin(isOver:true)), at: 0)
                    addScore(isOver: true)
                    cardsUsed += 1
                }
                else {
                    showFinishedSheet.toggle()
                    pastCards.removeAll()
                    currentCards = cards
                }
            }
    }
    func makeBottomButton() -> some View {
        return Color(red: 1, green: 1, blue: 1, opacity: 0.01)
            .onTapGesture {
                if (currentCards.count > 1) {
                    currentCards.remove(at:currentCards.firstIndex(of: currentCard)!)
                    lastCard = currentCard
                    currentCard = currentCards.randomElement()!
                    pastCards.insert(pastCard(name: lastCard, win: isWin(isOver:false)), at: 0)
                    if (Int(lastCard.trimmingCharacters(in: CharacterSet(charactersIn: "SDCH")))! > 3) {
                        addScore(isOver: false)
                    }
                    cardsUsed += 1
                }
                else {
                    showFinishedSheet.toggle()
                    pastCards.removeAll()
                    currentCards = cards
                }
            }
    }
    func makeButtons() -> some View{
        return VStack(spacing: 0) {
            makeTopButton()
            makeBottomButton()
        }
    }
    
    func sheetDismissed() {
        if score > userDefaults.integer(forKey: "highScore") {
            userDefaults.set(score, forKey: "highScore")
        }
        rawScore = 0
        wins = 0
        cardsUsed = 1
    }
    func makeSheetContent() -> some View{
        VStack {
            Spacer()
            Text("High Score")
            Text(String(userDefaults.integer(forKey: "highScore")))
                .font(Font.system(size: 40))
            Spacer()
            Text(score > userDefaults.integer(forKey: "highScore") ? "New High Score!" : "Score")
            Text(String(score))
                .font(Font.system(size: 90))
                .bold()
            Button {
                showFinishedSheet.toggle()
            } label: {
                Text("Play Again")
                    .font(Font.system(size: 30))
                    .bold()
            }
            Spacer()
            Spacer()
            Spacer()
        }
    }
    
    var body: some View {
        VStack {
            makeToolBar()
            ZStack {
                VStack() {
                    makeCard()
                    makeLastCards()
                }
                makeButtons()
            }
            
        }
            .sheet(isPresented: $showFinishedSheet, onDismiss: {
                sheetDismissed()
            }) {
            makeSheetContent()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portrait)
    }
}
