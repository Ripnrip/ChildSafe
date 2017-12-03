//
//  OnboardingViewController.swift
//  ChildSafe
//
//  Created by Gurinder Singh on 12/2/17.
//  Copyright © 2017 Gurinder Singh. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class OnboardingViewController: UIViewController {

    @IBOutlet weak var guardianButton: UIButton!
    @IBOutlet weak var childrenButton: UIButton!
    @IBOutlet weak var studentView: UIView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    var ref: DatabaseReference!
    let defaults:UserDefaults = UserDefaults.standard
    var isStudent = false
    
    var allEmails = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
            guard let email = Auth.auth().currentUser?.email else { return }
            self.emailAddressLabel.text = email
        }
        
        ref = Database.database().reference()
        
        ref.child("users").queryOrdered(byChild: "email").observe(.value, with: { snapshot in
            print("all the data in the snapshot is \(snapshot)")
            //let dict = snapshot as [String:Any]
            guard let myData = snapshot.value as? [String: Any] else { print("error converting dict in onboarding to get emails"); return }
            
            myData.forEach({ (child) in
                //let email = child["email"]
                print("the child iterated is \(child.value)")
                guard let info = child.value as? [String:Any],
                let email = info["email"] as? String
                else { return }
                
                print("the found email is \(email)")
                self.allEmails.append(email)
            })
        })
        
        isStudent = defaults.bool(forKey: "isStudent" )
        
        if isStudent {
            self.studentView.isHidden = false
            self.parentView.isHidden = true
            
        }else{
            self.studentView.isHidden = true
            self.parentView.isHidden = false
        }
        
    }

    func hideKeyboard() {
        emailTextField.endEditing(true)
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    

    
    @IBAction func registerChild(_ sender: Any) {
        //search and set child by email address

        
    }
    
    

    // select guardians / children
    // if guardians -> lead to a page to set up family profile / P2: confirmation key
    // if children -> lead to a page to enter confirmation key
    


}
