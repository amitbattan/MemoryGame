//
//  CardGameViewModelTest.swift
//  Accedo
//
//  Created by Amit Kumar Battan on 25/05/17.
//  Copyright © 2017 Amit Kumar Battan. All rights reserved.
//

import XCTest
@testable import Accedo

class CardGameViewModelTest: XCTestCase, CardGameViewModelDelegate {
    
    var viewModel:CardGameViewModel!
    var firstIndex:Int = -1
    var secondIndex:Int = -1
    var isMatch:Bool = false
    var cardMatchesCalled:Bool = false
    var loadNewGameCalled:Bool = false
    var updateScoreCalled:Bool = false
    var gameFinishCalled:Bool = false
    var score:Int = 10000
    var highestScore:Int? = nil

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel = CardGameViewModel()
        viewModel.dataManager = DataManagerMock()
        viewModel.delegate = self
        self.resetCheckes()
        viewModel.startGame()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testStartGame() {
        XCTAssertTrue(loadNewGameCalled)
        //Update highest score
        
        XCTAssertTrue(updateScoreCalled)
        XCTAssertEqual(score, 0)
        XCTAssertEqual(highestScore, 9)
        XCTAssertEqual(viewModel.totalCards, 16)
    }
    
    func testCardAtIndex() {
        var card = viewModel.card(at: 0)
        XCTAssertNotNil(card)
        
        card = viewModel.card(at: 16)
        XCTAssertNil(card)
    }
    
    //Test full game with actual input
    func testCompleteGame() {
        var s = score
        let hs = highestScore ?? 0
        
        while gameFinishCalled == false {
            let i:Int = Int(arc4random() % 16)
            self.resetCheckes()
            if viewModel.isSelectedOrMatched(for: i) == false {
                //If selection is a valid selection
                viewModel.cardSelect(at: i)
                if cardMatchesCalled == true {
                    //If it is a second card
                    XCTAssertTrue(updateScoreCalled)
                    if isMatch {
                        //If it is a match
                        s += 2
                        XCTAssertEqual(score, s)
                        if score > hs {
                            XCTAssertEqual(highestScore, s)
                        } else {
                            XCTAssertNil(highestScore)
                        }
                    } else {
                        //If it is a mismatch
                        s -= 1
                        XCTAssertEqual(score, s)
                        XCTAssertNil(highestScore)
                    }
                } else {
                    //If it is a first card
                    XCTAssertFalse(updateScoreCalled)
                    XCTAssertFalse(gameFinishCalled)
                }
            }
        }
        
    }
    
    //Test full game with mock input
    func testSomeGameSteps() {

        //Start Game with mock input
        viewModel.cardProvider = CardProviderMock()
        viewModel.startGame()
        
        //Step 1 First Selection
        self.resetCheckes()
        viewModel.cardSelect(at: 0)
        XCTAssertFalse(cardMatchesCalled) //should not call delegate cardMatches
        XCTAssertFalse(updateScoreCalled) //should not call delegate updateScore
        XCTAssertFalse(gameFinishCalled)  //should not call delegate gameFinish

        //Try Step 2
        self.resetCheckes()
        //Invalid selection
        var isSelectedOrMatched = viewModel.isSelectedOrMatched(for: 0)
        XCTAssertTrue(isSelectedOrMatched)
        //Valid selection
        isSelectedOrMatched = viewModel.isSelectedOrMatched(for: 1)
        XCTAssertFalse(isSelectedOrMatched)

        //Step 2 Second Selection, is a match
        self.resetCheckes()
        viewModel.cardSelect(at: 1)
        XCTAssertTrue(cardMatchesCalled) //should call delegate cardMatches
        //cardMatches params
        XCTAssertEqual(firstIndex, 0)
        XCTAssertEqual(secondIndex, 1)
        XCTAssertTrue(isMatch)
        
        XCTAssertTrue(updateScoreCalled) //should call delegate updateScore
        XCTAssertEqual(score, 2) //score, should increment 2
        XCTAssertNil(highestScore) //highestScore, should be nit as record not breaks

        XCTAssertFalse(gameFinishCalled)

        //Try Step 3
        self.resetCheckes()
        //Invalid selection
        isSelectedOrMatched = viewModel.isSelectedOrMatched(for: 0)
        XCTAssertTrue(isSelectedOrMatched)
        //Invalid selection
        isSelectedOrMatched = viewModel.isSelectedOrMatched(for: 1)
        XCTAssertTrue(isSelectedOrMatched)
        //Valid selection
        isSelectedOrMatched = viewModel.isSelectedOrMatched(for: 2)
        XCTAssertFalse(isSelectedOrMatched)
        
        //Step 3 First Selection
        self.resetCheckes()
        viewModel.cardSelect(at: 2)
        XCTAssertFalse(cardMatchesCalled)
        XCTAssertFalse(updateScoreCalled)
        XCTAssertFalse(gameFinishCalled)

        //Step 4 Second Selection, not a match
        self.resetCheckes()
        viewModel.cardSelect(at: 6)
        XCTAssertTrue(cardMatchesCalled)
        XCTAssertEqual(firstIndex, 2)
        XCTAssertEqual(secondIndex, 6)
        XCTAssertFalse(isMatch)
        
        //check score, should decrement 1
        XCTAssertTrue(updateScoreCalled)
        XCTAssertEqual(score, 1)
        XCTAssertNil(highestScore)

        XCTAssertFalse(gameFinishCalled)

        //Step 5-6 is a match
        self.resetCheckes()
        viewModel.cardSelect(at: 2)
        viewModel.cardSelect(at: 3)
        XCTAssertTrue(cardMatchesCalled)
        XCTAssertEqual(firstIndex, 2)
        XCTAssertEqual(secondIndex, 3)
        XCTAssertTrue(isMatch)
        XCTAssertTrue(updateScoreCalled)
        XCTAssertEqual(score, 3)
        XCTAssertNil(highestScore)
        XCTAssertFalse(gameFinishCalled)

        //Step 7-8 is a match
        self.resetCheckes()
        viewModel.cardSelect(at: 6)
        viewModel.cardSelect(at: 7)
        XCTAssertTrue(cardMatchesCalled)
        XCTAssertEqual(firstIndex, 6)
        XCTAssertEqual(secondIndex, 7)
        XCTAssertTrue(isMatch)
        XCTAssertTrue(updateScoreCalled)
        XCTAssertEqual(score, 5)
        XCTAssertNil(highestScore)
        XCTAssertFalse(gameFinishCalled)
        
        //Step 9-10 is a match
        self.resetCheckes()
        viewModel.cardSelect(at: 8)
        viewModel.cardSelect(at: 9)
        XCTAssertTrue(cardMatchesCalled)
        XCTAssertEqual(firstIndex, 8)
        XCTAssertEqual(secondIndex, 9)
        XCTAssertTrue(isMatch)
        XCTAssertTrue(updateScoreCalled)
        XCTAssertEqual(score, 7)
        XCTAssertNil(highestScore)
        XCTAssertFalse(gameFinishCalled)
        
        //Step 11-12 is a match
        self.resetCheckes()
        viewModel.cardSelect(at: 4)
        viewModel.cardSelect(at: 5)
        XCTAssertTrue(cardMatchesCalled)
        XCTAssertEqual(firstIndex, 4)
        XCTAssertEqual(secondIndex, 5)
        XCTAssertTrue(isMatch)
        XCTAssertTrue(updateScoreCalled)
        XCTAssertEqual(score, 9)
        XCTAssertNil(highestScore)
        XCTAssertFalse(gameFinishCalled)
        
        //Step 13-14 is a match
        self.resetCheckes()
        viewModel.cardSelect(at: 10)
        viewModel.cardSelect(at: 11)
        XCTAssertTrue(cardMatchesCalled)
        XCTAssertEqual(firstIndex, 10)
        XCTAssertEqual(secondIndex, 11)
        XCTAssertTrue(isMatch)
        XCTAssertTrue(updateScoreCalled)
        XCTAssertEqual(score, 11)
        //Record break highestScore should set
        XCTAssertEqual(highestScore, 11)
        XCTAssertFalse(gameFinishCalled)
        
        //Step 15-16
        self.resetCheckes()
        viewModel.cardSelect(at: 12)
        viewModel.cardSelect(at: 13)
        XCTAssertTrue(cardMatchesCalled)
        XCTAssertEqual(firstIndex, 12)
        XCTAssertEqual(secondIndex, 13)
        XCTAssertTrue(isMatch)
        XCTAssertTrue(updateScoreCalled)
        XCTAssertEqual(score, 13)
        XCTAssertEqual(highestScore, 13)
        XCTAssertFalse(gameFinishCalled)
        
        //Step 17-18
        self.resetCheckes()
        viewModel.cardSelect(at: 14)
        viewModel.cardSelect(at: 15)
        XCTAssertTrue(cardMatchesCalled)
        XCTAssertEqual(firstIndex, 14)
        XCTAssertEqual(secondIndex, 15)
        XCTAssertTrue(isMatch)
        XCTAssertTrue(updateScoreCalled)
        XCTAssertEqual(score, 15)
        XCTAssertEqual(highestScore, 15)
        
        //Now all match done, gameFinish should call
        XCTAssertTrue(gameFinishCalled)
 
    }
    
    func cardMatches(firstIndex:Int, secondIndex:Int, isMatch:Bool) {
        self.firstIndex = firstIndex
        self.secondIndex = secondIndex
        self.isMatch = isMatch
        self.cardMatchesCalled = true
    }

    func loadNewGame() {
        self.loadNewGameCalled = true
    }
    
    func updateScore(score:Int, highestScore:Int?) {
        self.updateScoreCalled = true
        self.score = score
        self.highestScore = highestScore
    }
    
    func gameFinish(scroe:Scores) {
        self.gameFinishCalled = true
    }
    
    func resetCheckes() {
        firstIndex = -1
        secondIndex = -1
        isMatch = false
        cardMatchesCalled = false
        loadNewGameCalled = false
        updateScoreCalled = false
        gameFinishCalled = false
        score = 10000
        highestScore = nil
    }
    
}
