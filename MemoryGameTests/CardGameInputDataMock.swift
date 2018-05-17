//
//  CardProvider.swift
//  Accedo
//
//  Created by Amit Kumar Battan on 26/05/17.
//  Copyright © 2017 Amit Kumar Battan. All rights reserved.
//

@testable import Accedo

//Mock card input, withoud suffle
class CardProviderMock: CardProvider {
    
    override func getSuffledCard() -> [Card] {
        var cards = [Card]()
        for input in rawInput {
            let card = Card(cardNo:input, isMatched:false)
            cards.append(card)
            cards.append(card)
        }
        return cards
    }
    
}
