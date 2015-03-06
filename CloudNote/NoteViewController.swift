//
//  NoteViewController.swift
//  CloudNote
//
//  Created by Ziyang Tan on 3/5/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import CoreData

class NoteViewController: UIViewController {
    
    var selectedNote: Note!

    @IBOutlet var contentTextView: UITextView!
    
    var titleTextField: UITextField!
    
    var moc: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let context = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext {
            moc = context
        }

        titleTextField = UITextField(frame: CGRectMake(0, 0, 200, 22))
        titleTextField.font = UIFont.boldSystemFontOfSize(19)
        titleTextField.textAlignment = NSTextAlignment.Center
        
        self.navigationItem.titleView = titleTextField
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "dismissVC")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveNote")
        
        if let noteTitle = selectedNote.title {
            titleTextField.text = noteTitle
        } else {
            titleTextField.text = "Insert title here"
        }
        
        if let noteContent = selectedNote.content {
            contentTextView.text = noteContent
        } else {
            contentTextView.text = ""
        }
    }
    
    func dismissVC() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func saveNote() {
        selectedNote.title = titleTextField.text
        selectedNote.content = contentTextView.text
        moc.save(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
