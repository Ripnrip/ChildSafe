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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
            guard let email = Auth.auth().currentUser?.email else { return }
            self.emailAddressLabel.text = email
        }
        
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: Selector(("hideKeyboard")))
//        tapGesture.cancelsTouchesInView = true
//        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OnboardingViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OnboardingViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        ref = Database.database().reference()
        
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
    

    

    
    // use the key to lead to the next screen
    @IBAction func segmentValueChanged(_ sender: Any) {
        guard let control = sender as? UISegmentedControl else { return }
        switch control.selectedSegmentIndex {
        case 0:
            self.studentView.isHidden = false
            self.parentView.isHidden = true
        case 1:
            self.studentView.isHidden = true
            self.parentView.isHidden = false
        default:
            //
            break
        }
    }
    @IBAction  func setValue(sender: UIButton) {
        switch sender {
        case guardianButton:
            // TODO: generate confirmation key
            print("parent")
        case childrenButton:
            // TODO: enter confirmation key
            print("children")
        default:
            break
        }
        
    }
    

    // select guardians / children
    // if guardians -> lead to a page to set up family profile / P2: confirmation key
    // if children -> lead to a page to enter confirmation key
    
    // view family profile

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
