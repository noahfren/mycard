//
//  AddContactInfoViewController.swift
//  mycard
//
//  Created by Benjamin Bucca on 7/8/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import UIKit
import Contacts
import JSSAlertView


let USER_IMAGE_FILENAME = "userImage.jpeg"

class EditInfoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - Outlets and Properties
    var card: Card!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var imageField: UIImageView!
    @IBAction func saveContactInfo(sender: AnyObject) {
        saveChanges()
    }
    @IBAction func signOut(sender: AnyObject) {
        
        appDelegate.parseLoginManager.signOutUser()
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let startViewController = storyboard.instantiateViewControllerWithIdentifier("LogInViewController") as! LogInViewController
        appDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        appDelegate.window?.rootViewController = startViewController;
        appDelegate.window?.makeKeyAndVisible()
    }
    
    let imagePicker = UIImagePickerController()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        if let card = appDelegate.currentUserCard {
            firstNameTextField.text = card.firstName
            lastNameTextField.text = card.lastName
            emailAddressTextField.text = card.email
            phoneNumberTextField.text = card.phoneNumber
            
            if let image = card.image {
                imageField.image = image
            }
            else {
                let image = UIImage(named: "defaultUser")
                let newSize = CGSize(width: 150, height: 150)
                let smallerImage = ImageHelper.resizeImage(image!.square!, targetSize: newSize)
                imageField.image = smallerImage
            }
        }
        else {
            let image = UIImage(named: "defaultUser")
            let newSize = CGSize(width: 150, height: 150)
            let smallerImage = ImageHelper.resizeImage(image!.square!, targetSize: newSize)
            imageField.image = smallerImage
        }
        
        // Adding tap gesture recognizer for choosing an image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        
        imageField.addGestureRecognizer(tapGesture)
        
    }

    override func viewWillAppear(animated: Bool) {
        imageField.layer.cornerRadius = imageField.frame.width / 2
        imageField.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Gesture Recognizer/ Image Picker Functions
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
        imageField.image = smallerImage
        
    }
    
    // MARK: - Keyboard
    
    //Dismisses keyboard when screen is touched
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - Save Changes
    func saveChanges() {
            
        let card = Card()
        
        if ValidationManager.validateEmailAddress(emailAddressTextField.text) {
            card.email = emailAddressTextField.text!
        } else {
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let alertView = JSSAlertView().show(
                    self,
                    title: "Invalid Email Address",
                    text: "Please enter a valid email address.",
                    buttonText: "Dismiss",
                    color: WET_ASPHALT
                )
                alertView.setTextTheme(.Light)
            }
            return
        }
        
        if ValidationManager.validatePhoneNumber(phoneNumberTextField.text) {
            card.phoneNumber = phoneNumberTextField.text!
        } else {
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
        card.firstName = firstNameTextField.text!
        card.lastName = lastNameTextField.text!
        
        if let image = imageField.image {
            card.image = image
        }
        
        ParseManager.updateCard(card)

    }

}
