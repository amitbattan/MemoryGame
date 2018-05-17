//
//  DataManagerMock.swift
//  Accedo
//
//  Created by Amit Kumar Battan on 26/05/17.
//  Copyright © 2017 Amit Kumar Battan. All rights reserved.
//

@testable import Accedo
import CoreData

//Mock cordata calls, provide dummy data or no data
class DataManagerMock: DataManager {
    //Always return invalid Scores object for testing
    override func createNewEntryFor(name:String, score:Int16, context:NSManagedObjectContext = DataManager.sharedInstance.sharedManagedObjectContext) -> Scores {
        return NSEntityDescription.insertNewObject(forEntityName: "Scores", into: context) as! Scores
    }
    
    //Always return empty list for testing
    override func fetchAllScores(context:NSManagedObjectContext = DataManager.sharedInstance.sharedManagedObjectContext)  -> [Scores] {
        return []
    }
    
    //Always return high score 10 for testing
    override func fetchHighestScore(context:NSManagedObjectContext = DataManager.sharedInstance.sharedManagedObjectContext)  -> Int {
        return 9
    }
    
    //By pass saveContext for testing
    override func saveContext() {
    }
}
