//
//  AddContactInfoViewController.swift
//  mycard
//
//  Created by Benjamin Bucca on 7/8/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import UIKit
import Contacts

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
        
    }
    
    var isViewShifted = false
    var ogFrameOriginY: CGFloat!
    
    let imagePicker = UIImagePickerController()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditInfoViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditInfoViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        

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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditInfoViewController.tap(_:)))
        
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
    func tap(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
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
    
    // Raises view so that all text fields are visible
    func keyboardWillShow(notification: NSNotification) {
        
        // Sets original y value for view's origin
        if ogFrameOriginY == nil {
            ogFrameOriginY = self.view.frame.origin.y
        }
        
        // Get the y value for the bottom of the email text field
        let emailFieldBottomLeftCorner = CGPoint(x: emailAddressTextField.frame.maxX, y: emailAddressTextField.frame.maxY)
        let textFieldBottomYPosition = emailAddressTextField.superview?.convertPoint(emailFieldBottomLeftCorner, toView: nil).y
        
        // Get the height of the keyboard that will appear
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        let keyboardMinY = keyboardRectangle.minY
        
        let shiftBy = (textFieldBottomYPosition! - keyboardMinY) + 10
        
        // if the view is not shifted already, shift the view up so that the bottom of the email field
        // is 10 pts above the top of the keyboard
        if (!isViewShifted && (shiftBy >= 0)) {
            self.view.frame.origin.y -= shiftBy

            isViewShifted = true
        }

        
    }
    
    // Lowers view when keyboard goes away
    func keyboardWillHide(notification: NSNotification) {

        if isViewShifted {
            //self.view.frame.origin.y += (keyboardHeight - (self.emailAddressTextField.frame.maxY))
            self.view.frame.origin.y = ogFrameOriginY
            isViewShifted = false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Save" {
            
            let card = Card()
            
            card.firstName = firstNameTextField.text!
            card.lastName = lastNameTextField.text!
            card.phoneNumber = phoneNumberTextField.text!
            card.email = emailAddressTextField.text!
            
            // Saving image to filesystem
            if let image = imageField.image {
                card.image = image
            }

        }
    }

}
