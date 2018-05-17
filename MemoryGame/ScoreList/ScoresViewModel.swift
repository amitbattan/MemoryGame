//
//  ScoresViewModel.swift
//  Accedo
//
//  Created by Amit Kumar Battan on 25/05/17.
//  Copyright © 2017 Amit Kumar Battan. All rights reserved.
//

import Foundation

class ScoresViewModel {
    private var scores:[Scores]
    private var currentGameScore:Scores?
    var currentGameScoreIndex:Int?
    var totalRecords:Int {
        get {
            return scores.count
        }
    }
    
    init(scores:[Scores], currentScore:Scores?) {
        self.scores = scores
        self.currentGameScore = currentScore
        if let currentGameScore = currentGameScore {
            self.currentGameScoreIndex = scores.index(of: currentGameScore)
        }
    }
    
    func updatePlayerName(playeName:String) -> String? {
        let name = playeName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard name.characters.count > 0 else {
            //if player name is empty
            return "Name should not be empty!"
        }
        
        var characterSet = CharacterSet.letters
        characterSet.insert(charactersIn: " ")
        if name.rangeOfCharacter(from: characterSet.inverted) != nil {
            //if player name contain character other than letters and space
            return "Name should only contains valid letters"
        }

        guard let currentGameScore = currentGameScore else {
            //Ideally it should not happen
            return "Some thing went wrong!"
        }

        currentGameScore.playerName = name
        //Save player in UserDefaults, to showing name in next game finish
        UserDefaults.standard.set(name, forKey: "playerName")
        
        if let currentGameScoreIndex = currentGameScoreIndex {
            scores[currentGameScoreIndex] = currentGameScore
        }
        
        DataManager.sharedInstance.saveContext()
        return nil
    }

    //Get name and score of current game player
    func getCurrentGameScoreInfo() -> (playerName:String?, playerScore:Int?) {
        guard let score = currentGameScore else {
            return (nil, nil)
        }
        return (score.playerName, Int(score.score))
    }

    //Get name and score at index
    func getScoreInfo(at index:Int) -> (playerName:String?, playerScore:Int?) {
        if scores.count > index {
            let score = scores[index]
            return (score.playerName, Int(score.score))
        }
        return (nil, nil)
    }

}
