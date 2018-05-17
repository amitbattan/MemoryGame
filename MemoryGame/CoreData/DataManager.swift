//
//  DataManager.swift
//  Accedo
//
//  Created by Amit Kumar Battan on 24/05/17.
//  Copyright © 2017 Amit Kumar Battan. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    static let sharedInstance:DataManager = DataManager()
    static let dbName:String = "CardsScore.sqlite"
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.razeware.HitList" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    // MARK: - Core Data stack
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Scores", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent(dbName)
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            NSLog("Failed to initialize the application's saved data")
        }
        
        return coordinator
    }()
    
    lazy var sharedManagedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        if sharedManagedObjectContext.hasChanges {
            do {
                try sharedManagedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func createNewEntryFor(name:String, score:Int16, context:NSManagedObjectContext = DataManager.sharedInstance.sharedManagedObjectContext) -> Scores {
        let entry:Scores = NSEntityDescription.insertNewObject(forEntityName: "Scores", into: context) as! Scores
        entry.playerName = name
        entry.score = score
        
        DataManager.sharedInstance.saveContext()
        return entry
    }
    
    func fetchAllScores(context:NSManagedObjectContext = DataManager.sharedInstance.sharedManagedObjectContext)  -> [Scores] {
        let fetchRequest:NSFetchRequest<Scores> = Scores.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "score", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let scores:[Scores] = try context.fetch(fetchRequest)
            return scores
        } catch {
            print("Failed to fetch serach key: \(error)")
        }
        return []
    }
    
    func fetchHighestScore(context:NSManagedObjectContext = DataManager.sharedInstance.sharedManagedObjectContext)  -> Int {
        let fetchRequest:NSFetchRequest<Scores> = Scores.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "score==max(score)")
        do {
            let scores:[Scores] = try context.fetch(fetchRequest)
            if scores.count > 0 {
                return Int(scores[0].score)
            }
        } catch {
            print("Failed to fetch serach key: \(error)")
        }
        return 0
    }

}
