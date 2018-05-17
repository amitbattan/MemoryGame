//
//  Card.swift
//  Accedo
//
//  Created by Amit Kumar Battan on 26/05/17.
//  Copyright © 2017 Amit Kumar Battan. All rights reserved.
//

import Foundation

struct Card {
    var cardNo:String
    var isMatched:Bool = false // is card matchs?
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.cardNo == rhs.cardNo
    }
}
