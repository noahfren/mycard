//
//  CardInfoViewController.swift
//  mycard
//
//  Created by Noah Frenkel on 8/9/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import UIKit
import Parse
import JSSAlertView

class CardInfoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var newUser: PFUser!
    
    var firstName: String!
    var lastName: String!
    var email: String!
    var password: String!
    
    let imagePicker = UIImagePickerController()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailFIeld: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBAction func cancelButton(sender: AnyObject) {
        
        appDelegate.parseLoginManager.signOutUser()
        newUser.deleteInBackground()
    }
    
    @IBAction func signUpButton(sender: AnyObject) {
        
        guard firstNameField.text != nil else {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let alertView = JSSAlertView().show(
                    self,
                    title: "Invalid First Name",
                    text: "Please enter your first name.",
                    buttonText: "Dismiss",
                    color: WET_ASPHALT
                )
                alertView.setTextTheme(.Light)
            }
            return
        }
        
        guard lastNameField.text != nil else {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let alertView = JSSAlertView().show(
                    self,
                    title: "Invalid Last Name",
                    text: "Please enter your last name.",
                    buttonText: "Dismiss",
                    color: WET_ASPHALT
                )
                alertView.setTextTheme(.Light)
            }
            return
        }
        
        guard ValidationManager.validateEmailAddress(emailFIeld.text) else {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let alertView = JSSAlertView().show(
                    self,
                    title: "Invalid Email Address",
                    text: "Please enter a valid email.",
                    buttonText: "Dismiss",
                    color: WET_ASPHALT
                )
                alertView.setTextTheme(.Light)
            }
            return
        }
        
        guard ValidationManager.validatePhoneNumber(phoneNumberField.text) else {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let alertView = JSSAlertView().show(
                    self,
                    title: "Invalid Phone Number",
                    text: "Please enter a phone number in the form:\n(xxx) xxx-xxxx",
                    buttonText: "Dismiss",
                    color: WET_ASPHALT
                )
                alertView.setTextTheme(.Light)
            }
            return
        }
        
        let newCard = Card()
        newCard["isOwnedBy"] = newUser
        newCard["firstName"] = firstNameField.text!
        newCard["lastName"] = lastNameField.text!
        newCard["phoneNumber"] = phoneNumberField.text!
        newCard["email"] = emailFIeld.text!
        
        if let image = imageView.image {
            newCard.image = image
        }
        else {
            newCard.image = UIImage(named: "defaultUser")!
        }
        
        let imageFile = UIImageJPEGRepresentation(newCard.image!, 1.0)
        
        newCard.imageFile = PFFile(name: "profilePic.jpg", data: imageFile!)
        newCard["image"] = newCard.imageFile
        
        newCard.saveInBackgroundWithBlock() {
            (succeeded: Bool, error: NSError?) -> Void in
            
            PFUser.logInWithUsernameInBackground(self.email, password: self.password) {
                (user: PFUser?, error: NSError?) -> Void in
                self.appDelegate.currentUserCard = ParseManager.getCardForCurrentUser()
                self.appDelegate.currentUserCard.fetchImage() {() -> Void in }
                self.appDelegate.mpcManager = MPCManager(currentUserCard: self.appDelegate.currentUserCard, currentUserID: user!.objectId!)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                
                self.showViewController(tabBarController, sender: self)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameField.text = firstName
        lastNameField.text = lastName
        emailFIeld.text = email
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        
        imageView.addGestureRecognizer(tapGesture)
        
        let image = UIImage(named: "defaultUser")
        let newSize = CGSize(width: 150, height: 150)
        let smallerImage = ImageHelper.resizeImage(image!.square!, targetSize: newSize)
        imageView.image = smallerImage

        
    }
    
    override func viewWillAppear(animated: Bool) {
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tap() {
        
        var source: UIImagePickerControllerSourceType!
        
        dispatch_async(dispatch_get_main_queue()) {
            let alert = JSSAlertView().show(
                self,
                title: "Choose photo source",
                buttonText: "Camera",
                cancelButtonText: "Library",
                color: WET_ASPHALT
            )
            alert.setTextTheme(.Light)
            alert.addAction() {
                source = UIImagePickerControllerSourceType.Camera
                if UIImagePickerController.isSourceTypeAvailable(source){
                    
                    self.imagePicker.delegate = self
                    self.imagePicker.sourceType = source
                    self.imagePicker.allowsEditing = false
                    
                    self.presentViewController(self.imagePicker, animated: true, completion: nil)
                }
                
            }
            alert.addCancelAction() {
                source = UIImagePickerControllerSourceType.SavedPhotosAlbum
                if UIImagePickerController.isSourceTypeAvailable(source){
                    
                    self.imagePicker.delegate = self
                    self.imagePicker.sourceType = source
                    self.imagePicker.allowsEditing = false
                    
                    self.presentViewController(self.imagePicker, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        let newSize = CGSize(width: 150, height: 150)
        let smallerImage = ImageHelper.resizeImage(image.square!, targetSize: newSize)
        imageView.image = smallerImage
        
    }

    //Dismisses keyboard when screen is touched
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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
