//
//  Utilities.swift
//  Accedo
//
//  Created by Amit Kumar Battan on 23/05/17.
//  Copyright © 2017 Amit Kumar Battan. All rights reserved.
//

import Foundation

//Array extension for suffle the array
extension Array {
	mutating func shuffle() {
        for _ in 0...count {
            self.sort {_, _ in arc4random() % 2 == 0}
        }
    }
}

