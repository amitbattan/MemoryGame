//
//  CradGameViewModel.swift
//  Accedo
//
//  Created by Amit Kumar Battan on 23/05/17.
//  Copyright © 2017 Amit Kumar Battan. All rights reserved.
//

import Foundation

protocol CardGameViewModelDelegate:class {
    //Calls if card is second card, it give index of both card and match result
    func cardMatches(firstIndex:Int, secondIndex:Int, isMatch:Bool)
    //Calls when game is start
    func loadNewGame()
    //Calls when score is change (at game start or after every alternative selection), give highScore if previous highscore breaks
    func updateScore(score:Int, highestScore:Int?)
    //Calls on game finish with score info and default player name
    func gameFinish(scroe:Scores)
}

//View Model for card memory game
class CardGameViewModel {
    
    //properties
    fileprivate var cards:[Card] = [Card]()
    fileprivate var selectedCardIndex:Int?
    fileprivate var openCardCount:Int = 0
    fileprivate var score:Int = 0
    fileprivate var highestScore:Int = 0
    let defaultPlayerName:String = "Player Name"
    
    var delegate:CardGameViewModelDelegate?
    var dataManager:DataManager = DataManager.sharedInstance
    var cardProvider:CardProvider = CardProvider()
    
    var totalCards:Int {
        get {
            return cards.count
        }
    }
    
    //start new game
    func startGame() {
        //reset card array and other properties
        cards = cardProvider.getSuffledCard()
        score = 0
        openCardCount = 0
        
        //Load Game
        delegate?.loadNewGame()
        
        //Update highest score
        highestScore = dataManager.fetchHighestScore()
        delegate?.updateScore(score:score, highestScore:highestScore)
    }
    
    //Get card at index
    func card(at index:Int) -> Card? {
        if cards.count > index {
            return cards[index]
        }
        return nil
    }
    
    //If select a card which already selected or matched, return true
    func isSelectedOrMatched(for index:Int) -> Bool {
        return selectedCardIndex == index || cards[index].isMatched
    }
    
    //On Selection of a card
    func cardSelect(at index:Int) {
        
        if selectedCardIndex == index || cards[index].isMatched {
            //If select a card which already selected or matched, do nothing
            return
        }

        guard let selectedCardIndex = selectedCardIndex else {
            //If there is no other card selected then set selectedCardIndex and return
            self.selectedCardIndex = index
            return
        }
        
        //if it is a second card then check the match
        self.checkMatch(firstIndex:selectedCardIndex, secondIndex:index)
    }
    
    //to check the match
    private func checkMatch(firstIndex:Int, secondIndex:Int) {
        defer {
            //set selectedCardIndex == nil in any
            self.selectedCardIndex = nil
        }
        
        var isMatches = false

        guard cards.count > firstIndex && cards.count > secondIndex else {
            //Ideally it should never happens
            return
        }
        
        let firstCard = cards[firstIndex]
        let secondCard = cards[secondIndex]

        if firstCard == secondCard {
            //if card is a match then mark card as matched
            cards[firstIndex].isMatched = true
            cards[secondIndex].isMatched = true
            //and set isMatches true
            isMatches = true
            score += 2

            // if card matches then increament openCardCount by 2
            openCardCount += 2
        } else {
            score -= 1
        }
        //Call delegate to update UI
        delegate?.cardMatches(firstIndex:firstIndex, secondIndex:secondIndex, isMatch:isMatches)

        //Update highest score if highestScore breaks
        var localHighestScore:Int? = nil
        if highestScore < score {
           localHighestScore = score
        }
        //Update highest score UI
        delegate?.updateScore(score:score, highestScore:localHighestScore)
        
        if openCardCount == cards.count {
            // if openCardCount equal to total cards then game is over
            gameFinish()
        }
    }
    
    //on game over
    fileprivate func gameFinish() {
        //Add entry for score in local DB
        let name = UserDefaults.standard.string(forKey: "playerName") ?? defaultPlayerName
        let newEntry = dataManager.createNewEntryFor(name:name, score:Int16(score))

        //Call delegate to update UI
        delegate?.gameFinish(scroe:newEntry)
    }
    
    //get all saved scores
    func getAllScores() -> [Scores] {
        return dataManager.fetchAllScores()
    }
   
}
