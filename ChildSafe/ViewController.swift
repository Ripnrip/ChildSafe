//
//  ViewController.swift
//  ChildSafe
//
//  Created by Gurinder Singh on 12/2/17.
//  Copyright © 2017 Gurinder Singh. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController, LoginButtonDelegate {
    
    
    var dict : [String : AnyObject] = [:]
    var ref: DatabaseReference!
    var isStudent = true
    let defaults:UserDefaults = UserDefaults.standard

    override func viewWillAppear(_ animated: Bool) {
        
        if FBSDKAccessToken.current() != nil {
            //go to next vc
            DispatchQueue.main.async {
                print("Async1")
                //self.performSegue(withIdentifier: "goToOnboarding", sender: nil)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = Database.database().reference()

        if (FBSDKAccessToken.current() != nil )  {
            // User is logged in, do work such as go to next view controller.
            DispatchQueue.main.async {
                print("Async2")
                //self.performSegue(withIdentifier: "goToOnboarding", sender: nil)
            }
            
            let loginButton = LoginButton(readPermissions: [.publicProfile, .email ])
            loginButton.center = view.center
            loginButton.delegate = self
            view.addSubview(loginButton)
            
        }else{
        
        let loginButton = LoginButton(readPermissions: [.publicProfile, .email ])
        loginButton.center = view.center
        loginButton.delegate = self
        view.addSubview(loginButton)
        }
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .success(let grantedPermissions, _, let accessToken):
            print("facebook success")
            print(accessToken.authenticationToken)
            guard let token = FBSDKAccessToken.current().tokenString else { break } 
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    // ...
                    return
                }
                // User is signed in
                // ...
                
                let alertController = UIAlertController(title: "Alert", message: "Are you a student, or a parent?", preferredStyle: .alert)
                
                let action1 = UIAlertAction(title: "Student", style: .default) { (action:UIAlertAction) in
                    print("You've pressed Student");
                    self.isStudent = true
                    guard let email = user?.email ,
                        let uid = user?.uid
                        else { return }
                    
                    self.defaults.set(true, forKey: "isStudent")
                    self.getFBUserDataWithAuthID(authID: uid)
                }
                
                let action2 = UIAlertAction(title: "Parent", style: .default) { (action:UIAlertAction) in
                    print("You've pressed Parent");
                    self.isStudent = false
                    guard let email = user?.email ,
                        let uid = user?.uid
                        else { return }
                    self.defaults.set(false, forKey: "isStudent")
                    self.getFBUserDataWithAuthID(authID: uid)
                }
                
                alertController.addAction(action1)
                alertController.addAction(action2)
                self.present(alertController, animated: true, completion: nil)
                
            }

        
            break
        case .cancelled:
            print("facebook cancelled")
            break
            
        case .failed(let error):
            print("facebook error")
            break
        }
    }
    
    
    //function is fetching the user data
    func getFBUserDataWithAuthID(authID:String){
        
        
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email,family"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    //print(result!)
                    //print(self.dict)
                    //go to next page
                    let name = self.dict["name"]
                    let email = self.dict["email"]
                    let fbID = self.dict["id"]
                    let isStudent = self.isStudent
                    guard let imageURL = ((self.dict["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String else {return}
                    
                    let userData = ["name": name,
                                    "email": email,
                                    "fbID":fbID,
                                    "imageURL":imageURL,
                                    "isStudent":isStudent] as [String : Any]
                    
                    self.ref.child("users").child(authID).setValue(userData)
                    
                    
                    DispatchQueue.main.async {
                        print("Async1")
                        self.performSegue(withIdentifier: "goToOnboarding", sender: nil)
                    }
                }
            })
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        //
    }



}

