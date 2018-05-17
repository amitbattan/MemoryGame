//
//  CardProvider.swift
//  Accedo
//
//  Created by Amit Kumar Battan on 26/05/17.
//  Copyright © 2017 Amit Kumar Battan. All rights reserved.
//

import Foundation

//class is responsible for providing suffle cards
class CardProvider {
    let rawInput:[String] = ["1", "2", "3", "4", "5", "6", "7", "8"]
    
    //prepare and return suffle cards
    func getSuffledCard() -> [Card] {
        var cards = [Card]()
        for input in rawInput {
            let card = Card(cardNo:input, isMatched:false)
            //add 2 entries for each card
            cards.append(card)
            cards.append(card)
        }

        //suffle cards
        cards.shuffle()
        return cards
    }
    
}
