//
//  Scores+CoreDataProperties.swift
//  Accedo
//
//  Created by Amit Kumar Battan on 24/05/17.
//  Copyright © 2017 Amit Kumar Battan. All rights reserved.
//

import Foundation
import CoreData


extension Scores {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Scores> {
        return NSFetchRequest<Scores>(entityName: "Scores")
    }

    @NSManaged public var score: Int16
    @NSManaged public var playerName: String?

}
