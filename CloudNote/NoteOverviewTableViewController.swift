//
//  NoteOverviewTableViewController.swift
//  CloudNote
//
//  Created by Ziyang Tan on 3/5/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import CoreData

class NoteOverviewTableViewController: UITableViewController {
    
    var selectedNotebook: Notebook!
    var moc: NSManagedObjectContext!
    var notesArray = [Note]()
    var newNote: Note? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "dismissVC")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNote")
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let context = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext {
            moc = context
        }
        
        newNote = nil
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "persistentStoreDidChange", name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "persistentStoreWillChange:", name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: moc.persistentStoreCoordinator)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveICloudChanges:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: moc.persistentStoreCoordinator)
        
        loadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:NSPersistentStoreCoordinatorStoresWillChangeNotification, object: moc.persistentStoreCoordinator)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: moc.persistentStoreCoordinator)
    }
    
    
    func persistentStoreDidChange() {
        // reeable UI and fetch data
        self.navigationItem.title = "iCloud ready"
        self.navigationItem.rightBarButtonItem?.enabled = true
        
        loadData()
    }
    
    func persistentStoreWillChange(notification: NSNotification) {
        self.navigationItem.title = "Changes in progress"
        // disable the UI
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        moc.performBlock { () -> Void in
            if self.moc.hasChanges {
                var error: NSError? = nil
                self.moc.save(&error)
                if error != nil {
                    println("Save error: \(error)")
                } else {
                    // drop any managed object references
                    self.moc.reset()
                }
            }
        }
    }
    
    func receiveICloudChanges(notification: NSNotification) {
        moc.performBlock { () -> Void in
            self.moc.mergeChangesFromContextDidSaveNotification(notification)
            self.loadData()
        }
    }
    
    func loadData() {
        notesArray = [Note]()
        var unsortedNotes = NSMutableArray()
        
        for singleNote in selectedNotebook.note {
            let loopNote = singleNote as Note
            unsortedNotes.addObject(loopNote)
        }
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        notesArray = unsortedNotes.sortedArrayUsingDescriptors([sortDescriptor]) as [Note]
        
        self.tableView.reloadData()
    }

    
    func addNote() {
        let note = CoreDataHelper.insertManagedObject(NSStringFromClass(Note), managedObjectCOntext: moc) as Note
        note.creationDate = NSDate()
        
        selectedNotebook.addNoteObject(note)
        newNote = note
        moc.save(nil)
        
        // performSegue
        self.performSegueWithIdentifier("showSingleNote", sender: self)
    }

    func dismissVC() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return notesArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        cell.textLabel?.text = notesArray[indexPath.row].title

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSingleNote" {
            let noteVC = segue.destinationViewController as NoteViewController
            
            if let segueNote = newNote {
                noteVC.selectedNote = segueNote
            } else {
                if let index = self.tableView.indexPathForSelectedRow() {
                    noteVC.selectedNote = notesArray[index.row]
                }
            }
        }
    }
    

}
