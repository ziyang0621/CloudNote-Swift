//
//  CoreDataHelper.swift
//  CloudNote
//
//  Created by Ziyang Tan on 3/5/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper: NSObject {
   
    class func insertManagedObject(className: NSString, managedObjectCOntext: NSManagedObjectContext) -> AnyObject {
        let managedObject = NSEntityDescription.insertNewObjectForEntityForName(className, inManagedObjectContext: managedObjectCOntext) as NSManagedObject
        
        return managedObject
    }
    
    class func fetchEntities(className: NSString, managedObjectContext: NSManagedObjectContext, predicate: NSPredicate?) -> NSArray {
        let fetchRequest = NSFetchRequest()
        let entityDescritpion = NSEntityDescription.entityForName(className, inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entityDescritpion
        
        if predicate != nil {
            fetchRequest.predicate = predicate!
        }
        
        fetchRequest.returnsObjectsAsFaults = false
        
        let items = managedObjectContext.executeFetchRequest(fetchRequest, error: nil)!
        
        return items
    }
    
}
